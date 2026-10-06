import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import '../models/filme.dart';
import '../services/filme_scope.dart';
import '../theme/app_colors.dart';
import '../utils/validadores_filme.dart';
import '../widgets/mensagem.dart';
import '../widgets/poster_filme.dart';

/// Formulário de filme: cadastra quando [filme] é `null`, edita caso contrário.
///
/// Fecha a tela devolvendo `true` quando o filme é salvo.
class FilmeFormPage extends StatefulWidget {
  const FilmeFormPage({super.key, this.filme});

  final Filme? filme;

  @override
  State<FilmeFormPage> createState() => _FilmeFormPageState();
}

class _FilmeFormPageState extends State<FilmeFormPage> {
  final _formKey = GlobalKey<FormState>();
  late final _titulo = TextEditingController(text: widget.filme?.titulo);
  late final _ano = TextEditingController(text: widget.filme?.ano.toString());
  late final _duracao = TextEditingController(
    text: widget.filme?.duracao.toString(),
  );
  late final _nota = TextEditingController(text: widget.filme?.nota.toString());
  late final _sinopse = TextEditingController(text: widget.filme?.sinopse);
  late String? _genero = widget.filme?.genero;
  late String? _classificacao = widget.filme?.classificacao;
  late bool _assistido = widget.filme?.assistido ?? false;
  late Uint8List? _poster = widget.filme?.poster;

  var _autovalidar = AutovalidateMode.disabled;
  var _salvando = false;

  bool get _editando => widget.filme != null;

  @override
  void dispose() {
    for (final controller in [_titulo, _ano, _duracao, _nota, _sinopse]) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _escolherPoster() async {
    try {
      final arquivo = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        imageQuality: 85,
      );
      if (arquivo == null) return; // usuário fechou a galeria
      final bytes = await arquivo.readAsBytes();
      if (mounted) setState(() => _poster = bytes);
    } catch (_) {
      if (!mounted) return;
      mostrarMensagem(
        ScaffoldMessenger.of(context),
        'Não foi possível carregar a imagem.',
        erro: true,
      );
    }
  }

  Future<void> _salvar() async {
    final messenger = ScaffoldMessenger.of(context);
    if (!_formKey.currentState!.validate()) {
      setState(() => _autovalidar = AutovalidateMode.onUserInteraction);
      mostrarMensagem(messenger, 'Corrija os campos destacados.', erro: true);
      return;
    }

    final filme = Filme(
      id: widget.filme?.id ?? '',
      titulo: _titulo.text.trim(),
      genero: _genero!,
      ano: int.parse(_ano.text.trim()),
      duracao: int.parse(_duracao.text.trim()),
      classificacao: _classificacao!,
      nota: ValidadoresFilme.lerNota(_nota.text)!,
      sinopse: _sinopse.text.trim(),
      assistido: _assistido,
      poster: _poster,
    );

    final service = FilmeScope.ler(context);
    final navigator = Navigator.of(context);
    setState(() => _salvando = true);
    try {
      if (_editando) {
        await service.atualizar(filme);
      } else {
        await service.adicionar(filme);
      }
    } catch (_) {
      if (mounted) setState(() => _salvando = false);
      mostrarMensagem(
        messenger,
        'Não foi possível salvar o filme.',
        erro: true,
      );
      return;
    }

    mostrarMensagem(
      messenger,
      _editando
          ? 'Filme atualizado com sucesso!'
          : 'Filme cadastrado com sucesso!',
    );
    navigator.pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final digitos = FilteringTextInputFormatter.digitsOnly;

    return Scaffold(
      appBar: AppBar(
        title: Text(_editando ? 'Editar filme' : 'Cadastrar filme'),
        backgroundColor: AppColors.fundo,
        scrolledUnderElevation: 0,
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          autovalidateMode: _autovalidar,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
            children: [
              _SeletorPoster(
                poster: _poster,
                onEscolher: _escolherPoster,
                onRemover: () => setState(() => _poster = null),
              ),
              const _Rotulo('Título'),
              TextFormField(
                key: const ValueKey('campo-titulo'),
                controller: _titulo,
                maxLength: 100,
                textCapitalization: TextCapitalization.sentences,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  hintText: 'Ex.: Interestelar',
                  counterText: '',
                ),
                validator: ValidadoresFilme.titulo,
              ),
              const _Rotulo('Gênero'),
              DropdownButtonFormField<String>(
                key: const ValueKey('campo-genero'),
                initialValue: _genero,
                hint: const Text('Selecione o gênero'),
                items: [
                  for (final genero in generos)
                    DropdownMenuItem(value: genero, child: Text(genero)),
                ],
                onChanged: (valor) => setState(() => _genero = valor),
                validator: (valor) =>
                    ValidadoresFilme.selecao(valor, 'o gênero'),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _CampoComRotulo(
                      rotulo: 'Ano',
                      campo: TextFormField(
                        key: const ValueKey('campo-ano'),
                        controller: _ano,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          digitos,
                          LengthLimitingTextInputFormatter(4),
                        ],
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(
                          hintText: 'Ex.: 2014',
                        ),
                        validator: ValidadoresFilme.ano,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _CampoComRotulo(
                      rotulo: 'Duração (min)',
                      campo: TextFormField(
                        key: const ValueKey('campo-duracao'),
                        controller: _duracao,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          digitos,
                          LengthLimitingTextInputFormatter(3),
                        ],
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(hintText: 'Ex.: 120'),
                        validator: ValidadoresFilme.duracao,
                      ),
                    ),
                  ),
                ],
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _CampoComRotulo(
                      rotulo: 'Classificação',
                      campo: DropdownButtonFormField<String>(
                        key: const ValueKey('campo-classificacao'),
                        initialValue: _classificacao,
                        isExpanded: true,
                        hint: const Text('Selecione'),
                        items: [
                          for (final c in classificacoes)
                            DropdownMenuItem(
                              value: c,
                              child: Text(c == 'Livre' ? c : '$c anos'),
                            ),
                        ],
                        onChanged: (valor) =>
                            setState(() => _classificacao = valor),
                        validator: (valor) =>
                            ValidadoresFilme.selecao(valor, 'a classificação'),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _CampoComRotulo(
                      rotulo: 'Nota (0 a 10)',
                      campo: TextFormField(
                        key: const ValueKey('campo-nota'),
                        controller: _nota,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                          LengthLimitingTextInputFormatter(4),
                        ],
                        decoration: const InputDecoration(hintText: 'Ex.: 8,5'),
                        validator: ValidadoresFilme.nota,
                      ),
                    ),
                  ),
                ],
              ),
              const _Rotulo('Sinopse (opcional)'),
              TextFormField(
                key: const ValueKey('campo-sinopse'),
                controller: _sinopse,
                maxLines: 4,
                maxLength: 500,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  hintText: 'Sobre o que é o filme?',
                ),
              ),
              SwitchListTile(
                key: const ValueKey('campo-assistido'),
                contentPadding: EdgeInsets.zero,
                title: const Text(
                  'Já assisti este filme',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.texto,
                  ),
                ),
                value: _assistido,
                onChanged: (valor) => setState(() => _assistido = valor),
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: _salvando ? null : _salvar,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.roxo,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    _editando ? 'Salvar alterações' : 'Cadastrar filme',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: _salvando
                    ? null
                    : () => Navigator.of(context).pop(false),
                child: const Text('Cancelar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SeletorPoster extends StatelessWidget {
  const _SeletorPoster({
    required this.poster,
    required this.onEscolher,
    required this.onRemover,
  });

  final Uint8List? poster;
  final VoidCallback onEscolher;
  final VoidCallback onRemover;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        InkWell(
          onTap: onEscolher,
          borderRadius: BorderRadius.circular(14),
          child: PosterFilme(
            poster: poster,
            largura: 96,
            altura: 136,
            raio: 14,
          ),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Pôster (opcional)',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppColors.texto,
                ),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: onEscolher,
                icon: const Icon(Icons.photo_library_outlined),
                label: Text(
                  poster == null ? 'Escolher imagem' : 'Trocar imagem',
                ),
              ),
              if (poster != null)
                TextButton(onPressed: onRemover, child: const Text('Remover')),
            ],
          ),
        ),
      ],
    );
  }
}

class _Rotulo extends StatelessWidget {
  const _Rotulo(this.texto);

  final String texto;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 4),
      child: Text(
        texto,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          color: AppColors.texto,
        ),
      ),
    );
  }
}

class _CampoComRotulo extends StatelessWidget {
  const _CampoComRotulo({required this.rotulo, required this.campo});

  final String rotulo;
  final Widget campo;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [_Rotulo(rotulo), campo],
    );
  }
}

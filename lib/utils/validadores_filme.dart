/// Regras de validação do formulário de filme.
///
/// Cada função devolve a mensagem de erro, ou `null` quando o valor é válido
/// (o formato que o `validator` do `TextFormField` espera).
abstract final class ValidadoresFilme {
  /// Ano do primeiro filme de que se tem registro.
  static const anoMinimo = 1888;
  static const notaMaxima = 10.0;

  static String? titulo(String? valor) {
    if (valor == null || valor.trim().isEmpty) return 'Informe o título';
    return null;
  }

  static String? ano(String? valor, {int? anoAtual}) {
    if (valor == null || valor.trim().isEmpty) return 'Informe o ano';
    final ano = int.tryParse(valor.trim());
    final maximo = (anoAtual ?? DateTime.now().year) + 1;
    if (ano == null || ano < anoMinimo || ano > maximo) {
      return 'Ano entre $anoMinimo e $maximo';
    }
    return null;
  }

  static String? duracao(String? valor) {
    if (valor == null || valor.trim().isEmpty) return 'Informe a duração';
    final minutos = int.tryParse(valor.trim());
    if (minutos == null || minutos <= 0) return 'Deve ser maior que zero';
    return null;
  }

  static String? nota(String? valor) {
    if (valor == null || valor.trim().isEmpty) return 'Informe a nota';
    final nota = lerNota(valor);
    if (nota == null || nota < 0 || nota > notaMaxima) return 'Nota de 0 a 10';
    return null;
  }

  static String? selecao(String? valor, String campo) {
    return valor == null ? 'Selecione $campo' : null;
  }

  /// Aceita vírgula ou ponto como separador decimal ("8,5" ou "8.5").
  static double? lerNota(String valor) =>
      double.tryParse(valor.trim().replaceAll(',', '.'));
}

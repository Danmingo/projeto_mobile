import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker_platform_interface/image_picker_platform_interface.dart';
import 'package:projeto_mobile/pages/filme_form_page.dart';
import 'package:projeto_mobile/services/filme_service.dart';

import 'helpers.dart';

/// PNG de 1×1 pixel: o pôster precisa ser uma imagem de verdade.
final _png = base64Decode(
  'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNkYAAAAAYAAjCB0C8AAAAASUVORK5CYII=',
);

/// Faz o papel da galeria e da câmera: devolve uma imagem sem abrir nada.
class _PickerFalso extends ImagePickerPlatform {
  ImageSource? origemPedida;
  bool falhar = false;

  @override
  Future<XFile?> getImageFromSource({
    required ImageSource source,
    ImagePickerOptions options = const ImagePickerOptions(),
  }) async {
    origemPedida = source;
    if (falhar) throw Exception('câmera ocupada');
    return XFile.fromData(_png, name: 'poster.png');
  }
}

void main() {
  late _PickerFalso picker;
  late ImagePickerPlatform original;

  setUp(() {
    original = ImagePickerPlatform.instance;
    picker = _PickerFalso();
    ImagePickerPlatform.instance = picker;
  });

  tearDown(() => ImagePickerPlatform.instance = original);

  Future<void> abrirMenuDoPoster(WidgetTester tester) async {
    usarTelaGrande(tester);
    await abrirTela(tester, FilmeService.emMemoria(), const FilmeFormPage());
    await tester.tap(find.text('Escolher imagem'));
    await tester.pumpAndSettle();
  }

  testWidgets('o menu oferece galeria e câmera', (tester) async {
    await abrirMenuDoPoster(tester);

    expect(find.text('Escolher da galeria'), findsOneWidget);
    expect(find.text('Tirar foto'), findsOneWidget);
  });

  testWidgets('tirar foto usa a câmera e mostra o pôster', (tester) async {
    await abrirMenuDoPoster(tester);

    await tester.tap(find.text('Tirar foto'));
    await tester.pumpAndSettle();

    expect(picker.origemPedida, ImageSource.camera);
    expect(find.text('Trocar imagem'), findsOneWidget);
    expect(find.text('Remover'), findsOneWidget);
  });

  testWidgets('escolher da galeria usa a galeria', (tester) async {
    await abrirMenuDoPoster(tester);

    await tester.tap(find.text('Escolher da galeria'));
    await tester.pumpAndSettle();

    expect(picker.origemPedida, ImageSource.gallery);
    expect(find.text('Trocar imagem'), findsOneWidget);
  });

  testWidgets('fechar o menu não abre nada', (tester) async {
    await abrirMenuDoPoster(tester);

    // Toca fora do menu, na parte escurecida da tela.
    await tester.tapAt(const Offset(10, 10));
    await tester.pumpAndSettle();

    expect(picker.origemPedida, isNull);
    expect(find.text('Escolher imagem'), findsOneWidget);
  });

  testWidgets('erro na câmera avisa e mantém sem pôster', (tester) async {
    picker.falhar = true;
    await abrirMenuDoPoster(tester);

    await tester.tap(find.text('Tirar foto'));
    await tester.pumpAndSettle();

    expect(find.text('Não foi possível abrir a câmera.'), findsOneWidget);
    expect(find.text('Escolher imagem'), findsOneWidget);
  });
}

import 'package:home_widget/home_widget.dart';
import 'package:pinyinapp/core/error/exceptions.dart';
import 'package:pinyinapp/features/home_screen_widget/data/datasources/home_screen_widget_data_source.dart';

// As constantes abaixo são duplicadas em `ios/PinyinWidget/PinyinWidget.swift`,
// nos `.entitlements` e em `android/app/src/main/kotlin/com/joao/pinyinapp/
// PinyinWidgetProvider.kt`; mudar uma exige mudar as outras.
class HomeWidgetPluginDataSource implements HomeScreenWidgetDataSource {
  static const String appGroupId = 'group.com.joao.pinyinapp';

  static const String iOSWidgetName = 'PinyinWidget';

  static const String androidWidgetName =
      'com.joao.pinyinapp.PinyinWidgetProvider';

  static const String wordIdKey = 'word_id';
  static const String simplifiedKey = 'word_simplified';
  static const String pinyinKey = 'word_pinyin';

  // Extrai o id de `pinyinapp://word/<id>?homeWidget`, a URL que o widget abre.
  static String? wordIdFromUri(Uri? uri) {
    if (uri == null || uri.host != 'word') return null;
    final segments = uri.pathSegments;
    if (segments.length != 1 || segments.single.isEmpty) return null;
    return segments.single;
  }

  late final Future<void> _appGroupReady = HomeWidget.setAppGroupId(appGroupId);

  @override
  Future<void> saveWord({
    required String id,
    required String simplified,
    required String pinyin,
  }) async {
    try {
      await _appGroupReady;
      await HomeWidget.saveWidgetData<String>(wordIdKey, id);
      await HomeWidget.saveWidgetData<String>(simplifiedKey, simplified);
      await HomeWidget.saveWidgetData<String>(pinyinKey, pinyin);
      await HomeWidget.updateWidget(
        iOSName: iOSWidgetName,
        qualifiedAndroidName: androidWidgetName,
      );
    } on Object catch (error) {
      throw HomeScreenWidgetException(
        'Falha ao gravar a palavra $id no widget.',
        cause: error,
      );
    }
  }

  @override
  Future<bool> hasInstalledWidget() async {
    try {
      final widgets = await HomeWidget.getInstalledWidgets();
      // No Android o plugin devolve o nome curto (`.PinyinWidgetProvider`).
      final androidSimpleName = androidWidgetName.split('.').last;
      return widgets.any(
        (widget) =>
            widget.iOSKind == iOSWidgetName ||
            (widget.androidClassName?.endsWith('.$androidSimpleName') ?? false),
      );
    } on Object catch (error) {
      throw HomeScreenWidgetException(
        'Falha ao listar os widgets instalados.',
        cause: error,
      );
    }
  }

  @override
  Future<bool> canRequestPin() async {
    try {
      return await HomeWidget.isRequestPinWidgetSupported() ?? false;
    } on Object catch (error) {
      throw HomeScreenWidgetException(
        'Falha ao consultar se o launcher fixa widgets.',
        cause: error,
      );
    }
  }

  // O launcher mostra o próprio diálogo de confirmação; o plugin não informa
  // se o usuário aceitou.
  @override
  Future<void> requestPin() async {
    try {
      await HomeWidget.requestPinWidget(qualifiedAndroidName: androidWidgetName);
    } on Object catch (error) {
      throw HomeScreenWidgetException(
        'Falha ao pedir a fixação do widget.',
        cause: error,
      );
    }
  }

  @override
  Future<String?> launchedWordId() async {
    try {
      return wordIdFromUri(await HomeWidget.initiallyLaunchedFromHomeWidget());
    } on Object catch (error) {
      throw HomeScreenWidgetException(
        'Falha ao ler a URL que abriu o app.',
        cause: error,
      );
    }
  }

  @override
  Stream<String> watchTappedWordIds() => HomeWidget.widgetClicked
      .map(wordIdFromUri)
      .where((id) => id != null)
      .cast<String>();
}

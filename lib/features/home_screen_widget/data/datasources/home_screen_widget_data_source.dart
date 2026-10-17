abstract interface class HomeScreenWidgetDataSource {
  Future<void> saveWord({
    required String id,
    required String simplified,
    required String pinyin,
  });

  Future<bool> hasInstalledWidget();

  Future<String?> launchedWordId();

  Stream<String> watchTappedWordIds();
}

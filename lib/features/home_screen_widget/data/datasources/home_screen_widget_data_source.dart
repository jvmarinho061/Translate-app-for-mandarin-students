abstract interface class HomeScreenWidgetDataSource {
  Future<void> saveWord({
    required String id,
    required String simplified,
    required String pinyin,
  });

  Future<bool> hasInstalledWidget();

  Future<bool> canRequestPin();

  Future<void> requestPin();

  Future<String?> launchedWordId();

  Stream<String> watchTappedWordIds();
}

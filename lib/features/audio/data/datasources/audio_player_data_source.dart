abstract interface class AudioPlayerDataSource {
  Future<void> play(Uri uri);

  Future<void> stop();
}

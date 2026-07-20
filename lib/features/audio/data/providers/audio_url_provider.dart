
abstract interface class AudioUrlProvider {
  String get id;
  Uri buildUri(String term);
  bool get requiresCleartextHttp;
}

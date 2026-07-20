import 'package:pinyinapp/core/config/api_config.dart';
import 'package:pinyinapp/features/audio/data/providers/audio_url_provider.dart';

class YoudaoAudioUrlProvider implements AudioUrlProvider {
  const YoudaoAudioUrlProvider();

  static const String providerId = 'youdao';

  @override
  String get id => providerId;

  @override
  bool get requiresCleartextHttp => true;

  @override
  Uri buildUri(String term) {

    return Uri.http(
      ApiEndpoints.youdaoAudioHost,
      ApiEndpoints.youdaoAudioPath,
      <String, String>{'type': '1', 'audio': term},
    );
  }
}

import 'package:flutter_test/flutter_test.dart';
import 'package:pinyinapp/features/audio/data/providers/youdao/youdao_audio_url_provider.dart';

void main() {
  const provider = YoudaoAudioUrlProvider();

  test('faz percent-encoding do hanzi na query string', () {
    final uri = provider.buildUri('你好');

    expect(uri.host, 'dict.youdao.com');
    expect(uri.path, '/dictvoice');
    expect(uri.queryParameters['audio'], '你好');
    expect(uri.toString(), contains('%E4%BD%A0%E5%A5%BD'));
  });

  test('mantém type=1', () {
    expect(provider.buildUri('好').queryParameters['type'], '1');
  });

  test('declara que exige cleartext HTTP', () {
    expect(provider.buildUri('好').scheme, 'http');
    expect(provider.requiresCleartextHttp, isTrue);
  });
}

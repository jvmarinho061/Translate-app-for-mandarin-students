class BaiduCredentials {
  const BaiduCredentials({required this.appId, required this.appKey});

  factory BaiduCredentials.fromEnvironment() => const BaiduCredentials(
        appId: String.fromEnvironment('BAIDU_APP_ID'),
        appKey: String.fromEnvironment('BAIDU_APP_KEY'),
      );

  final String appId;
  final String appKey;

  bool get isConfigured => appId.isNotEmpty && appKey.isNotEmpty;
}


abstract final class ApiEndpoints {
  static const String baiduTranslateBaseUrl = 'https://fanyi-api.baidu.com';
  static const String baiduTranslatePath = '/api/trans/vip/translate';
  static const String youdaoAudioHost = 'dict.youdao.com';
  static const String youdaoAudioPath = '/dictvoice';
}

class GoogleTranslateCredentials {
  const GoogleTranslateCredentials({required this.apiKey});

  factory GoogleTranslateCredentials.fromEnvironment() =>
      const GoogleTranslateCredentials(
        apiKey: String.fromEnvironment('GOOGLE_TRANSLATE_API_KEY'),
      );

  final String apiKey;

  bool get isConfigured => apiKey.isNotEmpty;
}


abstract final class ApiEndpoints {
  static const String googleTranslateBaseUrl =
      'https://translation.googleapis.com';
  static const String googleTranslatePath = '/language/translate/v2';
  static const String youdaoAudioHost = 'dict.youdao.com';
  static const String youdaoAudioPath = '/dictvoice';
}

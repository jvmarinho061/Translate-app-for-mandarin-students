class GoogleTranslateCredentials {
  const GoogleTranslateCredentials({required this.apiKey});

  factory GoogleTranslateCredentials.fromEnvironment() =>
      const GoogleTranslateCredentials(
        apiKey: String.fromEnvironment('GOOGLE_TRANSLATE_API_KEY'),
      );

  final String apiKey;

  bool get isConfigured => apiKey.isNotEmpty;
}

/// Identidade que a restrição de app Android da API key exige. O Dio não envia
/// esses headers sozinho — só as bibliotecas oficiais do Google fazem isso —,
/// então sem eles o Google vê o pacote como `<empty>` e bloqueia a requisição.
class GoogleAndroidClient {
  const GoogleAndroidClient({
    required this.packageName,
    required this.certSha1,
  });

  // SHA-1 do keystore de debug (o mesmo que assina o release hoje). Ao criar um
  // keystore de release próprio o valor muda: sobrescreva por --dart-define em
  // vez de editar aqui. Não é segredo — é derivável de qualquer APK.
  static const String _debugSha1 =
      '83:72:14:DA:37:D6:0D:F2:27:46:03:CA:CF:97:9D:17:36:D3:07:26';

  factory GoogleAndroidClient.fromEnvironment() => const GoogleAndroidClient(
        packageName: String.fromEnvironment(
          'GOOGLE_ANDROID_PACKAGE',
          defaultValue: 'com.joao.pinyinapp',
        ),
        certSha1: String.fromEnvironment(
          'GOOGLE_ANDROID_CERT_SHA1',
          defaultValue: _debugSha1,
        ),
      );

  final String packageName;
  final String certSha1;

  /// O Google espera o SHA-1 em hex maiúsculo e sem separadores; normalizar
  /// aqui deixa o valor tolerante ao formato que o `keytool` imprime.
  Map<String, String> get headers => {
        'X-Android-Package': packageName,
        'X-Android-Cert':
            certSha1.replaceAll(':', '').replaceAll('-', '').toUpperCase(),
      };
}


abstract final class ApiEndpoints {
  static const String googleTranslateBaseUrl =
      'https://translation.googleapis.com';
  static const String googleTranslatePath = '/language/translate/v2';
  static const String youdaoAudioHost = 'dict.youdao.com';
  static const String youdaoAudioPath = '/dictvoice';
}

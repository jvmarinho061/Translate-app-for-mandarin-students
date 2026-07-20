/// Credenciais e endpoints injetados em build-time.
///
/// **Nunca** versione chaves reais. Os valores chegam por `--dart-define`:
///
/// ```sh
/// flutter run --dart-define=BAIDU_APP_ID=xxx --dart-define=BAIDU_APP_KEY=yyy
/// ```
///
/// Lembrete arquitetural: na topologia atual (cliente falando direto com a
/// Baidu) estas chaves **são extraíveis do binário**. Isso é uma limitação
/// aceita conscientemente, mitigada por cota restrita e rotação — não uma
/// solução. Ela desaparece quando o BFF entrar.
class BaiduCredentials {
  const BaiduCredentials({required this.appId, required this.appKey});

  /// Lê as credenciais do ambiente de compilação.
  factory BaiduCredentials.fromEnvironment() => const BaiduCredentials(
        appId: String.fromEnvironment('BAIDU_APP_ID'),
        appKey: String.fromEnvironment('BAIDU_APP_KEY'),
      );

  final String appId;
  final String appKey;

  /// Permite falhar cedo, com mensagem clara, em vez de receber um
  /// `52003 UNAUTHORIZED USER` opaco do servidor.
  bool get isConfigured => appId.isNotEmpty && appKey.isNotEmpty;
}

/// Endpoints externos. Centralizados para que a migração ao BFF seja a troca
/// de um valor, e não uma caçada por strings espalhadas.
abstract final class ApiEndpoints {
  /// A API de tradução da Baidu está disponível sobre HTTPS.
  static const String baiduTranslateBaseUrl = 'https://fanyi-api.baidu.com';
  static const String baiduTranslatePath = '/api/trans/vip/translate';

  /// ATENÇÃO: o endpoint de áudio do Youdao é **HTTP puro**.
  /// Exige `networkSecurityConfig` (Android) e exceção ATS (iOS), e é
  /// inutilizável na Web por *mixed content*.
  static const String youdaoAudioHost = 'dict.youdao.com';
  static const String youdaoAudioPath = '/dictvoice';
}

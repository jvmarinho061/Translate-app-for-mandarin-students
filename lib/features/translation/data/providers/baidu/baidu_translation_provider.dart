import 'package:dio/dio.dart';
import 'package:pinyinapp/core/config/api_config.dart';
import 'package:pinyinapp/core/error/exceptions.dart';
import 'package:pinyinapp/features/translation/data/dtos/translation_dto.dart';
import 'package:pinyinapp/features/translation/data/providers/baidu/baidu_error_mapper.dart';
import 'package:pinyinapp/features/translation/data/providers/baidu/baidu_language_codec.dart';
import 'package:pinyinapp/features/translation/data/providers/baidu/baidu_signature.dart';
import 'package:pinyinapp/features/translation/data/providers/translation_provider.dart';
import 'package:pinyinapp/features/translation/domain/entities/language.dart';

class BaiduTranslationProvider implements TranslationProvider {
  const BaiduTranslationProvider({
    required this.dio,
    required this.credentials,
    this.codec = const BaiduLanguageCodec(),
    this.signature = const BaiduSignature(),
    this.errorMapper = const BaiduErrorMapper(),
  });

  static const String providerId = 'baidu';

  final Dio dio;
  final BaiduCredentials credentials;
  final BaiduLanguageCodec codec;
  final BaiduSignature signature;
  final BaiduErrorMapper errorMapper;

  @override
  String get id => providerId;

  @override
  bool supports({required Language from, required Language to}) =>
      codec.supports(from) && codec.supports(to);

  @override
  Future<TranslationDto> translate({
    required String text,
    required Language from,
    required Language to,
  }) async {
    if (!credentials.isConfigured) {
      throw const ApiAuthException(
        'Credenciais Baidu ausentes. Informe BAIDU_APP_ID e BAIDU_APP_KEY '
        'via --dart-define.',
      );
    }

    final salt = signature.generateSalt();
    final response = await _send(
      queryParameters: {
        'q': text,
        'from': codec.encode(from),
        'to': codec.encode(to),
        'appid': credentials.appId,
        'salt': salt,
        'sign': signature.compute(
          appId: credentials.appId,
          query: text,
          salt: salt,
          appKey: credentials.appKey,
        ),
      },
    );

    return _parse(response, sourceText: text, from: from, to: to);
  }

  Future<Map<String, Object?>> _send({
    required Map<String, String> queryParameters,
  }) async {
    try {
      final response = await dio.get<Object?>(
        ApiEndpoints.baiduTranslatePath,
        queryParameters: queryParameters,
      );
      final data = response.data;
      if (data is! Map) {
        throw const ApiContractException(
          'Resposta da Baidu não é um objeto JSON.',
        );
      }
      return data.cast<String, Object?>();
    } on DioException catch (error) {
      throw NetworkException(
        error.message ?? 'Falha de rede ao contatar a Baidu.',
        cause: error,
      );
    }
  }

  TranslationDto _parse(
    Map<String, Object?> json, {
    required String sourceText,
    required Language from,
    required Language to,
  }) {
    // A Baidu sinaliza erro com HTTP 200 e `error_code` no corpo.
    final errorCode = json['error_code'];
    if (errorCode != null && errorCode.toString() != '52000') {
      throw errorMapper.map(errorCode.toString(), json['error_msg']?.toString());
    }

    final results = json['trans_result'];
    if (results is! List || results.isEmpty) {
      throw const ApiContractException('Resposta da Baidu sem `trans_result`.');
    }

    // Texto multilinha volta como um item por linha.
    final translated = results
        .whereType<Map<Object?, Object?>>()
        .map((item) => item['dst']?.toString() ?? '')
        .join('\n');

    if (translated.isEmpty) {
      throw const ApiContractException('Baidu devolveu tradução vazia.');
    }

    return TranslationDto(
      sourceText: sourceText,
      translatedText: translated,
      fromIsoCode: from.isoCode,
      toIsoCode: to.isoCode,
      providerId: providerId,
    );
  }
}

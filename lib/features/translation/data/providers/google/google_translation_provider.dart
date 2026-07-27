import 'package:dio/dio.dart';
import 'package:pinyinapp/core/config/api_config.dart';
import 'package:pinyinapp/core/error/exceptions.dart';
import 'package:pinyinapp/features/translation/data/dtos/translation_dto.dart';
import 'package:pinyinapp/features/translation/data/providers/google/google_error_mapper.dart';
import 'package:pinyinapp/features/translation/data/providers/google/google_language_codec.dart';
import 'package:pinyinapp/features/translation/data/providers/translation_provider.dart';
import 'package:pinyinapp/features/translation/domain/entities/language.dart';

class GoogleTranslationProvider implements TranslationProvider {
  const GoogleTranslationProvider({
    required this.dio,
    required this.credentials,
    this.codec = const GoogleLanguageCodec(),
    this.errorMapper = const GoogleErrorMapper(),
  });

  static const String providerId = 'google';

  final Dio dio;
  final GoogleTranslateCredentials credentials;
  final GoogleLanguageCodec codec;
  final GoogleErrorMapper errorMapper;

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
        'Credencial Google ausente. Informe GOOGLE_TRANSLATE_API_KEY '
        'via --dart-define.',
      );
    }

    final response = await _send(
      body: {
        'q': text,
        'source': codec.encode(from),
        'target': codec.encode(to),
        'format': 'text',
      },
    );

    return _parse(response, sourceText: text, from: from, to: to);
  }

  Future<Map<String, Object?>> _send({
    required Map<String, String> body,
  }) async {
    try {
      final response = await dio.post<Object?>(
        ApiEndpoints.googleTranslatePath,
        queryParameters: {'key': credentials.apiKey},
        data: body,
      );
      final data = response.data;
      if (data is! Map) {
        throw const ApiContractException(
          'Resposta do Google não é um objeto JSON.',
        );
      }
      return data.cast<String, Object?>();
    } on DioException catch (error) {
      final response = error.response;
      if (response == null) {
        throw NetworkException(
          error.message ?? 'Falha de rede ao contatar o Google.',
          cause: error,
        );
      }
      throw _mapErrorResponse(response);
    }
  }

  AppException _mapErrorResponse(Response<Object?> response) {
    final body = response.data;
    final error = body is Map ? body['error'] : null;
    final status = error is Map ? error['status']?.toString() : null;
    final message = error is Map ? error['message']?.toString() : null;
    return errorMapper.map(
      httpStatus: response.statusCode,
      status: status,
      message: message,
    );
  }

  TranslationDto _parse(
    Map<String, Object?> json, {
    required String sourceText,
    required Language from,
    required Language to,
  }) {
    final data = json['data'];
    final translations = data is Map ? data['translations'] : null;
    if (translations is! List || translations.isEmpty) {
      throw const ApiContractException(
        'Resposta do Google sem `data.translations`.',
      );
    }

    final first = translations.first;
    final translated =
        first is Map ? first['translatedText']?.toString() ?? '' : '';

    if (translated.isEmpty) {
      throw const ApiContractException('Google devolveu tradução vazia.');
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

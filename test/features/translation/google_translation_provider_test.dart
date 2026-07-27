import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pinyinapp/core/config/api_config.dart';
import 'package:pinyinapp/core/error/exceptions.dart';
import 'package:pinyinapp/features/translation/data/providers/google/google_translation_provider.dart';
import 'package:pinyinapp/features/translation/domain/entities/language.dart';

class MockDio extends Mock implements Dio {}

void main() {
  late MockDio dio;

  const credentials = GoogleTranslateCredentials(apiKey: 'chave-de-teste');
  final requestOptions =
      RequestOptions(path: ApiEndpoints.googleTranslatePath);

  setUp(() => dio = MockDio());

  GoogleTranslationProvider build({
    GoogleTranslateCredentials creds = credentials,
  }) =>
      GoogleTranslationProvider(dio: dio, credentials: creds);

  Future<Object?> translate(GoogleTranslationProvider provider) =>
      provider.translate(
        text: '你好',
        from: Language.chinese,
        to: Language.portuguese,
      );

  void stubPost(Object? body) {
    when(
      () => dio.post<Object?>(
        any(),
        queryParameters: any(named: 'queryParameters'),
        data: any(named: 'data'),
      ),
    ).thenAnswer(
      (_) async => Response<Object?>(
        data: body,
        statusCode: 200,
        requestOptions: requestOptions,
      ),
    );
  }

  void stubPostError({int? statusCode, Object? body}) {
    when(
      () => dio.post<Object?>(
        any(),
        queryParameters: any(named: 'queryParameters'),
        data: any(named: 'data'),
      ),
    ).thenThrow(
      DioException(
        requestOptions: requestOptions,
        type: statusCode == null
            ? DioExceptionType.connectionTimeout
            : DioExceptionType.badResponse,
        response: statusCode == null
            ? null
            : Response<Object?>(
                data: body,
                statusCode: statusCode,
                requestOptions: requestOptions,
              ),
      ),
    );
  }

  test('sucesso: parseia translatedText da resposta', () async {
    stubPost({
      'data': {
        'translations': [
          {'translatedText': 'Olá', 'detectedSourceLanguage': 'zh'},
        ],
      },
    });

    final dto = await build().translate(
      text: '你好',
      from: Language.chinese,
      to: Language.portuguese,
    );

    expect(dto.translatedText, 'Olá');
    expect(dto.providerId, 'google');
    expect(dto.fromIsoCode, 'zh');
    expect(dto.toIsoCode, 'pt');
  });

  test('credencial ausente lança ApiAuthException sem tocar a rede', () async {
    final provider =
        build(creds: const GoogleTranslateCredentials(apiKey: ''));

    await expectLater(translate(provider), throwsA(isA<ApiAuthException>()));
    verifyZeroInteractions(dio);
  });

  test('HTTP 403 (PERMISSION_DENIED) vira ApiAuthException', () async {
    stubPostError(
      statusCode: 403,
      body: {
        'error': {
          'code': 403,
          'message': 'The request is missing a valid API key.',
          'status': 'PERMISSION_DENIED',
        },
      },
    );

    await expectLater(translate(build()), throwsA(isA<ApiAuthException>()));
  });

  test('HTTP 429 (RESOURCE_EXHAUSTED) vira ApiQuotaException', () async {
    stubPostError(
      statusCode: 429,
      body: {
        'error': {
          'code': 429,
          'message': 'Quota exceeded.',
          'status': 'RESOURCE_EXHAUSTED',
        },
      },
    );

    await expectLater(translate(build()), throwsA(isA<ApiQuotaException>()));
  });

  test('DioException sem response (timeout) vira NetworkException', () async {
    stubPostError();

    await expectLater(translate(build()), throwsA(isA<NetworkException>()));
  });
}

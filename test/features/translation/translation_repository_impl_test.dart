import 'package:flutter_test/flutter_test.dart';
import 'package:pinyinapp/core/error/exceptions.dart';
import 'package:pinyinapp/core/error/failure.dart';
import 'package:pinyinapp/core/result/result.dart';
import 'package:pinyinapp/features/translation/data/datasources/translation_cache_data_source.dart';
import 'package:pinyinapp/features/translation/data/dtos/translation_dto.dart';
import 'package:pinyinapp/features/translation/data/providers/translation_provider.dart';
import 'package:pinyinapp/features/translation/data/repositories/translation_repository_impl.dart';
import 'package:pinyinapp/features/translation/domain/entities/language.dart';

/// Fornecedor fictício. A existência deste arquivo, sem nenhum import de Baidu
/// ou Dio, é a prova de que a regra de negócio não conhece o fornecedor.
class FakeProvider implements TranslationProvider {
  FakeProvider({this.answer = 'Olá', this.error});

  final String answer;
  final Object? error;
  int calls = 0;

  @override
  String get id => 'fake';

  @override
  bool supports({required Language from, required Language to}) => true;

  @override
  Future<TranslationDto> translate({
    required String text,
    required Language from,
    required Language to,
  }) async {
    calls++;
    if (error != null) throw error!;
    return TranslationDto(
      sourceText: text,
      translatedText: answer,
      fromIsoCode: from.isoCode,
      toIsoCode: to.isoCode,
      providerId: id,
    );
  }
}

void main() {
  late InMemoryTranslationCacheDataSource cache;

  setUp(() => cache = InMemoryTranslationCacheDataSource());

  TranslationRepositoryImpl build(TranslationProvider provider) =>
      TranslationRepositoryImpl(provider: provider, cache: cache);

  test('traduz e devolve entidade de domínio', () async {
    final result = await build(FakeProvider()).translate(
      text: '你好',
      from: Language.chinese,
      to: Language.portuguese,
    );

    expect(result, isA<Success>());
    expect(result.valueOrNull?.translatedText, 'Olá');
    expect(result.valueOrNull?.isStale, isFalse);
  });

  test('segunda chamada é servida do cache, sem tocar o fornecedor', () async {
    final provider = FakeProvider();
    final repository = build(provider);

    await repository.translate(
      text: '你好',
      from: Language.chinese,
      to: Language.portuguese,
    );
    await repository.translate(
      text: '你好',
      from: Language.chinese,
      to: Language.portuguese,
    );

    expect(provider.calls, 1);
  });

  test('sem rede, devolve cache expirado marcado como isStale', () async {
    await build(FakeProvider()).translate(
      text: '你好',
      from: Language.chinese,
      to: Language.portuguese,
    );

    final offline = TranslationRepositoryImpl(
      provider: FakeProvider(error: const NetworkException('sem rede')),
      cache: cache,
      ttl: Duration.zero, // força o cache a estar vencido
    );

    final result = await offline.translate(
      text: '你好',
      from: Language.chinese,
      to: Language.portuguese,
    );

    expect(result.valueOrNull?.translatedText, 'Olá');
    expect(result.valueOrNull?.isStale, isTrue);
  });

  test('sem rede e sem cache, falha como OfflineFailure', () async {
    final result = await build(
      FakeProvider(error: const NetworkException('sem rede')),
    ).translate(
      text: '陌生',
      from: Language.chinese,
      to: Language.portuguese,
    );

    expect(result.failureOrNull, isA<OfflineFailure>());
  });

  test('erro de cota do fornecedor vira ApiQuotaFailure', () async {
    final result = await build(
      FakeProvider(error: const ApiQuotaException('limite')),
    ).translate(
      text: '你好',
      from: Language.chinese,
      to: Language.portuguese,
    );

    expect(result.failureOrNull, isA<ApiQuotaFailure>());
  });
}

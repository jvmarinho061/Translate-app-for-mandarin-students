import 'package:pinyinapp/core/error/exceptions.dart';
import 'package:pinyinapp/core/error/failure.dart';
import 'package:pinyinapp/core/result/result.dart';
import 'package:pinyinapp/features/translation/data/datasources/translation_cache_data_source.dart';
import 'package:pinyinapp/features/translation/data/dtos/translation_dto.dart';
import 'package:pinyinapp/features/translation/data/mappers/translation_mapper.dart';
import 'package:pinyinapp/features/translation/data/providers/translation_provider.dart';
import 'package:pinyinapp/features/translation/domain/entities/language.dart';
import 'package:pinyinapp/features/translation/domain/entities/translation.dart';
import 'package:pinyinapp/features/translation/domain/repositories/translation_repository.dart';

class TranslationRepositoryImpl implements TranslationRepository {
  const TranslationRepositoryImpl({
    required this.provider,
    required this.cache,
    this.ttl = const Duration(days: 30),
    this.mapper = const TranslationMapper(),
  });

  final TranslationProvider provider;
  final TranslationCacheDataSource cache;
  final TranslationMapper mapper;
  final Duration ttl;

  @override
  Future<Result<Translation>> translate({
    required String text,
    required Language from,
    required Language to,
  }) async {
    if (!provider.supports(from: from, to: to)) {
      return const FailureResult(
        ValidationFailure(reason: 'Par de idiomas não suportado.'),
      );
    }

    final key = TranslationCacheKey(
      text: text,
      fromIsoCode: from.isoCode,
      toIsoCode: to.isoCode,
    );

    final cached = await _readCache(key);
    if (cached != null && _isFresh(cached)) {
      return Success(mapper.toEntity(cached.dto, retrievedAt: cached.storedAt));
    }

    try {
      final dto = await provider.translate(text: text, from: from, to: to);
      await _writeCache(key, dto);
      return Success(mapper.toEntity(dto, retrievedAt: DateTime.now()));
    } on NetworkException catch (error) {
      // Sem rede: dado expirado é melhor que erro, desde que marcado isStale.
      if (cached != null) {
        return Success(
          mapper.toEntity(
            cached.dto,
            retrievedAt: cached.storedAt,
            isStale: true,
          ),
        );
      }
      return FailureResult(OfflineFailure(debugMessage: error.message));
    } on AppException catch (error) {
      return FailureResult(_toFailure(error));
    } on Object catch (error) {
      return FailureResult(UnexpectedFailure(debugMessage: error.toString()));
    }
  }

  bool _isFresh(CachedTranslation cached) =>
      DateTime.now().difference(cached.storedAt) < ttl;

  // Falha de cache não derruba a tradução: seguimos para a rede.
  Future<CachedTranslation?> _readCache(TranslationCacheKey key) async {
    try {
      return await cache.read(key);
    } on Object {
      return null;
    }
  }

  Future<void> _writeCache(TranslationCacheKey key, TranslationDto dto) async {
    try {
      await cache.write(key, dto);
    } on Object {
      // Não conseguir cachear não invalida um resultado já obtido.
    }
  }

  Failure _toFailure(AppException error) => switch (error) {
        ApiAuthException() => ApiAuthFailure(debugMessage: error.message),
        ApiQuotaException() => ApiQuotaFailure(debugMessage: error.message),
        ApiContractException() =>
          ApiContractFailure(debugMessage: error.message),
        NetworkException() => NetworkFailure(debugMessage: error.message),
        _ => UnexpectedFailure(debugMessage: error.message),
      };
}

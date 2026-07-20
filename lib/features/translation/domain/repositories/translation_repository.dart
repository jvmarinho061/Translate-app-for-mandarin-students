import 'package:pinyinapp/core/result/result.dart';
import 'package:pinyinapp/features/translation/domain/entities/language.dart';
import 'package:pinyinapp/features/translation/domain/entities/translation.dart';

/// Contrato de tradução, do ponto de vista da regra de negócio.
///
/// Repare no que **não** está aqui: cache, TTL, HTTP, chave de API, fornecedor.
/// Tudo isso é decisão da implementação. Quem chama só sabe que pediu uma
/// tradução e recebeu um [Result].
abstract interface class TranslationRepository {
  Future<Result<Translation>> translate({
    required String text,
    required Language from,
    required Language to,
  });
}

import 'package:equatable/equatable.dart';
import 'package:pinyinapp/features/translation/domain/entities/language.dart';

/// Resultado de uma tradução.
class Translation extends Equatable {
  const Translation({
    required this.sourceText,
    required this.translatedText,
    required this.from,
    required this.to,
    required this.retrievedAt,
    this.isStale = false,
  });

  final String sourceText;
  final String translatedText;
  final Language from;
  final Language to;

  /// Quando o dado foi obtido do fornecedor (não quando foi lido do cache).
  final DateTime retrievedAt;

  /// `true` quando servimos um valor de cache já expirado por não haver rede.
  ///
  /// É informação de **domínio**, não de infraestrutura: significa "este dado
  /// pode estar desatualizado", e a UI tem obrigação de sinalizá-lo. Nunca
  /// apresentar dado velho como se fosse fresco.
  final bool isStale;

  Translation copyWith({bool? isStale}) => Translation(
        sourceText: sourceText,
        translatedText: translatedText,
        from: from,
        to: to,
        retrievedAt: retrievedAt,
        isStale: isStale ?? this.isStale,
      );

  @override
  List<Object?> get props =>
      [sourceText, translatedText, from, to, retrievedAt, isStale];
}

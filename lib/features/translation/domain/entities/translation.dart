import 'package:equatable/equatable.dart';
import 'package:pinyinapp/features/translation/domain/entities/language.dart';

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

  final DateTime retrievedAt;
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

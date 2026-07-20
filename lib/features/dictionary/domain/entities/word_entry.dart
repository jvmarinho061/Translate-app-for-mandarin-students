import 'package:equatable/equatable.dart';
import 'package:pinyinapp/features/dictionary/domain/entities/definition.dart';
import 'package:pinyinapp/features/dictionary/domain/entities/pinyin.dart';

/// Entrada do dicionário — a entidade central do app.
class WordEntry extends Equatable {
  const WordEntry({
    required this.id,
    required this.simplified,
    required this.pinyin,
    required this.definitions,
    this.traditional,
    this.hskLevel,
  });

  final String id;

  final String simplified;

  final String? traditional;

  final Pinyin pinyin;
  final List<Definition> definitions;

  final int? hskLevel;

  String get pronounceableTerm => simplified;

  @override
  List<Object?> get props =>
      [id, simplified, traditional, pinyin, definitions, hskLevel];
}

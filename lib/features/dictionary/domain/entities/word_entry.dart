import 'package:equatable/equatable.dart';
import 'package:pinyinapp/features/dictionary/domain/entities/definition.dart';
import 'package:pinyinapp/features/dictionary/domain/entities/pinyin.dart';

class WordEntry extends Equatable {
  const WordEntry({
    required this.id,
    required this.simplified,
    required this.pinyin,
    required this.definitions,
    this.hskLevel,
  });

  final String id;
  final String simplified;
  final Pinyin pinyin;
  final List<Definition> definitions;
  final int? hskLevel;

  String get pronounceableTerm => simplified;

  @override
  List<Object?> get props => [id, simplified, pinyin, definitions, hskLevel];
}

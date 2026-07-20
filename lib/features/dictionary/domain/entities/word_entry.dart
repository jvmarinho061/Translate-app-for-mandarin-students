import 'package:equatable/equatable.dart';
import 'package:pinyinapp/features/dictionary/domain/entities/definition.dart';
import 'package:pinyinapp/features/dictionary/domain/entities/pinyin.dart';

/// Entrada do dicionário — a entidade central do app.
///
/// Note que ela **já carrega pinyin e definições**. É por isso que não existe
/// um caso de uso "obter pinyin" separado para palavras conhecidas: seria uma
/// segunda consulta para um dado que já está em mãos.
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

  /// Ausente quando simplificado e tradicional coincidem.
  final String? traditional;

  final Pinyin pinyin;
  final List<Definition> definitions;

  /// Reservado para a evolução HSK. Nulo enquanto o dado não for importado.
  final int? hskLevel;

  /// Termo usado para requisitar a pronúncia.
  String get pronounceableTerm => simplified;

  @override
  List<Object?> get props =>
      [id, simplified, traditional, pinyin, definitions, hskLevel];
}

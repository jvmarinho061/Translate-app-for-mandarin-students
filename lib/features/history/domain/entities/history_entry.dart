import 'package:equatable/equatable.dart';
import 'package:pinyinapp/features/dictionary/domain/entities/word_entry.dart';

class HistoryEntry extends Equatable {
  const HistoryEntry({
    required this.word,
    required this.lastVisitedAt,
    required this.visitCount,
  });

  final WordEntry word;
  final DateTime lastVisitedAt;
  final int visitCount;

  @override
  List<Object?> get props => [word, lastVisitedAt, visitCount];
}

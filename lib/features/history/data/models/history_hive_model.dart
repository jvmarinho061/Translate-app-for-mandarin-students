import 'package:pinyinapp/shared/data/models/word_snapshot_model.dart';

class HistoryHiveModel {
  const HistoryHiveModel({
    required this.word,
    required this.lastVisitedAt,
    required this.visitCount,
  });

  final WordSnapshotModel word;
  final DateTime lastVisitedAt;
  final int visitCount;

  String get key => word.id;

  Map<String, Object?> toMap() => {
        'word': word.toMap(),
        'lastVisitedAt': lastVisitedAt.millisecondsSinceEpoch,
        'visitCount': visitCount,
      };

  factory HistoryHiveModel.fromMap(Map<dynamic, dynamic> map) =>
      HistoryHiveModel(
        word: WordSnapshotModel.fromMap(map['word']! as Map<dynamic, dynamic>),
        lastVisitedAt:
            DateTime.fromMillisecondsSinceEpoch(map['lastVisitedAt']! as int),
        visitCount: map['visitCount'] as int? ?? 1,
      );
}

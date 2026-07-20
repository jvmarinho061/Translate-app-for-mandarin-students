import 'package:pinyinapp/shared/data/models/word_snapshot_model.dart';

class FavoriteHiveModel {
  const FavoriteHiveModel({required this.word, required this.createdAt});

  final WordSnapshotModel word;
  final DateTime createdAt;

  String get key => word.id;

  Map<String, Object?> toMap() => {
        'word': word.toMap(),
        'createdAt': createdAt.millisecondsSinceEpoch,
      };

  factory FavoriteHiveModel.fromMap(Map<dynamic, dynamic> map) =>
      FavoriteHiveModel(
        word: WordSnapshotModel.fromMap(map['word']! as Map<dynamic, dynamic>),
        createdAt:
            DateTime.fromMillisecondsSinceEpoch(map['createdAt']! as int),
      );
}

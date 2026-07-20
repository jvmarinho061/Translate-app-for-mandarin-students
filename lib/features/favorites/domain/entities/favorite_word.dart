import 'package:equatable/equatable.dart';
import 'package:pinyinapp/features/dictionary/domain/entities/word_entry.dart';

class FavoriteWord extends Equatable {
  const FavoriteWord({required this.word, required this.createdAt});

  final WordEntry word;
  final DateTime createdAt;

  @override
  List<Object?> get props => [word, createdAt];
}

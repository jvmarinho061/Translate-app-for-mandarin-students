import 'package:pinyinapp/core/result/result.dart';
import 'package:pinyinapp/features/dictionary/domain/entities/word_entry.dart';
import 'package:pinyinapp/features/home_screen_widget/domain/entities/home_screen_widget_presence.dart';

abstract interface class HomeScreenWidgetRepository {
  Future<Result<HomeScreenWidgetPresence>> show(WordEntry word);
  Stream<String> watchTappedWordIds();
}

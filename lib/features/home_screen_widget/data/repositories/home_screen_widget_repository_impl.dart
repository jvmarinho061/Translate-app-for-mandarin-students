import 'package:pinyinapp/core/error/exceptions.dart';
import 'package:pinyinapp/core/error/failure.dart';
import 'package:pinyinapp/core/result/result.dart';
import 'package:pinyinapp/features/dictionary/domain/entities/word_entry.dart';
import 'package:pinyinapp/features/home_screen_widget/data/datasources/home_screen_widget_data_source.dart';
import 'package:pinyinapp/features/home_screen_widget/domain/entities/home_screen_widget_presence.dart';
import 'package:pinyinapp/features/home_screen_widget/domain/repositories/home_screen_widget_repository.dart';

class HomeScreenWidgetRepositoryImpl implements HomeScreenWidgetRepository {
  const HomeScreenWidgetRepositoryImpl({required this.dataSource});

  final HomeScreenWidgetDataSource dataSource;

  @override
  Future<Result<HomeScreenWidgetPresence>> show(WordEntry word) async {
    try {
      await dataSource.saveWord(
        id: word.id,
        simplified: word.simplified,
        pinyin: word.pinyin.marked,
      );
      final installed = await dataSource.hasInstalledWidget();
      return Success(
        installed
            ? HomeScreenWidgetPresence.onHomeScreen
            : HomeScreenWidgetPresence.notAdded,
      );
    } on HomeScreenWidgetException catch (error) {
      return FailureResult(HomeScreenWidgetFailure(debugMessage: error.toString()));
    } on Object catch (error) {
      return FailureResult(UnexpectedFailure(debugMessage: error.toString()));
    }
  }

  @override
  Stream<String> watchTappedWordIds() async* {
    try {
      final launched = await dataSource.launchedWordId();
      if (launched != null) yield launched;
    } on Object {
      // Ver comentário do método.
    }
    yield* dataSource.watchTappedWordIds().handleError((Object _) {});
  }
}

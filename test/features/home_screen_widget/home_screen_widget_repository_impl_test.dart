import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pinyinapp/core/error/exceptions.dart';
import 'package:pinyinapp/core/error/failure.dart';
import 'package:pinyinapp/core/result/result.dart';
import 'package:pinyinapp/features/dictionary/domain/entities/pinyin.dart';
import 'package:pinyinapp/features/dictionary/domain/entities/word_entry.dart';
import 'package:pinyinapp/features/home_screen_widget/data/datasources/home_screen_widget_data_source.dart';
import 'package:pinyinapp/features/home_screen_widget/data/repositories/home_screen_widget_repository_impl.dart';
import 'package:pinyinapp/features/home_screen_widget/domain/entities/home_screen_widget_presence.dart';

class MockHomeScreenWidgetDataSource extends Mock
    implements HomeScreenWidgetDataSource {}

void main() {
  late MockHomeScreenWidgetDataSource dataSource;
  late HomeScreenWidgetRepositoryImpl repository;

  const word = WordEntry(
    id: '42',
    simplified: '你好',
    pinyin: Pinyin(marked: 'nǐ hǎo', numbered: 'ni3 hao3', toneless: 'ni hao'),
    definitions: [],
  );

  setUp(() {
    dataSource = MockHomeScreenWidgetDataSource();
    repository = HomeScreenWidgetRepositoryImpl(dataSource: dataSource);
  });

  void stubSave() {
    when(
      () => dataSource.saveWord(
        id: any(named: 'id'),
        simplified: any(named: 'simplified'),
        pinyin: any(named: 'pinyin'),
      ),
    ).thenAnswer((_) async {});
  }

  group('show', () {
    test('grava id, hanzi e pinyin com marcas de tom', () async {
      stubSave();
      when(() => dataSource.hasInstalledWidget()).thenAnswer((_) async => true);

      await repository.show(word);

      verify(
        () => dataSource.saveWord(id: '42', simplified: '你好', pinyin: 'nǐ hǎo'),
      ).called(1);
    });

    test('devolve onHomeScreen quando já há widget instalado', () async {
      stubSave();
      when(() => dataSource.hasInstalledWidget()).thenAnswer((_) async => true);

      final result = await repository.show(word);

      expect(result.valueOrNull, HomeScreenWidgetPresence.onHomeScreen);
    });

    test('devolve notAdded quando nenhum widget foi adicionado', () async {
      stubSave();
      when(() => dataSource.hasInstalledWidget())
          .thenAnswer((_) async => false);

      final result = await repository.show(word);

      expect(result.valueOrNull, HomeScreenWidgetPresence.notAdded);
    });

    test('converte HomeScreenWidgetException em HomeScreenWidgetFailure',
        () async {
      when(
        () => dataSource.saveWord(
          id: any(named: 'id'),
          simplified: any(named: 'simplified'),
          pinyin: any(named: 'pinyin'),
        ),
      ).thenThrow(const HomeScreenWidgetException('App Group indisponível'));

      final result = await repository.show(word);

      expect(result, isA<FailureResult<HomeScreenWidgetPresence>>());
      expect(result.failureOrNull, isA<HomeScreenWidgetFailure>());
      verifyNever(() => dataSource.hasInstalledWidget());
    });
  });

  group('watchTappedWordIds', () {
    test('emite primeiro a palavra que abriu o app, depois os toques',
        () async {
      when(() => dataSource.launchedWordId()).thenAnswer((_) async => '7');
      when(() => dataSource.watchTappedWordIds())
          .thenAnswer((_) => Stream.fromIterable(['8', '9']));

      expect(await repository.watchTappedWordIds().toList(), ['7', '8', '9']);
    });

    test('sem toque na abertura, emite só os toques seguintes', () async {
      when(() => dataSource.launchedWordId()).thenAnswer((_) async => null);
      when(() => dataSource.watchTappedWordIds())
          .thenAnswer((_) => Stream.fromIterable(['8']));

      expect(await repository.watchTappedWordIds().toList(), ['8']);
    });

    test('descarta erros sem encerrar o stream', () async {
      when(() => dataSource.launchedWordId())
          .thenThrow(const HomeScreenWidgetException('canal fechado'));
      when(() => dataSource.watchTappedWordIds()).thenAnswer(
        (_) => Stream<String>.multi((controller) {
          controller
            ..addError(const HomeScreenWidgetException('URL inválida'))
            ..add('8')
            ..close();
        }),
      );

      expect(await repository.watchTappedWordIds().toList(), ['8']);
    });
  });
}

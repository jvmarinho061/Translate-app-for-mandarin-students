import 'package:dio/dio.dart';
import 'package:just_audio/just_audio.dart';
import 'package:pinyinapp/core/config/api_config.dart';
import 'package:pinyinapp/core/database/hive_boxes.dart';
import 'package:pinyinapp/core/database/hive_bootstrap.dart';
import 'package:pinyinapp/features/audio/data/datasources/just_audio_player_data_source.dart';
import 'package:pinyinapp/features/audio/data/providers/youdao/youdao_audio_url_provider.dart';
import 'package:pinyinapp/features/audio/data/repositories/audio_repository_impl.dart';
import 'package:pinyinapp/features/audio/domain/repositories/audio_repository.dart';
import 'package:pinyinapp/features/dictionary/data/datasources/dictionary_database.dart';
import 'package:pinyinapp/features/dictionary/data/datasources/sqflite_dictionary_data_source.dart';
import 'package:pinyinapp/features/dictionary/data/repositories/dictionary_repository_impl.dart';
import 'package:pinyinapp/features/dictionary/domain/repositories/dictionary_repository.dart';
import 'package:pinyinapp/features/favorites/data/datasources/favorites_local_data_source.dart';
import 'package:pinyinapp/features/favorites/data/repositories/favorites_repository_impl.dart';
import 'package:pinyinapp/features/favorites/domain/repositories/favorites_repository.dart';
import 'package:pinyinapp/features/history/data/datasources/history_local_data_source.dart';
import 'package:pinyinapp/features/history/data/repositories/history_repository_impl.dart';
import 'package:pinyinapp/features/history/domain/repositories/history_repository.dart';
import 'package:pinyinapp/features/translation/data/datasources/hive_translation_cache_data_source.dart';
import 'package:pinyinapp/features/translation/data/providers/google/google_translation_provider.dart';
import 'package:pinyinapp/features/translation/data/repositories/translation_repository_impl.dart';
import 'package:pinyinapp/features/translation/domain/repositories/translation_repository.dart';

class Dependencies {
  Dependencies._({
    required this.dictionary,
    required this.translation,
    required this.audio,
    required this.favorites,
    required this.history,
  });

  final DictionaryRepository dictionary;
  final TranslationRepository translation;
  final AudioRepository audio;
  final FavoritesRepository favorites;
  final HistoryRepository history;

  static Dependencies build() {
    final dio = Dio(
      BaseOptions(
        baseUrl: ApiEndpoints.googleTranslateBaseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 15),
      ),
    );

    return Dependencies._(
      dictionary: DictionaryRepositoryImpl(
        localDataSource: SqfliteDictionaryDataSource(
          DictionaryDatabase.open,
        ),
      ),
      translation: TranslationRepositoryImpl(
        provider: GoogleTranslationProvider(
          dio: dio,
          credentials: GoogleTranslateCredentials.fromEnvironment(),
        ),
        cache: HiveTranslationCacheDataSource(
          HiveBootstrap.box(HiveBoxes.translationCache),
        ),
      ),
      audio: AudioRepositoryImpl(
        urlProvider: const YoudaoAudioUrlProvider(),
        player: JustAudioPlayerDataSource(AudioPlayer()),
      ),
      favorites: FavoritesRepositoryImpl(
        dataSource: HiveFavoritesLocalDataSource(
          HiveBootstrap.box(HiveBoxes.favorites),
        ),
      ),
      history: HistoryRepositoryImpl(
        dataSource: HiveHistoryLocalDataSource(
          HiveBootstrap.box(HiveBoxes.history),
        ),
      ),
    );
  }
}

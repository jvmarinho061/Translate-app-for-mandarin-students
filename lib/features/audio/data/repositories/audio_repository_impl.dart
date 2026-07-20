import 'package:pinyinapp/core/error/exceptions.dart';
import 'package:pinyinapp/core/error/failure.dart';
import 'package:pinyinapp/core/result/result.dart';
import 'package:pinyinapp/features/audio/data/datasources/audio_player_data_source.dart';
import 'package:pinyinapp/features/audio/data/providers/audio_url_provider.dart';
import 'package:pinyinapp/features/audio/domain/entities/audio_source.dart';
import 'package:pinyinapp/features/audio/domain/repositories/audio_repository.dart';

class AudioRepositoryImpl implements AudioRepository {
  const AudioRepositoryImpl({required this.urlProvider, required this.player});

  final AudioUrlProvider urlProvider;
  final AudioPlayerDataSource player;

  @override
  Future<Result<AudioSource>> resolve(String term) async {
    final trimmed = term.trim();
    if (trimmed.isEmpty) {
      return const FailureResult(
        ValidationFailure(reason: 'Termo vazio não possui pronúncia.'),
      );
    }

    try {
      return Success(
        AudioSource(
          term: trimmed,
          uri: urlProvider.buildUri(trimmed),
          isLocal: false,
        ),
      );
    } on Object catch (error) {
      return FailureResult(AudioFailure(debugMessage: error.toString()));
    }
  }

  @override
  Future<Result<void>> play(AudioSource source) async {
    try {
      await player.play(source.uri);
      return const Success(null);
    } on AudioPlaybackException catch (error) {
      return FailureResult(AudioFailure(debugMessage: error.message));
    } on Object catch (error) {
      return FailureResult(AudioFailure(debugMessage: error.toString()));
    }
  }

  @override
  Future<Result<void>> stop() async {
    try {
      await player.stop();
      return const Success(null);
    } on Object catch (error) {
      return FailureResult(AudioFailure(debugMessage: error.toString()));
    }
  }
}

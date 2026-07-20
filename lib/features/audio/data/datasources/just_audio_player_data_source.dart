import 'dart:async';

import 'package:just_audio/just_audio.dart';
import 'package:pinyinapp/core/error/exceptions.dart';
import 'package:pinyinapp/features/audio/data/datasources/audio_player_data_source.dart';

class JustAudioPlayerDataSource implements AudioPlayerDataSource {
  JustAudioPlayerDataSource(this.player);

  final AudioPlayer player;

  @override
  Future<void> play(Uri uri) async {
    try {
      await player.setUrl(uri.toString());
      unawaited(player.play());
    } on Object catch (error) {
      throw AudioPlaybackException(
        'Falha ao reproduzir $uri.',
        cause: error,
      );
    }
  }

  @override
  Future<void> stop() async {
    try {
      await player.stop();
    } on Object catch (error) {
      throw AudioPlaybackException('Falha ao parar a reprodução.', cause: error);
    }
  }

  Future<void> dispose() => player.dispose();
}

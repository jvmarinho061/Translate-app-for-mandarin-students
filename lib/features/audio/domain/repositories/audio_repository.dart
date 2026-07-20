import 'package:pinyinapp/core/result/result.dart';
import 'package:pinyinapp/features/audio/domain/entities/audio_source.dart';

abstract interface class AudioRepository {
  Future<Result<AudioSource>> resolve(String term);

  Future<Result<void>> play(AudioSource source);

  Future<Result<void>> stop();
}

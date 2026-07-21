import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pinyinapp/core/error/failure.dart';
import 'package:pinyinapp/features/audio/domain/repositories/audio_repository.dart';

sealed class AudioState extends Equatable {
  const AudioState();
  @override
  List<Object?> get props => [];
}

class AudioIdle extends AudioState {
  const AudioIdle();
}

class AudioBuffering extends AudioState {
  const AudioBuffering(this.term);
  final String term;
  @override
  List<Object?> get props => [term];
}

class AudioPlaying extends AudioState {
  const AudioPlaying(this.term);
  final String term;
  @override
  List<Object?> get props => [term];
}

class AudioError extends AudioState {
  const AudioError(this.failure);
  final Failure failure;
  @override
  List<Object?> get props => [failure];
}

class AudioCubit extends Cubit<AudioState> {
  AudioCubit(this.repository) : super(const AudioIdle());

  final AudioRepository repository;

  Future<void> play(String term) async {
    emit(AudioBuffering(term));

    // "Só um áudio por vez" é regra de negócio e mora aqui, não na UI.
    await repository.stop();

    final resolved = await repository.resolve(term);
    if (isClosed) return;

    final source = resolved.valueOrNull;
    if (source == null) {
      emit(AudioError(resolved.failureOrNull ?? const AudioFailure()));
      return;
    }

    final played = await repository.play(source);
    if (isClosed) return;

    emit(
      played.fold(
        onSuccess: (_) => AudioPlaying(term),
        onFailure: AudioError.new,
      ),
    );
  }

  Future<void> stop() async {
    await repository.stop();
    if (!isClosed) emit(const AudioIdle());
  }
}

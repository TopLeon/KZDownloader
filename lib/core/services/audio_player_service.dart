import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
part 'audio_player_service.g.dart';

@Riverpod(keepAlive: true)
AudioPlayerService audioPlayerService(Ref ref) {
  return AudioPlayerService();
}

// Represents the current state of the audio player.
class AudioState {
  final bool isPlaying;
  final Duration position;
  final Duration duration;
  final String? currentFilePath;
  final String? currentThumbnail;
  final String? currentTitle;
  final String? currentChannel;
  final int? currentTaskId;

  AudioState({
    this.isPlaying = false,
    this.position = Duration.zero,
    this.duration = Duration.zero,
    this.currentFilePath,
    this.currentThumbnail,
    this.currentTitle,
    this.currentChannel,
    this.currentTaskId,
  });

  AudioState copyWith({
    bool? isPlaying,
    Duration? position,
    Duration? duration,
    String? currentFilePath,
    String? currentThumbnail,
    String? currentTitle,
    String? currentChannel,
    int? currentTaskId,
  }) {
    return AudioState(
      isPlaying: isPlaying ?? this.isPlaying,
      position: position ?? this.position,
      duration: duration ?? this.duration,
      currentFilePath: currentFilePath ?? this.currentFilePath,
      currentThumbnail: currentThumbnail ?? this.currentThumbnail,
      currentTitle: currentTitle ?? this.currentTitle,
      currentChannel: currentChannel ?? this.currentChannel,
      currentTaskId: currentTaskId ?? this.currentTaskId,
    );
  }
}

// Notifier that manages the audio playback state.
@riverpod
class AudioStateNotifier extends _$AudioStateNotifier {
  @override
  AudioState build() {
    final service = ref.watch(audioPlayerServiceProvider);

    final s1 = service.player.playerStateStream.listen((playerState) {
      state = state.copyWith(isPlaying: playerState.playing);
    });
    final s2 = service.player.positionStream.listen((pos) {
      state = state.copyWith(position: pos);
    });
    final s3 = service.player.durationStream.listen((dur) {
      state = state.copyWith(duration: dur ?? Duration.zero);
    });

    ref.onDispose(() {
      s1.cancel();
      s2.cancel();
      s3.cancel();
    });

    return AudioState();
  }

  // Plays audio from the specified file path.
  Future<void> playAudio(String filePath,
      {String? thumbnail, String? title, String? channel, int? taskId}) async {
    final service = ref.read(audioPlayerServiceProvider);
    if (state.currentFilePath == filePath) {
      if (state.isPlaying) {
        await service.pause();
      } else {
        await service.play();
      }
    } else {
      state = state.copyWith(
        currentFilePath: filePath,
        currentThumbnail: thumbnail,
        currentTitle: title,
        currentChannel: channel,
        currentTaskId: taskId,
      );
      await service.setUrl(filePath);
      await service.play();
    }
  }

  // Stops playback.
  Future<void> stop() async {
    final service = ref.read(audioPlayerServiceProvider);
    await service.stop();
    state = AudioState();
  }
}

// Service wrapping the audio player functionality.
class AudioPlayerService {
  final AudioPlayer player = AudioPlayer();

  AudioPlayerService();

  Future<void> setUrl(String filePath) async {
    await player.setFilePath(filePath);
  }

  Future<void> play() async {
    await player.play();
  }

  Future<void> pause() async {
    await player.pause();
  }

  Future<void> stop() async {
    await player.stop();
  }
}

final currentlyPlayingProvider = Provider<int?>((ref) {
  return ref.watch(audioStateProvider).currentTaskId;
});

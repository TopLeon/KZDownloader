// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'audio_player_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(audioPlayerService)
const audioPlayerServiceProvider = AudioPlayerServiceProvider._();

final class AudioPlayerServiceProvider extends $FunctionalProvider<
    AudioPlayerService,
    AudioPlayerService,
    AudioPlayerService> with $Provider<AudioPlayerService> {
  const AudioPlayerServiceProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'audioPlayerServiceProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$audioPlayerServiceHash();

  @$internal
  @override
  $ProviderElement<AudioPlayerService> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AudioPlayerService create(Ref ref) {
    return audioPlayerService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AudioPlayerService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AudioPlayerService>(value),
    );
  }
}

String _$audioPlayerServiceHash() =>
    r'341770aae4dd4b9ecf8382ff937aa241ede6cdd8';

@ProviderFor(AudioStateNotifier)
const audioStateProvider = AudioStateNotifierProvider._();

final class AudioStateNotifierProvider
    extends $NotifierProvider<AudioStateNotifier, AudioState> {
  const AudioStateNotifierProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'audioStateProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$audioStateNotifierHash();

  @$internal
  @override
  AudioStateNotifier create() => AudioStateNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AudioState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AudioState>(value),
    );
  }
}

String _$audioStateNotifierHash() =>
    r'784a39038c3b6b713ae24e36594c8c6f53336adc';

abstract class _$AudioStateNotifier extends $Notifier<AudioState> {
  AudioState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<AudioState, AudioState>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AudioState, AudioState>, AudioState, Object?, Object?>;
    element.handleValue(ref, created);
  }
}

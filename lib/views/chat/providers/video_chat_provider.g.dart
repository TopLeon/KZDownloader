// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'video_chat_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(VideoChatNotifier)
const videoChatProvider = VideoChatNotifierProvider._();

final class VideoChatNotifierProvider
    extends $NotifierProvider<VideoChatNotifier, VideoChatState> {
  const VideoChatNotifierProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'videoChatProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$videoChatNotifierHash();

  @$internal
  @override
  VideoChatNotifier create() => VideoChatNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(VideoChatState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<VideoChatState>(value),
    );
  }
}

String _$videoChatNotifierHash() => r'338c9b040a2d246e115c4b0cfb64f5fe801d15fc';

abstract class _$VideoChatNotifier extends $Notifier<VideoChatState> {
  VideoChatState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<VideoChatState, VideoChatState>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<VideoChatState, VideoChatState>,
        VideoChatState,
        Object?,
        Object?>;
    element.handleValue(ref, created);
  }
}

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'playlist_detail_pane.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(SelectedPlaylistVideo)
const selectedPlaylistVideoProvider = SelectedPlaylistVideoProvider._();

final class SelectedPlaylistVideoProvider
    extends $NotifierProvider<SelectedPlaylistVideo, DownloadTask?> {
  const SelectedPlaylistVideoProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'selectedPlaylistVideoProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$selectedPlaylistVideoHash();

  @$internal
  @override
  SelectedPlaylistVideo create() => SelectedPlaylistVideo();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DownloadTask? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DownloadTask?>(value),
    );
  }
}

String _$selectedPlaylistVideoHash() =>
    r'd725983fff6afdc07cbb28e045b7d81bc5d4997f';

abstract class _$SelectedPlaylistVideo extends $Notifier<DownloadTask?> {
  DownloadTask? build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<DownloadTask?, DownloadTask?>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<DownloadTask?, DownloadTask?>,
        DownloadTask?,
        Object?,
        Object?>;
    element.handleValue(ref, created);
  }
}

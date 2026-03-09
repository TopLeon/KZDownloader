// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'prefetched_metadata.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Stores prefetched metadata keyed by URL.

@ProviderFor(PrefetchedMetadata)
const prefetchedMetadataProvider = PrefetchedMetadataProvider._();

/// Stores prefetched metadata keyed by URL.
final class PrefetchedMetadataProvider
    extends $NotifierProvider<PrefetchedMetadata, Map<String, PrefetchedData>> {
  /// Stores prefetched metadata keyed by URL.
  const PrefetchedMetadataProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'prefetchedMetadataProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$prefetchedMetadataHash();

  @$internal
  @override
  PrefetchedMetadata create() => PrefetchedMetadata();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Map<String, PrefetchedData> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Map<String, PrefetchedData>>(value),
    );
  }
}

String _$prefetchedMetadataHash() =>
    r'd5c5e5e7f31cc939e671663546700aeb7a11093a';

/// Stores prefetched metadata keyed by URL.

abstract class _$PrefetchedMetadata
    extends $Notifier<Map<String, PrefetchedData>> {
  Map<String, PrefetchedData> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref
        as $Ref<Map<String, PrefetchedData>, Map<String, PrefetchedData>>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<Map<String, PrefetchedData>, Map<String, PrefetchedData>>,
        Map<String, PrefetchedData>,
        Object?,
        Object?>;
    element.handleValue(ref, created);
  }
}

/// Tracks the prefetch status for the currently active URL input.

@ProviderFor(PrefetchStatusNotifier)
const prefetchStatusProvider = PrefetchStatusNotifierProvider._();

/// Tracks the prefetch status for the currently active URL input.
final class PrefetchStatusNotifierProvider
    extends $NotifierProvider<PrefetchStatusNotifier, PrefetchStatus> {
  /// Tracks the prefetch status for the currently active URL input.
  const PrefetchStatusNotifierProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'prefetchStatusProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$prefetchStatusNotifierHash();

  @$internal
  @override
  PrefetchStatusNotifier create() => PrefetchStatusNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PrefetchStatus value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PrefetchStatus>(value),
    );
  }
}

String _$prefetchStatusNotifierHash() =>
    r'5606d0a06ecefbaadeb47c3b543293ae21d381e1';

/// Tracks the prefetch status for the currently active URL input.

abstract class _$PrefetchStatusNotifier extends $Notifier<PrefetchStatus> {
  PrefetchStatus build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<PrefetchStatus, PrefetchStatus>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<PrefetchStatus, PrefetchStatus>,
        PrefetchStatus,
        Object?,
        Object?>;
    element.handleValue(ref, created);
  }
}

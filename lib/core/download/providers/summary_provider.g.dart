// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'summary_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ActiveSummaries)
const activeSummariesProvider = ActiveSummariesProvider._();

final class ActiveSummariesProvider
    extends $NotifierProvider<ActiveSummaries, Set<int>> {
  const ActiveSummariesProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'activeSummariesProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$activeSummariesHash();

  @$internal
  @override
  ActiveSummaries create() => ActiveSummaries();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Set<int> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Set<int>>(value),
    );
  }
}

String _$activeSummariesHash() => r'1ca7d8fe9d60b42976ce9865f8537b611097438d';

abstract class _$ActiveSummaries extends $Notifier<Set<int>> {
  Set<int> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<Set<int>, Set<int>>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<Set<int>, Set<int>>, Set<int>, Object?, Object?>;
    element.handleValue(ref, created);
  }
}

@ProviderFor(SummaryManager)
const summaryManagerProvider = SummaryManagerProvider._();

final class SummaryManagerProvider
    extends $NotifierProvider<SummaryManager, void> {
  const SummaryManagerProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'summaryManagerProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$summaryManagerHash();

  @$internal
  @override
  SummaryManager create() => SummaryManager();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$summaryManagerHash() => r'32c5d77df831a2eb474323c917c8609dc50cc363';

abstract class _$SummaryManager extends $Notifier<void> {
  void build();
  @$mustCallSuper
  @override
  void runBuild() {
    build();
    final ref = this.ref as $Ref<void, void>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<void, void>, void, Object?, Object?>;
    element.handleValue(ref, null);
  }
}

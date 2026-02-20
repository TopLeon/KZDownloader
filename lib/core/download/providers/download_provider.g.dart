// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'download_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(dbService)
const dbServiceProvider = DbServiceProvider._();

final class DbServiceProvider
    extends $FunctionalProvider<DbService, DbService, DbService>
    with $Provider<DbService> {
  const DbServiceProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'dbServiceProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$dbServiceHash();

  @$internal
  @override
  $ProviderElement<DbService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  DbService create(Ref ref) {
    return dbService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DbService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DbService>(value),
    );
  }
}

String _$dbServiceHash() => r'13e7dd57c66ffa9a1d062494249d131bb91673dc';

@ProviderFor(dbInit)
const dbInitProvider = DbInitProvider._();

final class DbInitProvider
    extends $FunctionalProvider<AsyncValue<void>, void, FutureOr<void>>
    with $FutureModifier<void>, $FutureProvider<void> {
  const DbInitProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'dbInitProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$dbInitHash();

  @$internal
  @override
  $FutureProviderElement<void> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<void> create(Ref ref) {
    return dbInit(ref);
  }
}

String _$dbInitHash() => r'21b7be03fdbb027acd600e8d631880962ee316ed';

@ProviderFor(SelectedCategory)
const selectedCategoryProvider = SelectedCategoryProvider._();

final class SelectedCategoryProvider
    extends $NotifierProvider<SelectedCategory, TaskCategory?> {
  const SelectedCategoryProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'selectedCategoryProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$selectedCategoryHash();

  @$internal
  @override
  SelectedCategory create() => SelectedCategory();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TaskCategory? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TaskCategory?>(value),
    );
  }
}

String _$selectedCategoryHash() => r'fecd06fd5d1cc05d8993ea5c66bcc26db258d503';

abstract class _$SelectedCategory extends $Notifier<TaskCategory?> {
  TaskCategory? build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<TaskCategory?, TaskCategory?>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<TaskCategory?, TaskCategory?>,
        TaskCategory?,
        Object?,
        Object?>;
    element.handleValue(ref, created);
  }
}

@ProviderFor(LastAddedTaskId)
const lastAddedTaskIdProvider = LastAddedTaskIdProvider._();

final class LastAddedTaskIdProvider
    extends $NotifierProvider<LastAddedTaskId, int?> {
  const LastAddedTaskIdProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'lastAddedTaskIdProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$lastAddedTaskIdHash();

  @$internal
  @override
  LastAddedTaskId create() => LastAddedTaskId();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int?>(value),
    );
  }
}

String _$lastAddedTaskIdHash() => r'e62009b547ffb2a43375effd0446d9a4d053b52a';

abstract class _$LastAddedTaskId extends $Notifier<int?> {
  int? build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<int?, int?>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<int?, int?>, int?, Object?, Object?>;
    element.handleValue(ref, created);
  }
}

@ProviderFor(ExpandedTaskId)
const expandedTaskIdProvider = ExpandedTaskIdProvider._();

final class ExpandedTaskIdProvider
    extends $NotifierProvider<ExpandedTaskId, int?> {
  const ExpandedTaskIdProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'expandedTaskIdProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$expandedTaskIdHash();

  @$internal
  @override
  ExpandedTaskId create() => ExpandedTaskId();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int?>(value),
    );
  }
}

String _$expandedTaskIdHash() => r'ab037992611baa400ea2e135c6aefb87bb2db9e2';

abstract class _$ExpandedTaskId extends $Notifier<int?> {
  int? build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<int?, int?>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<int?, int?>, int?, Object?, Object?>;
    element.handleValue(ref, created);
  }
}

@ProviderFor(ActiveDownloadProgress)
const activeDownloadProgressProvider = ActiveDownloadProgressProvider._();

final class ActiveDownloadProgressProvider extends $NotifierProvider<
    ActiveDownloadProgress, Map<int, Map<String, dynamic>>> {
  const ActiveDownloadProgressProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'activeDownloadProgressProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$activeDownloadProgressHash();

  @$internal
  @override
  ActiveDownloadProgress create() => ActiveDownloadProgress();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Map<int, Map<String, dynamic>> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride:
          $SyncValueProvider<Map<int, Map<String, dynamic>>>(value),
    );
  }
}

String _$activeDownloadProgressHash() =>
    r'feb60b4f4c02803f80f8bb17fa3c4bd481a898c4';

abstract class _$ActiveDownloadProgress
    extends $Notifier<Map<int, Map<String, dynamic>>> {
  Map<int, Map<String, dynamic>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref
        as $Ref<Map<int, Map<String, dynamic>>, Map<int, Map<String, dynamic>>>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<Map<int, Map<String, dynamic>>,
            Map<int, Map<String, dynamic>>>,
        Map<int, Map<String, dynamic>>,
        Object?,
        Object?>;
    element.handleValue(ref, created);
  }
}

@ProviderFor(DownloadList)
const downloadListProvider = DownloadListProvider._();

final class DownloadListProvider
    extends $StreamNotifierProvider<DownloadList, List<DownloadTask>> {
  const DownloadListProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'downloadListProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$downloadListHash();

  @$internal
  @override
  DownloadList create() => DownloadList();
}

String _$downloadListHash() => r'9efeb7283a9585ad87d1abab284dfcb03ff906a3';

abstract class _$DownloadList extends $StreamNotifier<List<DownloadTask>> {
  Stream<List<DownloadTask>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref =
        this.ref as $Ref<AsyncValue<List<DownloadTask>>, List<DownloadTask>>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AsyncValue<List<DownloadTask>>, List<DownloadTask>>,
        AsyncValue<List<DownloadTask>>,
        Object?,
        Object?>;
    element.handleValue(ref, created);
  }
}

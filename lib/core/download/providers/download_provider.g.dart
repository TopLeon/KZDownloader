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

String _$dbServiceHash() => r'b10e9d8f6323903849fea133e43623a75ce7def9';

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

String _$dbInitHash() => r'8d5c33cf0131a3a976d28a56712cb07f915a83c7';

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

String _$selectedCategoryHash() => r'75b0f0c64348cf4b1f39f5e97ce235f1ce6f8596';

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

String _$lastAddedTaskIdHash() => r'cb0ea7f6bd16b47a32c613bf4f26cafe6156c379';

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

String _$expandedTaskIdHash() => r'3d50955c0536b3ec784c760a1c1e809b1b6d854c';

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

String _$downloadListHash() => r'3b6692f604e06444335872cc8ec1627116d283e4';

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

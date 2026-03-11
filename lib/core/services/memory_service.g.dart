// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'memory_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(memoryService)
const memoryServiceProvider = MemoryServiceProvider._();

final class MemoryServiceProvider
    extends $FunctionalProvider<MemoryService, MemoryService, MemoryService>
    with $Provider<MemoryService> {
  const MemoryServiceProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'memoryServiceProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$memoryServiceHash();

  @$internal
  @override
  $ProviderElement<MemoryService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  MemoryService create(Ref ref) {
    return memoryService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(MemoryService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<MemoryService>(value),
    );
  }
}

String _$memoryServiceHash() => r'7ad162aacbad9c48ca3dc48232fb79f86690df05';

@ProviderFor(memoryUsage)
const memoryUsageProvider = MemoryUsageProvider._();

final class MemoryUsageProvider
    extends $FunctionalProvider<AsyncValue<int>, int, Stream<int>>
    with $FutureModifier<int>, $StreamProvider<int> {
  const MemoryUsageProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'memoryUsageProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$memoryUsageHash();

  @$internal
  @override
  $StreamProviderElement<int> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<int> create(Ref ref) {
    return memoryUsage(ref);
  }
}

String _$memoryUsageHash() => r'22e7b3a328c1d8c4d25af0776a9b4171a8fdb775';

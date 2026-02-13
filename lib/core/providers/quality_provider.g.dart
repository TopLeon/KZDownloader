// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'quality_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(QualitySettings_)
const qualitySettings_Provider = QualitySettings_Provider._();

final class QualitySettings_Provider
    extends $AsyncNotifierProvider<QualitySettings_, QualitySettings> {
  const QualitySettings_Provider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'qualitySettings_Provider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$qualitySettings_Hash();

  @$internal
  @override
  QualitySettings_ create() => QualitySettings_();
}

String _$qualitySettings_Hash() => r'ab02d713d6f711ce46b60dacdf6320d10a6defc5';

abstract class _$QualitySettings_ extends $AsyncNotifier<QualitySettings> {
  FutureOr<QualitySettings> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<AsyncValue<QualitySettings>, QualitySettings>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AsyncValue<QualitySettings>, QualitySettings>,
        AsyncValue<QualitySettings>,
        Object?,
        Object?>;
    element.handleValue(ref, created);
  }
}

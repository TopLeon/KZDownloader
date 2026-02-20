// Holds metadata obtained from an HTTP HEAD request.
class UrlMetadata {
  final int size;
  final bool acceptRanges;
  final String? remoteFileName;

  const UrlMetadata({
    required this.size,
    required this.acceptRanges,
    this.remoteFileName,
  });
}

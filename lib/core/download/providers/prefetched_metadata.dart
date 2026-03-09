import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:kzdownloader/core/download/providers/url_metadata.dart';
import 'package:kzdownloader/core/utils/m3u8_utils.dart';

part 'prefetched_metadata.g.dart';

/// Status of a metadata prefetch operation.
enum PrefetchStatus { idle, loading, ready, error }

/// Holds prefetched metadata for a URL before the user submits it.
class PrefetchedData {
  /// yt-dlp format list (from metadata `formats` field)
  final List<Map<String, dynamic>> formats;

  /// Video/playlist title
  final String? title;

  /// Video thumbnail URL
  final String? thumbnail;

  /// Channel/uploader name
  final String? channel;

  /// Duration in seconds
  final int? duration;

  /// Whether this URL points to a playlist
  final bool isPlaylist;

  /// Number of videos in a playlist
  final int? videoCount;

  /// List of videos in a playlist (title, url, duration, etc.)
  final List<Map<String, dynamic>>? playlistVideos;

  /// HEAD request metadata for generic files
  final UrlMetadata? headMeta;

  /// Parsed M3U8 result for M3U8 URLs
  final M3U8ParseResult? m3u8Result;

  /// Error message if prefetch failed
  final String? errorMessage;

  const PrefetchedData({
    this.formats = const [],
    this.title,
    this.thumbnail,
    this.channel,
    this.duration,
    this.isPlaylist = false,
    this.videoCount,
    this.playlistVideos,
    this.headMeta,
    this.m3u8Result,
    this.errorMessage,
  });
}

/// Stores prefetched metadata keyed by URL.
@Riverpod(keepAlive: true)
class PrefetchedMetadata extends _$PrefetchedMetadata {
  @override
  Map<String, PrefetchedData> build() => {};

  void set(String url, PrefetchedData data) {
    state = {...state, url: data};
  }

  void remove(String url) {
    final newState = Map<String, PrefetchedData>.from(state);
    newState.remove(url);
    state = newState;
  }

  PrefetchedData? get(String url) => state[url];

  void clear() => state = {};
}

/// Tracks the prefetch status for the currently active URL input.
@Riverpod(keepAlive: true)
class PrefetchStatusNotifier extends _$PrefetchStatusNotifier {
  @override
  PrefetchStatus build() => PrefetchStatus.idle;

  void setStatus(PrefetchStatus status) => state = status;
}

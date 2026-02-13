import 'package:flutter/material.dart';
import 'package:youtube_player_embed/youtube_player_embed.dart';
import 'package:kzdownloader/models/download_task.dart';

class VideoPlayerDialog extends StatefulWidget {
  final DownloadTask task;

  const VideoPlayerDialog({super.key, required this.task});

  @override
  State<VideoPlayerDialog> createState() => _VideoPlayerDialogState();
}

class _VideoPlayerDialogState extends State<VideoPlayerDialog> {
  String _extractVideoId(String url) {
    // Supports youtu.be/ID and youtube.com/watch?v=ID
    final uri = Uri.parse(url);
    if (uri.host.contains('youtu.be')) {
      return uri.pathSegments.isNotEmpty ? uri.pathSegments.first : '';
    }
    if (uri.queryParameters.containsKey('v')) {
      return uri.queryParameters['v'] ?? '';
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      insetPadding: const EdgeInsets.all(16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: AspectRatio(
          aspectRatio: 16 / 9,
          child: YoutubePlayerEmbed(
            key: ValueKey(widget.task.url), // Unique key for the video
            callBackVideoController: (controller) {},
            videoId: _extractVideoId(widget.task.url),
            autoPlay: true,
            customVideoTitle: widget.task.title,
          ),
        ),
      ),
    );
  }
}

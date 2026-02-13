import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kzdownloader/core/services/audio_player_service.dart';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:kzdownloader/l10n/arb/app_localizations.dart';
import 'dart:ui';

// Shows audio metadata (thumbnail, progress), and controls for play/pause/stop.
// It appears only when there is an active audio track in [AudioState].
class AudioPlayerBar extends ConsumerStatefulWidget {
  const AudioPlayerBar({super.key});

  @override
  ConsumerState<AudioPlayerBar> createState() => _AudioPlayerBarState();
}

class _AudioPlayerBarState extends ConsumerState<AudioPlayerBar> {
  //bool _isCompact = true;
  bool hovered = false;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(audioStateProvider);
    final l10n = AppLocalizations.of(context)!;

    if (state.currentFilePath == null) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Horizontal compact player bar
    return MouseRegion(
      onEnter: (_) {
        setState(() {
          hovered = true;
        });
      },
      onExit: (_) {
        setState(() {
          hovered = false;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.only(bottom: 12, left: 14, right: 14),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color:
              hovered ? theme.colorScheme.tertiary : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: colorScheme.primary.withOpacity(0.15), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.all(Radius.circular(4)),
                  child: state.currentThumbnail != null
                      ? Image.network(
                          state.currentThumbnail!,
                          height: 30,
                          width: 30,
                          fit: BoxFit.cover,
                          errorBuilder: (BuildContext context, Object exception,
                              StackTrace? stackTrace) {
                            return Container(
                              color: Colors.grey[800],
                              child: const Icon(Icons.music_note,
                                  size: 24, color: Colors.white54),
                            );
                          },
                        )
                      : Container(
                          height: 30,
                          width: 30,
                          color: Colors.grey[800],
                          child: const Icon(Icons.music_note,
                              size: 24, color: Colors.white54),
                        ),
                ),
                const SizedBox(
                  width: 8,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (hovered) ...[
                        _MarqueeText(
                          text: state.currentTitle ?? l10n.analyzing,
                          style: GoogleFonts.montserrat(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: colorScheme.onSurface,
                          ),
                        ),
                      ] else ...[
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Text(
                            state.currentTitle ?? l10n.analyzing,
                            style: GoogleFonts.montserrat(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: colorScheme.onSurface,
                            ),
                          ),
                        ),
                      ],
                      Text(
                        state.currentChannel ?? l10n.analyzing,
                        style: GoogleFonts.montserrat(
                          fontSize: 11,
                          fontWeight: FontWeight.w400,
                          color: colorScheme.onSurfaceVariant,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                InkWell(
                  onTap: () {
                    ref.read(audioStateProvider.notifier).stop();
                    setState(() {
                      hovered = false;
                    });
                  },
                  child: Icon(
                    Icons.close_rounded,
                    size: 18,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Progress bar with time labels
            Row(
              children: [
                Text(
                  _formatDuration(state.position),
                  style: GoogleFonts.montserrat(
                    fontSize: 11,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ProgressBar(
                    progress: state.position,
                    total: state.duration,
                    onSeek: (duration) {
                      ref
                          .read(audioPlayerServiceProvider)
                          .player
                          .seek(duration);
                    },
                    timeLabelLocation: TimeLabelLocation.none,
                    progressBarColor: colorScheme.primary,
                    baseBarColor: hovered
                        ? colorScheme.primary.withOpacity(0.2)
                        : colorScheme.primary.withOpacity(0.1),
                    thumbColor: colorScheme.primary,
                    thumbRadius: 0,
                    thumbGlowRadius: 5,
                    barHeight: 3,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  _formatDuration(state.duration),
                  style: GoogleFonts.montserrat(
                    fontSize: 11,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            if (hovered) const SizedBox(height: 8),

            if (hovered)
              // Controls row
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: () {
                      final currentPos = state.position;
                      ref
                          .read(audioPlayerServiceProvider)
                          .player
                          .seek(currentPos - const Duration(seconds: 10));
                    },
                    icon: const Icon(Icons.replay_10_rounded),
                    iconSize: 22,
                    color: colorScheme.primary,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(width: 16),
                  IconButton(
                    onPressed: () {
                      if (state.isPlaying) {
                        ref.read(audioPlayerServiceProvider).pause();
                      } else {
                        ref.read(audioPlayerServiceProvider).play();
                      }
                    },
                    icon: Icon(
                      state.isPlaying
                          ? Icons.pause_rounded
                          : Icons.play_arrow_rounded,
                    ),
                    iconSize: 32,
                    color: colorScheme.primary,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(width: 16),
                  IconButton(
                    onPressed: () {
                      final currentPos = state.position;
                      ref
                          .read(audioPlayerServiceProvider)
                          .player
                          .seek(currentPos + const Duration(seconds: 10));
                    },
                    icon: const Icon(Icons.forward_10_rounded),
                    iconSize: 22,
                    color: colorScheme.primary,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }
}

// Widget for marquee scrolling text
class _MarqueeText extends StatefulWidget {
  final String text;
  final TextStyle style;

  const _MarqueeText({
    required this.text,
    required this.style,
  });

  @override
  State<_MarqueeText> createState() => _MarqueeTextState();
}

class _MarqueeTextState extends State<_MarqueeText>
    with SingleTickerProviderStateMixin {
  late ScrollController _scrollController;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _animationController = AnimationController(
      vsync: this,
      duration:
          const Duration(seconds: 1), // Will be updated based on actual width
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients &&
          _scrollController.position.maxScrollExtent > 0) {
        _startScrolling();
      }
    });
  }

  void _startScrolling() async {
    if (!mounted) return;
    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;

    // Calculate duration based on actual scroll distance for constant speed
    // Speed: 10 pixels per second
    const pixelsPerSecond = 10.0;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final durationSeconds = maxScroll / pixelsPerSecond;

    _animationController.duration =
        Duration(milliseconds: (durationSeconds * 1000).toInt());
    _animationController.repeat();
    _animationController.addListener(() {
      if (_scrollController.hasClients) {
        final progress = _animationController.value;
        _scrollController.jumpTo(maxScroll * progress);
      }
    });
  }

  @override
  void didUpdateWidget(_MarqueeText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text) {
      // Reset and recalculate animation when text changes
      _animationController.stop();
      _animationController.reset();
      _scrollController.jumpTo(0);

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients &&
            _scrollController.position.maxScrollExtent > 0) {
          _startScrolling();
        }
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.style.fontSize! * (widget.style.height ?? 1.3),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        controller: _scrollController,
        child: Padding(
          padding: const EdgeInsets.only(right: 4),
          child: Text(
            widget.text,
            style: widget.style,
            maxLines: 1,
            overflow: TextOverflow.visible,
          ),
        ),
      ),
    );
  }
}

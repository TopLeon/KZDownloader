import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kzdownloader/models/playlist.dart';
import 'package:kzdownloader/core/download/providers/playlist_provider.dart';
import 'package:kzdownloader/core/download/providers/download_provider.dart';
import 'package:kzdownloader/models/download_task.dart';
import 'package:kzdownloader/core/services/audio_player_service.dart';
import 'package:kzdownloader/views/widgets/confirm_dialog.dart';
import 'package:ultimate_flutter_icons/ficon.dart';
import 'package:ultimate_flutter_icons/icons/ri.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';
import 'package:kzdownloader/l10n/arb/app_localizations.dart';

// Detail pane for user-created music playlists.
class PlaylistDetailPane extends ConsumerStatefulWidget {
  final Playlist playlist;
  final VoidCallback? onClose;

  const PlaylistDetailPane({
    super.key,
    required this.playlist,
    this.onClose,
  });

  @override
  ConsumerState<PlaylistDetailPane> createState() => _PlaylistDetailPaneState();
}

class _PlaylistDetailPaneState extends ConsumerState<PlaylistDetailPane> {
  Future<void> _pickCoverImage() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
    );

    if (result != null && result.files.single.path != null) {
      final imagePath = result.files.single.path!;
      await ref
          .read(playlistListProvider.notifier)
          .updatePlaylistImage(widget.playlist.id, imagePath);
    }
  }

  void _showAddMusicDialog() async {
    final allTasks = await ref.read(downloadListProvider.future);

    // Get the updated playlist to check current tracks
    final playlists = ref.read(playlistListProvider);
    final currentPlaylist = playlists.firstWhere(
      (p) => p.id == widget.playlist.id,
      orElse: () => widget.playlist,
    );

    // Filter only completed music tracks
    final musicTracks = allTasks.where((t) {
      return t.category == TaskCategory.music &&
          t.downloadStatus.isSuccess &&
          t.filePath != null;
    }).toList();

    // Remove tracks already present in the playlist
    final playlistTaskIds = currentPlaylist.tasks.map((t) => t.id).toSet();
    final availableTracks =
        musicTracks.where((t) => !playlistTaskIds.contains(t.id)).toList();

    if (availableTracks.isEmpty) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.noTracksToAdd),
        ),
      );
      return;
    }

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) => _AddMusicDialog(
        availableTracks: availableTracks,
        playlist: currentPlaylist,
        onAddTracks: (selectedTracks) async {
          await ref
              .read(playlistListProvider.notifier)
              .addTasksToPlaylist(widget.playlist.id, selectedTracks);
        },
      ),
    );
  }

  void _confirmRemoveTrack(DownloadTask track) {
    final l10n = AppLocalizations.of(context)!;
    showConfirmDialog(
      context,
      title: l10n.removeFromPlaylist,
      content: l10n.removeTrackConfirmMessage(track.title ?? ''),
      onConfirm: () async {
        await ref
            .read(playlistListProvider.notifier)
            .removeTaskFromPlaylist(widget.playlist.id, track);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    bool isDark = colorScheme.brightness == Brightness.dark;

    // Watch playlist updates to reflect changes in real-time
    final playlists = ref.watch(playlistListProvider);
    final currentPlaylist = playlists.firstWhere(
      (p) => p.id == widget.playlist.id,
      orElse: () => widget.playlist,
    );

    // Get playlist tracks via IsarLinks
    final playlistTracks = currentPlaylist.tasks.toList();

    return Container(
      width: MediaQuery.of(context).size.width * 0.3 < 550
          ? MediaQuery.of(context).size.width * 0.3
          : 550,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
          left: BorderSide(color: colorScheme.primary.withOpacity(0.15)),
        ),
      ),
      child: Column(
        children: [
          // Header with close button
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                if (widget.onClose != null)
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: widget.onClose,
                    tooltip: l10n.close,
                  ),
              ],
            ),
          ),

          // Scrollable content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(left: 24, right: 24, bottom: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Playlist cover
                  GestureDetector(
                    onTap: _pickCoverImage,
                    child: Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: isDark
                            ? Colors.white.withOpacity(0.1)
                            : colorScheme.surfaceContainerHighest,
                        border: Border.all(
                          color: colorScheme.primary.withOpacity(0.2),
                          width: 2,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: currentPlaylist.coverImage != null
                            ? Image.file(
                                File(currentPlaylist.coverImage!),
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    _buildPlaceholderCover(colorScheme),
                              )
                            : _buildPlaceholderCover(colorScheme),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Playlist name
                  Text(
                    currentPlaylist.name,
                    style: GoogleFonts.montserrat(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Info: track count and creation date
                      Text(
                        '${playlistTracks.length} ${playlistTracks.length == 1 ? l10n.track : l10n.tracks} - ',
                        style: GoogleFonts.montserrat(
                          fontSize: 13,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      Text(
                        l10n.createdOnDate(DateFormat.yMMMMd(
                                Localizations.localeOf(context).toString())
                            .format(currentPlaylist.createdAt)),
                        style: GoogleFonts.montserrat(
                          fontSize: 13,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Add Music button
                  FilledButton.icon(
                    onPressed: _showAddMusicDialog,
                    icon: FIcon(RI.RiAddLine,
                        size: 20, color: colorScheme.onPrimary),
                    label: Text(l10n.addMusic),
                    style: FilledButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Divider
                  if (playlistTracks.isNotEmpty)
                    Divider(
                      color: colorScheme.outlineVariant.withOpacity(0.5),
                    ),
                  const SizedBox(height: 12),

                  // Track list
                  if (playlistTracks.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 40),
                      child: Column(
                        children: [
                          FIcon(
                            RI.RiMusicLine,
                            size: 64,
                            color:
                                colorScheme.onSurfaceVariant.withOpacity(0.3),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            l10n.playlistEmpty,
                            style: GoogleFonts.notoSans(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    ...playlistTracks.asMap().entries.map((entry) {
                      final index = entry.key;
                      final track = entry.value;
                      return _buildTrackItem(
                        track,
                        index + 1,
                        colorScheme,
                        ref,
                      );
                    }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholderCover(ColorScheme colorScheme) {
    bool isDark = colorScheme.brightness == Brightness.dark;
    return Stack(
      children: [
        Container(
          color: isDark
              ? Colors.white.withOpacity(0.1)
              : colorScheme.surfaceContainerHighest,
          child: Center(
            child: FIcon(
              RI.RiPlayListFill,
              size: 64,
              color: colorScheme.primary.withOpacity(0.3),
            ),
          ),
        ),
        Positioned(
          bottom: 8,
          right: 8,
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: colorScheme.tertiary,
              shape: BoxShape.circle,
            ),
            child: FIcon(
              RI.RiImageEditLine,
              size: 16,
              color: colorScheme.primary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTrackItem(
    DownloadTask track,
    int index,
    ColorScheme colorScheme,
    WidgetRef ref,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: colorScheme.tertiary,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.primary.withOpacity(0.15)),
      ),
      child: InkWell(
        onTap: () {
          // Play audio
          if (track.filePath != null) {
            ref.read(audioStateProvider.notifier).playAudio(
                  track.filePath!,
                  thumbnail: track.thumbnail,
                  title: track.title,
                  channel: track.channelName,
                  taskId: track.id,
                );
          }
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Track number
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: colorScheme.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '$index',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.primary,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Thumbnail
              if (track.thumbnail != null)
                ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: Transform.scale(
                                  scale: 1.35,
                      child: CachedNetworkImage(
                        imageUrl: track.thumbnail!,
                        fit: BoxFit.cover,
                        height: 35,
                        width: 35,
                        filterQuality: FilterQuality.medium,
                        errorWidget: (context, url, error) => Container(
                          color: Theme.brightnessOf(context) == Brightness.dark
                              ? Colors.grey[800]
                              : Colors.grey[500],
                          child: const Icon(Icons.music_note,
                              size: 20, color: Colors.white54),
                        ),
                      ),
                    )),
              const SizedBox(width: 12),

              // Track info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      track.title ?? AppLocalizations.of(context)!.unknownTrack,
                      style: GoogleFonts.montserrat(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (track.channelName != null)
                      Text(
                        track.channelName!,
                        style: GoogleFonts.montserrat(
                          fontSize: 13,
                          color: colorScheme.onSurfaceVariant,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 8),

              // Remove button
              IconButton(
                icon: const FIcon(RI.RiDeleteBinLine, size: 18),
                onPressed: () => _confirmRemoveTrack(track),
                tooltip: AppLocalizations.of(context)!.removeFromPlaylist,
                style: IconButton.styleFrom(
                  foregroundColor: colorScheme.error,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Dialog for selecting music tracks to add to a playlist.
class _AddMusicDialog extends StatefulWidget {
  final List<DownloadTask> availableTracks;
  final Playlist playlist;
  final Function(List<DownloadTask>) onAddTracks;

  const _AddMusicDialog({
    required this.availableTracks,
    required this.playlist,
    required this.onAddTracks,
  });

  @override
  State<_AddMusicDialog> createState() => _AddMusicDialogState();
}

class _AddMusicDialogState extends State<_AddMusicDialog> {
  final Set<int> _selectedTrackIds = {};
  String _searchQuery = '';

  List<DownloadTask> get _filteredTracks {
    if (_searchQuery.isEmpty) return widget.availableTracks;

    final query = _searchQuery.toLowerCase();
    return widget.availableTracks.where((track) {
      final title = track.title?.toLowerCase() ?? '';
      final artist = track.channelName?.toLowerCase() ?? '';
      return title.contains(query) || artist.contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
      child: Material(
        color: Colors.transparent,
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 600, maxHeight: 500),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark
                    ? Colors.white.withOpacity(0.1)
                    : Colors.black.withOpacity(0.05),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 32,
                  offset: const Offset(0, 16),
                ),
              ],
            ),
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                // Header
                Row(
                  children: [
                    FIcon(
                      RI.RiPlayListAddLine,
                      color: colorScheme.primary,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      l10n.addMusic,
                      style: GoogleFonts.montserrat(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Search bar
                TextField(
                  onChanged: (value) => setState(() => _searchQuery = value),
                  decoration: InputDecoration(
                    hintText: l10n.searchTracksPlaceholder,
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: isDark
                        ? Colors.white.withOpacity(0.05)
                        : colorScheme.surfaceContainerHighest,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Selected count
                if (_selectedTrackIds.isNotEmpty)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        FIcon(
                          RI.RiCheckLine,
                          color: colorScheme.primary,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${_selectedTrackIds.length} ${_selectedTrackIds.length == 1 ? l10n.selectedTrackSingular : l10n.selectedTracksPlural}',
                          style: TextStyle(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 16),

                // Track list
                Expanded(
                  child: _filteredTracks.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              FIcon(
                                RI.RiSearchLine,
                                size: 48,
                                color: colorScheme.onSurfaceVariant
                                    .withOpacity(0.3),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                l10n.noTracksFound,
                                style: GoogleFonts.notoSans(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          itemCount: _filteredTracks.length,
                          itemBuilder: (context, index) {
                            final track = _filteredTracks[index];
                            final isSelected =
                                _selectedTrackIds.contains(track.id);

                            return Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? colorScheme.primary.withOpacity(0.1)
                                    : (isDark
                                        ? Colors.white.withOpacity(0.05)
                                        : colorScheme.surfaceContainerHighest),
                                borderRadius: BorderRadius.circular(12),
                                border: isSelected
                                    ? Border.all(
                                        color: colorScheme.primary,
                                        width: 2,
                                      )
                                    : null,
                              ),
                              child: InkWell(
                                onTap: () {
                                  setState(() {
                                    if (isSelected) {
                                      _selectedTrackIds.remove(track.id);
                                    } else {
                                      _selectedTrackIds.add(track.id);
                                    }
                                  });
                                },
                                borderRadius: BorderRadius.circular(12),
                                child: Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Row(
                                    children: [
                                      // Checkbox
                                      Container(
                                        width: 24,
                                        height: 24,
                                        decoration: BoxDecoration(
                                          color: isSelected
                                              ? colorScheme.primary
                                              : Colors.transparent,
                                          border: Border.all(
                                            color: isSelected
                                                ? colorScheme.primary
                                                : colorScheme.primary
                                                    .withOpacity(0.15),
                                            width: 2,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(6),
                                        ),
                                        child: isSelected
                                            ? Icon(
                                                Icons.check,
                                                size: 16,
                                                color: colorScheme.onPrimary,
                                              )
                                            : null,
                                      ),
                                      const SizedBox(width: 12),

                                      // Thumbnail
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(6),
                                        child: track.thumbnail != null
                                            ? CachedNetworkImage(
                                                imageUrl: track.thumbnail!,
                                                fit: BoxFit.cover,
                                                width: 40,
                                                height: 40,
                                                filterQuality:
                                                    FilterQuality.medium,
                                                errorWidget:
                                                    (context, url, error) =>
                                                        Container(
                                                  color: Theme.brightnessOf(
                                                              context) ==
                                                          Brightness.dark
                                                      ? Colors.grey[800]
                                                      : Colors.grey[500],
                                                  child: const Icon(
                                                      Icons.music_note,
                                                      size: 20,
                                                      color: Colors.white54),
                                                ),
                                              )
                                            : Container(
                                                color: Theme.brightnessOf(
                                                            context) ==
                                                        Brightness.dark
                                                    ? Colors.grey[800]
                                                    : Colors.grey[500],
                                                child: const Icon(
                                                    Icons.music_note,
                                                    size: 20,
                                                    color: Colors.white54),
                                              ),
                                      ),
                                      const SizedBox(width: 12),

                                      // Track info
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              track.title ??
                                                  AppLocalizations.of(context)!
                                                      .unknownTrack,
                                              style: GoogleFonts.notoSans(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w600,
                                                color: isSelected
                                                    ? colorScheme.primary
                                                    : colorScheme.onSurface,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            if (track.channelName != null)
                                              Text(
                                                track.channelName!,
                                                style: GoogleFonts.notoSans(
                                                  fontSize: 13,
                                                  color: colorScheme
                                                      .onSurfaceVariant,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                ),

                const SizedBox(height: 16),

                // Action buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Annulla'),
                    ),
                    const SizedBox(width: 12),
                    FilledButton(
                      onPressed: _selectedTrackIds.isEmpty
                          ? null
                          : () {
                              final selectedTracks = widget.availableTracks
                                  .where(
                                      (t) => _selectedTrackIds.contains(t.id))
                                  .toList();
                              widget.onAddTracks(selectedTracks);
                              Navigator.pop(context);
                            },
                      style: ButtonStyle(
                        shape: WidgetStateProperty.all(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                      child: Text(
                        'Aggiungi (${_selectedTrackIds.length})',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

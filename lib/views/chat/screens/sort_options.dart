import 'package:kzdownloader/l10n/arb/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:kzdownloader/models/download_task.dart';

enum SortOption {
  recent,
  downloaded,
  summaries,
  playlists,
}

String getSortOptionLabel(SortOption option, AppLocalizations l10n) {
  switch (option) {
    case SortOption.recent:
      return l10n.recentSection;
    case SortOption.downloaded:
      return l10n.downloaded;
    case SortOption.summaries:
      return l10n.categorySummaries;
    case SortOption.playlists:
      return l10n.playlistSection;
  }
}

IconData getSortOptionIcon(SortOption option) {
  switch (option) {
    case SortOption.recent:
      return Icons.sort_rounded;
    case SortOption.downloaded:
      return Icons.download_done;
    case SortOption.summaries:
      return Icons.auto_awesome;
    case SortOption.playlists:
      return Icons.playlist_play;
  }
}

/// Restituisce le opzioni di ordinamento disponibili per una data categoria.
/// Le playlist sono disponibili solo per la sezione video.
List<SortOption> getAvailableSortOptionsForCategory(TaskCategory? category) {
  if (category == TaskCategory.video) {
    return SortOption.values; // Tutte le opzioni per video
  } else {
    // Per altre categorie, escludi playlists
    return SortOption.values
        .where((option) => option != SortOption.playlists && option != SortOption.summaries)
        .toList();
  }
}

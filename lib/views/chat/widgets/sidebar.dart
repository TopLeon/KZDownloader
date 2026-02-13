import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kzdownloader/core/download/providers/download_provider.dart';
import 'package:kzdownloader/l10n/arb/app_localizations.dart';
import 'package:kzdownloader/models/download_task.dart';
import 'package:kzdownloader/views/chat/widgets/audio_player_bar.dart';
import 'package:ultimate_flutter_icons/ficon.dart';
import 'package:ultimate_flutter_icons/icons/ri.dart';

class Sidebar extends ConsumerStatefulWidget {
  final VoidCallback onNewDownload;
  final VoidCallback? onToggle;
  final bool isMinimized;

  const Sidebar({
    super.key,
    required this.onNewDownload,
    this.onToggle,
    this.isMinimized = false,
  });

  @override
  ConsumerState<Sidebar> createState() => _SidebarState();
}

class _SidebarState extends ConsumerState<Sidebar> {
  bool _isLibraryExpanded = true;
  bool _isDownloadsExpanded = true;

  @override
  Widget build(BuildContext context) {
    final selectedCategory = ref.watch(selectedCategoryProvider);
    final downloadList = ref.watch(downloadListProvider).asData?.value ?? [];
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    int getCount(TaskCategory cat) =>
        downloadList.where((t) => t.category == cat).length;

    int getInProgressCount() => downloadList
        .where((t) => [
              'downloading',
              'pending',
              'summarizing',
              'paused',
              'converting'
            ].contains(t.status))
        .length;

    int getFailedCount() => downloadList
        .where((t) => ['error', 'cancelled'].contains(t.status))
        .length;

    return Container(
      width: widget.isMinimized ? 80 : MediaQuery.of(context).size.width * 0.2,
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
          right: BorderSide(
            color: colorScheme.primary.withOpacity(0.15),
            width: 1,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: widget.isMinimized
            ? CrossAxisAlignment.center
            : CrossAxisAlignment.start,
        children: [
          if (widget.isMinimized)
            Padding(
              padding: const EdgeInsets.only(bottom: 6, top: 14),
              child: InkWell(
                onTap: widget.onToggle,
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: FIcon(RI.RiSideBarFill,
                      size: 24, color: colorScheme.primary),
                ),
              ),
            )
          else
            Padding(
              padding: EdgeInsets.only(
                  right: 14,
                  left: 16,
                  top: Platform.isMacOS ? 18 : 0,
                  bottom: 6),
              child: Row(
                children: [
                  Text(
                    'KZ',
                    style: GoogleFonts.montserrat(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                      letterSpacing: 0.5,
                    ),
                  ),
                  Text(
                    'Downloader',
                    style: GoogleFonts.montserrat(
                      fontSize: 18,
                      fontWeight: FontWeight.w300,
                      color: colorScheme.onSurface,
                      letterSpacing: 0.3,
                    ),
                  ),
                  const Spacer(),
                  if (widget.onToggle != null)
                    InkWell(
                      onTap: widget.onToggle,
                      borderRadius: BorderRadius.circular(4),
                      child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: FIcon(RI.RiSideBarFill,
                            size: 18, color: colorScheme.onSurfaceVariant),
                      ),
                    ),
                ],
              ),
            ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  if (widget.isMinimized) ...[
                    _SidebarItem(
                      label: l10n.categoryHome,
                      icon: RI.RiShadowLine,
                      selectedIcon: RI.RiShadowLine,
                      isSelected: selectedCategory == TaskCategory.home,
                      onTap: () => ref
                          .read(selectedCategoryProvider.notifier)
                          .setCategory(TaskCategory.home),
                      colorScheme: colorScheme,
                      isMinimized: true,
                    ),
                    const SizedBox(height: 8),
                    _SidebarItem(
                      label: l10n.headerVideoTitle,
                      icon: RI.RiVideoLine,
                      selectedIcon: RI.RiVideoLine,
                      isSelected: selectedCategory == TaskCategory.video,
                      onTap: () => ref
                          .read(selectedCategoryProvider.notifier)
                          .setCategory(TaskCategory.video),
                      colorScheme: colorScheme,
                      isMinimized: true,
                    ),
                    _SidebarItem(
                      label: l10n.headerMusicTitle,
                      icon: RI.RiMusicLine,
                      selectedIcon: RI.RiMusicLine,
                      isSelected: selectedCategory == TaskCategory.music,
                      onTap: () => ref
                          .read(selectedCategoryProvider.notifier)
                          .setCategory(TaskCategory.music),
                      colorScheme: colorScheme,
                      isMinimized: true,
                    ),
                    _SidebarItem(
                      label: l10n.headerFileTitle,
                      icon: RI.RiFolderLine,
                      selectedIcon: RI.RiFolderOpenLine,
                      isSelected: selectedCategory == TaskCategory.generic,
                      onTap: () => ref
                          .read(selectedCategoryProvider.notifier)
                          .setCategory(TaskCategory.generic),
                      colorScheme: colorScheme,
                      isMinimized: true,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Divider(
                          height: 1,
                          indent: 16,
                          endIndent: 16,
                          color: colorScheme.outlineVariant),
                    ),
                    _SidebarItem(
                      label: l10n.headerInProgressTitle,
                      icon: RI.RiDownloadLine,
                      selectedIcon: RI.RiDownloadLine,
                      isSelected: selectedCategory == TaskCategory.inprogress,
                      onTap: () => ref
                          .read(selectedCategoryProvider.notifier)
                          .setCategory(TaskCategory.inprogress),
                      colorScheme: colorScheme,
                      isMinimized: true,
                    ),
                    _SidebarItem(
                      label: l10n.headerFailedTitle,
                      icon: RI.RiErrorWarningLine,
                      selectedIcon: RI.RiErrorWarningLine,
                      isSelected: selectedCategory == TaskCategory.failed,
                      onTap: () => ref
                          .read(selectedCategoryProvider.notifier)
                          .setCategory(TaskCategory.failed),
                      colorScheme: colorScheme,
                      isMinimized: true,
                    ),
                  ] else ...[
                    _SidebarGroup(
                      title: l10n.library,
                      icon: RI.RiBookLine,
                      isExpanded: _isLibraryExpanded,
                      onToggle: () => setState(
                          () => _isLibraryExpanded = !_isLibraryExpanded),
                      children: [
                        _SidebarItem(
                          label: l10n.categoryHome,
                          icon: RI.RiShadowLine,
                          selectedIcon: RI.RiShadowLine,
                          isSelected: selectedCategory == TaskCategory.home,
                          onTap: () => ref
                              .read(selectedCategoryProvider.notifier)
                              .setCategory(TaskCategory.home),
                          colorScheme: colorScheme,
                          isHome: true,
                        ),
                        _SidebarItem(
                          label: l10n.headerVideoTitle,
                          icon: RI.RiVideoLine,
                          selectedIcon: RI.RiVideoLine,
                          isSelected: selectedCategory == TaskCategory.video,
                          onTap: () => ref
                              .read(selectedCategoryProvider.notifier)
                              .setCategory(TaskCategory.video),
                          colorScheme: colorScheme,
                          count: getCount(TaskCategory.video),
                        ),
                        _SidebarItem(
                          label: l10n.headerMusicTitle,
                          icon: RI.RiMusicLine,
                          selectedIcon: RI.RiMusicLine,
                          isSelected: selectedCategory == TaskCategory.music,
                          onTap: () => ref
                              .read(selectedCategoryProvider.notifier)
                              .setCategory(TaskCategory.music),
                          colorScheme: colorScheme,
                          count: getCount(TaskCategory.music),
                        ),
                        _SidebarItem(
                          label: l10n.headerFileTitle,
                          icon: RI.RiFolderOpenLine,
                          selectedIcon: RI.RiFolderOpenLine,
                          isSelected: selectedCategory == TaskCategory.generic,
                          onTap: () => ref
                              .read(selectedCategoryProvider.notifier)
                              .setCategory(TaskCategory.generic),
                          colorScheme: colorScheme,
                          count: getCount(TaskCategory.generic),
                        ),
                      ],
                    ),
                    _SidebarGroup(
                      title: l10n.downloadingTitle,
                      icon: RI.RiCloudLine,
                      isExpanded: _isDownloadsExpanded,
                      onToggle: () => setState(
                          () => _isDownloadsExpanded = !_isDownloadsExpanded),
                      children: [
                        _SidebarItem(
                          label: l10n.headerInProgressTitle,
                          icon: RI.RiDownloadLine,
                          selectedIcon: RI.RiDownloadLine,
                          isSelected:
                              selectedCategory == TaskCategory.inprogress,
                          onTap: () => ref
                              .read(selectedCategoryProvider.notifier)
                              .setCategory(TaskCategory.inprogress),
                          colorScheme: colorScheme,
                          count: getInProgressCount(),
                        ),
                        _SidebarItem(
                          label: l10n.headerFailedTitle,
                          icon: RI.RiErrorWarningLine,
                          selectedIcon: RI.RiErrorWarningLine,
                          isSelected: selectedCategory == TaskCategory.failed,
                          onTap: () => ref
                              .read(selectedCategoryProvider.notifier)
                              .setCategory(TaskCategory.failed),
                          colorScheme: colorScheme,
                          count: getFailedCount(),
                        ),
                      ],
                    ),
                  ]
                ],
              ),
            ),
          ),
          // Audio Player Bar
          const AudioPlayerBar(),
          Padding(
            padding:
                EdgeInsets.symmetric(horizontal: widget.isMinimized ? 0 : 14),
            child: _SidebarItem(
              label: l10n.settings,
              icon: RI.RiSettingsLine,
              selectedIcon: RI.RiSettingsLine,
              isSettings: true,
              isSelected: selectedCategory == TaskCategory.settings,
              onTap: () => ref
                  .read(selectedCategoryProvider.notifier)
                  .setCategory(TaskCategory.settings),
              colorScheme: colorScheme,
              hideCount: true,
              isMinimized: widget.isMinimized,
            ),
          ),
        ],
      ),
    );
  }
}

class _SidebarGroup extends StatelessWidget {
  final String title;
  final FIconObject icon;
  final bool isExpanded;
  final VoidCallback onToggle;
  final List<Widget> children;

  const _SidebarGroup({
    required this.title,
    required this.icon,
    required this.isExpanded,
    required this.onToggle,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Clickable Header
        InkWell(
          onTap: onToggle,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding:
                const EdgeInsets.only(left: 16, right: 14, top: 8, bottom: 10),
            child: Row(
              children: [
                FIcon(icon, size: 18, color: colorScheme.onSurfaceVariant),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    title,
                    style: GoogleFonts.montserrat(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurfaceVariant,
                      letterSpacing: 0.5,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                AnimatedRotation(
                  turns: isExpanded ? 0 : -0.25,

                  // 0 = down, -0.25 = right
                  duration: const Duration(milliseconds: 200),
                  child: FIcon(RI.RiArrowDownSLine,
                      size: 18, color: colorScheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
        ),

        // Animated Content
        AnimatedCrossFade(
          firstChild: Padding(
            padding: const EdgeInsets.only(left: 20, right: 14),
            child: Column(children: children),
          ),
          secondChild: const SizedBox(width: double.infinity),
          crossFadeState:
              isExpanded ? CrossFadeState.showFirst : CrossFadeState.showSecond,
          duration: const Duration(milliseconds: 200),
        ),
        if (isExpanded) const SizedBox(height: 8),
      ],
    );
  }
}

class _SidebarItem extends StatelessWidget {
  final String label;
  final FIconObject icon;
  final FIconObject selectedIcon;
  final bool isSelected;
  final VoidCallback onTap;
  final ColorScheme colorScheme;
  final int count;
  final bool isHome;
  final bool hideCount;
  final bool isSettings;
  final bool isMinimized;

  const _SidebarItem({
    required this.label,
    required this.icon,
    required this.selectedIcon,
    required this.isSelected,
    required this.onTap,
    required this.colorScheme,
    this.count = 0,
    this.isHome = false,
    this.hideCount = false,
    this.isSettings = false,
    this.isMinimized = false,
  });

  @override
  Widget build(BuildContext context) {
    final activeColor = colorScheme.primary;
    final inactiveColor = colorScheme.onSurfaceVariant;

    if (isMinimized) {
      return Tooltip(
        message: label,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: InkWell(
            onTap: onTap,
            splashColor: Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isSelected
                    ? colorScheme.tertiary

                    // Subtle background for selection
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: FIcon(
                  isSelected ? selectedIcon : icon,
                  size: 24,
                  color: isSelected ? activeColor : inactiveColor,
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          splashColor: Colors.transparent,
          hoverColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected
                  ? colorScheme.tertiary

                  // Subtle background for selection
                  : Colors.transparent,
              borderRadius: const BorderRadius.all(Radius.circular(12)),
              border: isSelected
                  ? Border.all(
                      color: colorScheme.primary.withOpacity(0.15), width: 1)
                  : null,
            ),
            child: Row(
              children: [
                // Animated Icon
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: FIcon(
                    isSelected ? selectedIcon : icon,
                    key: ValueKey(isSelected),
                    size: 20,
                    color: isSelected ? activeColor : inactiveColor,
                  ),
                ),
                const SizedBox(width: 12),

                // Label
                Expanded(
                  child: Text(
                    label,
                    style: GoogleFonts.montserrat(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w500,
                      color: isSelected ? colorScheme.onSurface : inactiveColor,
                    ),
                  ),
                ),

                // Counter Badge (Pill Style)
                if (!hideCount && count > 0)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? colorScheme.primary.withOpacity(0.1)

                          // If active, primary color
                          : colorScheme.surfaceContainerHighest,

                      // If inactive, gray
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      count.toString(),
                      style: GoogleFonts.montserrat(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: isSelected ? activeColor : inactiveColor,
                      ),
                    ),
                  ),

                if (isSettings)
                  FIcon(RI.RiArrowRightSLine, size: 18, color: inactiveColor)
              ],
            ),
          ),
        ),
      ),
    );
  }
}

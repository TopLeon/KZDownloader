import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kzdownloader/core/download/providers/download_provider.dart';
import 'package:kzdownloader/l10n/arb/app_localizations.dart';
import 'package:kzdownloader/models/download_task.dart';
import 'package:kzdownloader/views/chat/widgets/audio_player_bar.dart';
import 'package:kzdownloader/views/chat/widgets/download_status_widget.dart';
import 'package:ultimate_flutter_icons/ficon.dart';
import 'package:ultimate_flutter_icons/icons/ri.dart';
import 'package:window_manager/window_manager.dart';

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

class _SidebarState extends ConsumerState<Sidebar>
    with SingleTickerProviderStateMixin {
  bool _isLibraryExpanded = true;
  bool _isDownloadsExpanded = true;

  @override
  Widget build(BuildContext context) {
    final selectedCategory = ref.watch(selectedCategoryProvider);
    final downloadList = ref.watch(downloadListProvider).asData?.value ?? [];
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    int getCount(TaskCategory cat) {
      if (cat == TaskCategory.video) {
        return downloadList
            .where((t) => t.category == cat && t.playlistParentId == null)
            .length;
      } else if (cat == TaskCategory.music) {
        return downloadList
            .where((t) => t.category == cat && !t.isPlaylistContainer)
            .length;
      } else {
        return downloadList.where((t) => t.category == cat).length;
      }
    }

    int getInProgressCount() => downloadList
        .where((t) =>
            t.downloadStatus == WorkStatus.running &&
                t.playlistParentId == null ||
            t.summaryStatus.isActive)
        .length;

    int getFailedCount() => downloadList
        .where((t) =>
            t.downloadStatus == WorkStatus.failed && t.playlistParentId == null)
        .length;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
      width: widget.isMinimized ? 80 : 235,
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
              child: _AnimatedSidebarIconButton(
                onTap: widget.onToggle ?? () {},
                icon: FIcon(RI.RiSideBarFill,
                    size: 24, color: colorScheme.primary),
              ),
            )
          else
            DragToMoveArea(
              child: Padding(
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
                        fontWeight: FontWeight.w500,
                        color: colorScheme.onSurface,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const Spacer(),
                    if (widget.onToggle != null)
                      _AnimatedSidebarIconButton(
                        onTap: widget.onToggle!,
                        icon: FIcon(RI.RiSideBarFill,
                            size: 18, color: colorScheme.onSurfaceVariant),
                      ),
                  ],
                ),
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
          if (!widget.isMinimized) const AudioPlayerBar(),

          DownloadStatusWidget(isMinimized: widget.isMinimized),

          const SizedBox(height: 16),
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

// ── Animated icon button for the toggle ───────────────────────────────────────

class _AnimatedSidebarIconButton extends StatefulWidget {
  final VoidCallback onTap;
  final Widget icon;

  const _AnimatedSidebarIconButton({
    required this.onTap,
    required this.icon,
  });

  @override
  State<_AnimatedSidebarIconButton> createState() =>
      _AnimatedSidebarIconButtonState();
}

class _AnimatedSidebarIconButtonState extends State<_AnimatedSidebarIconButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scale = Tween<double>(begin: 1.0, end: 0.88).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _onTapDown(_) => _ctrl.forward();
  void _onTapUp(_) {
    _ctrl.reverse();
    widget.onTap();
  }

  void _onTapCancel() => _ctrl.reverse();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: ScaleTransition(
        scale: _scale,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: widget.icon,
          ),
        ),
      ),
    );
  }
}

// ── Sidebar group ──────────────────────────────────────────────────────────────

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
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeOutCubic,
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
          duration: const Duration(milliseconds: 250),
          firstCurve: Curves.easeOutCubic,
          secondCurve: Curves.easeInCubic,
          sizeCurve: Curves.easeOutCubic,
        ),
        if (isExpanded) const SizedBox(height: 8),
      ],
    );
  }
}

// ── Sidebar item ───────────────────────────────────────────────────────────────

class _SidebarItem extends StatefulWidget {
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
  State<_SidebarItem> createState() => _SidebarItemState();
}

class _SidebarItemState extends State<_SidebarItem>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pressCtrl;
  late final Animation<double> _pressScale;
  bool _isHovered = false;
  bool _labelVisible = false;

  @override
  void initState() {
    super.initState();
    _pressCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );
    _pressScale = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _pressCtrl, curve: Curves.easeInOut),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() => _labelVisible = true);
    });
  }

  @override
  void dispose() {
    _pressCtrl.dispose();
    super.dispose();
  }

  void _onTapDown(_) => _pressCtrl.forward();
  void _onTapUp(_) {
    _pressCtrl.reverse();
    widget.onTap();
  }

  void _onTapCancel() => _pressCtrl.reverse();

  @override
  Widget build(BuildContext context) {
    final activeColor = widget.colorScheme.primary;
    final inactiveColor = widget.colorScheme.onSurfaceVariant;

    if (widget.isMinimized) {
      return Tooltip(
        message: widget.label,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: GestureDetector(
            onTapDown: _onTapDown,
            onTapUp: _onTapUp,
            onTapCancel: _onTapCancel,
            child: ScaleTransition(
              scale: _pressScale,
              child: MouseRegion(
                onEnter: (_) => setState(() => _isHovered = true),
                onExit: (_) => setState(() => _isHovered = false),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOutCubic,
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: widget.isSelected
                        ? widget.colorScheme.tertiary
                        : _isHovered
                            ? widget.colorScheme.tertiary.withOpacity(0.6)
                            : widget.colorScheme.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: widget.isSelected
                        ? Border.all(
                            color: widget.colorScheme.primary.withOpacity(0.15),
                            width: 1)
                        : null,
                  ),
                  child: Center(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 180),
                      child: FIcon(
                        widget.isSelected ? widget.selectedIcon : widget.icon,
                        key: ValueKey(widget.isSelected),
                        size: 22,
                        color: widget.isSelected ? activeColor : inactiveColor,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: GestureDetector(
        onTapDown: _onTapDown,
        onTapUp: _onTapUp,
        onTapCancel: _onTapCancel,
        child: ScaleTransition(
          scale: _pressScale,
          child: MouseRegion(
            onEnter: (_) => setState(() => _isHovered = true),
            onExit: (_) => setState(() => _isHovered = false),
            cursor: SystemMouseCursors.click,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOutCubic,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: widget.isSelected
                    ? widget.colorScheme.tertiary
                    : _isHovered
                        ? widget.colorScheme.tertiary.withOpacity(0.5)
                        : widget.colorScheme.surface,
                borderRadius: const BorderRadius.all(Radius.circular(12)),
                boxShadow: [
                  if (widget.isSelected)
                    BoxShadow(
                      color: widget.colorScheme.shadow.withOpacity(0.025),
                      blurRadius: 20,
                      offset: const Offset(0, 2),
                    )
                ],
                border: widget.isSelected
                    ? Border.all(
                        color: widget.colorScheme.primary.withOpacity(0.15),
                        width: 1)
                    : null,
              ),
              child: Row(
                children: [
                  // Animated Icon
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 180),
                    child: FIcon(
                      widget.isSelected ? widget.selectedIcon : widget.icon,
                      key: ValueKey(widget.isSelected),
                      size: 20,
                      color: widget.isSelected ? activeColor : inactiveColor,
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Label with animated color
                  Expanded(
                    child: AnimatedOpacity(
                      opacity: _labelVisible ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 220),
                      curve: Curves.easeOutCubic,
                      child: AnimatedSlide(
                        offset: _labelVisible
                            ? Offset.zero
                            : const Offset(-0.1, 0),
                        duration: const Duration(milliseconds: 220),
                        curve: Curves.easeOutCubic,
                        child: AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 200),
                          curve: Curves.easeOutCubic,
                          style: GoogleFonts.montserrat(
                            fontSize: 13.5,
                            fontWeight: widget.isSelected
                                ? FontWeight.w600
                                : FontWeight.w500,
                            color: widget.isSelected
                                ? widget.colorScheme.onSurface
                                : inactiveColor,
                          ),
                          child: Text(widget.label),
                        ),
                      ),
                    ),
                  ),

                  // Counter Badge — animated switcher
                  if (!widget.hideCount && widget.count > 0)
                    AnimatedOpacity(
                      opacity: _labelVisible ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeOutCubic,
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        transitionBuilder: (child, anim) => ScaleTransition(
                          scale: anim,
                          child: FadeTransition(opacity: anim, child: child),
                        ),
                        child: Container(
                          key: ValueKey(widget.count),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: widget.isSelected
                                ? widget.colorScheme.primary.withOpacity(0.1)
                                : widget.colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            widget.count.toString(),
                            style: GoogleFonts.montserrat(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: widget.isSelected
                                  ? activeColor
                                  : inactiveColor,
                            ),
                          ),
                        ),
                      ),
                    ),

                  if (widget.isSettings)
                    AnimatedOpacity(
                      opacity: _isHovered ? 1.0 : 0.5,
                      duration: const Duration(milliseconds: 200),
                      child: FIcon(RI.RiArrowRightSLine,
                          size: 18, color: inactiveColor),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

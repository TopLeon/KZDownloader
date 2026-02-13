import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Enum for the type of settings tile.
enum SettingsTileType {
  navigation,

  // With right arrow
  toggle,

  // With switch
  dropdown,

  // With dropdown
  action,

  // With clickable icon
  info,

  // Just info text
}

// Reusable settings tile widget with glassmorphism style.
class SettingsTile extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onTap;
  final SettingsTileType type;
  final bool isDestructive;
  final bool showDivider;

  const SettingsTile({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.onTap,
    this.type = SettingsTileType.navigation,
    this.isDestructive = false,
    this.showDivider = true,
  });

  // Factory for tile with switch.
  factory SettingsTile.toggle({
    required String title,
    String? subtitle,
    IconData? leadingIcon,
    required bool value,
    required ValueChanged<bool> onChanged,
    bool showDivider = true,
  }) {
    return SettingsTile(
      title: title,
      subtitle: subtitle,
      leading: leadingIcon != null ? Icon(leadingIcon) : null,
      type: SettingsTileType.toggle,
      showDivider: showDivider,
      trailing: Switch.adaptive(value: value, onChanged: onChanged),
      onTap: () => onChanged(!value),
    );
  }

  // Factory for action tile (e.g. delete).
  factory SettingsTile.action({
    required String title,
    String? subtitle,
    IconData? leadingIcon,
    required IconData actionIcon,
    required VoidCallback onAction,
    bool isDestructive = false,
    bool showDivider = true,
  }) {
    return SettingsTile(
      title: title,
      subtitle: subtitle,
      leading: leadingIcon != null ? Icon(leadingIcon) : null,
      type: SettingsTileType.action,
      isDestructive: isDestructive,
      showDivider: showDivider,
      onTap: onAction,
      trailing: Builder(
        builder: (context) => Icon(
          actionIcon,
          color: isDestructive
              ? Theme.of(context).colorScheme.error
              : Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final titleColor =
        isDestructive ? colorScheme.error : colorScheme.onSurface;
    final iconColor = isDestructive
        ? colorScheme.error
        : colorScheme.primary.withOpacity(0.8);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                if (leading != null) ...[
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: iconColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: IconTheme(
                      data: IconThemeData(size: 20, color: iconColor),
                      child: leading!,
                    ),
                  ),
                  const SizedBox(width: 14),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w500,
                          color: titleColor,
                        ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          subtitle!,
                          style: textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (trailing != null) trailing!,
                if (type == SettingsTileType.navigation && trailing == null)
                  Icon(
                    Icons.chevron_right_rounded,
                    color: colorScheme.onSurfaceVariant.withOpacity(0.5),
                  ),
              ],
            ),
          ),
        ),
        if (showDivider)
          Padding(
            padding: EdgeInsets.only(
              left: leading != null ? 58 : 16,
              right: 16,
            ),
            child: Divider(
              height: 1,
              color: colorScheme.outlineVariant.withOpacity(0.3),
            ),
          ),
      ],
    );
  }
}

// Container with glassmorphism effect to group settings.
class SettingsSection extends StatelessWidget {
  final String? title;
  final List<Widget> children;

  const SettingsSection({super.key, this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isLightTheme = Theme.of(context).brightness == Brightness.light;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null) ...[
          Padding(
            padding: const EdgeInsets.only(bottom: 12, left: 4),
            child: Text(
              title!.toUpperCase(),
              style: GoogleFonts.montserrat(
                color: colorScheme.primary,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.2,
                fontSize: 12,
              ),
            ),
          ),
        ],
        Container(
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: colorScheme.primary.withOpacity(0.15)),
            boxShadow: [
              BoxShadow(
                color: isLightTheme
                    ? colorScheme.shadow.withOpacity(0.1)
                    : colorScheme.shadow.withOpacity(0.2),
                blurRadius: 2,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Column(
              children: [
                for (int i = 0; i < children.length; i++)
                  if (children[i] is SettingsTile)
                    SettingsTile(
                      title: (children[i] as SettingsTile).title,
                      subtitle: (children[i] as SettingsTile).subtitle,
                      leading: (children[i] as SettingsTile).leading,
                      trailing: (children[i] as SettingsTile).trailing,
                      onTap: (children[i] as SettingsTile).onTap,
                      type: (children[i] as SettingsTile).type,
                      isDestructive:
                          (children[i] as SettingsTile).isDestructive,
                      showDivider: i < children.length - 1,
                    )
                  else
                    children[i],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

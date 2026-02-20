import 'package:flutter/material.dart';

// Custom window control button for non-macOS platforms.
class WindowButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final bool isClose;

  const WindowButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.isClose = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      hoverColor: isClose
          ? Theme.of(context).colorScheme.error
          : Theme.of(context).brightness == Brightness.light
              ? Colors.black.withOpacity(0.1)
              : Colors.white.withOpacity(0.1),
      child: Container(
        width: 32,
        height: 16,
        alignment: Alignment.center,
        child: Icon(
          icon,
          size: 16,
          color: Theme.of(context).brightness == Brightness.light
              ? Colors.black87
              : Colors.white70,
        ),
      ),
    );
  }
}

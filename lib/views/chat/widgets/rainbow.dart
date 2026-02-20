import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ultimate_flutter_icons/ficon.dart';

// A widget that paints a rotating rainbow gradient border around its child.
class RainbowAnimatedBorderForever extends StatefulWidget {
  const RainbowAnimatedBorderForever(
      {super.key,
      required this.child,
      required this.disabled,
      required this.borderRadius});

  final Widget child;
  final bool disabled;
  final double borderRadius;

  @override
  State<RainbowAnimatedBorderForever> createState() =>
      _RainbowAnimatedBorderForeverState();
}

class _RainbowAnimatedBorderForeverState
    extends State<RainbowAnimatedBorderForever>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.disabled) {
      return widget.child;
    }
    return Stack(
      children: [
        Positioned.fill(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return CustomPaint(
                painter: _CometBorderPainter2(
                  progress: _controller.value,
                  borderWidth: 2,
                  radius: widget.borderRadius + 2,
                ),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(2),
          child: widget.child,
        ),
      ],
    );
  }
}

class AiButton extends StatefulWidget {
  const AiButton({super.key, required this.text, required this.icon});

  final String text;
  final FIconObject icon;

  @override
  State<AiButton> createState() => _AiButtonState();
}

class _AiButtonState extends State<AiButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isAnimating = true;
  final double _borderRadius = 16.0;
  final double _strokeWidth = 2.0;
  final Duration _animationDuration = const Duration(milliseconds: 2000);

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    Timer(_animationDuration, () {
      if (mounted) {
        setState(() {
          _isAnimating = false;
          _controller.stop();
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.surface;
    final staticBorderColor =
        Theme.of(context).colorScheme.primary.withOpacity(0.15);

    return MouseRegion(
      onEnter: (event) => setState(() {
        _isAnimating = true;
        _controller.repeat();
      }),
      onExit: (event) => setState(() {
        _isAnimating = false;
        _controller.stop();
      }),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned.fill(
            child: AnimatedOpacity(
              opacity: _isAnimating ? 1 : 0,
              duration: const Duration(milliseconds: 300),
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return CustomPaint(
                    painter: _CometBorderPainter2(
                      progress: _controller.value,
                      borderWidth: _strokeWidth,
                      radius: _borderRadius + _strokeWidth,
                    ),
                  );
                },
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(_strokeWidth),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(_borderRadius),
                border: _isAnimating
                    ? Border.all(color: Colors.transparent, width: 1)
                    : Border.all(color: staticBorderColor, width: 1),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FIcon(widget.icon),
                  const SizedBox(width: 8),
                  Text(
                    widget.text,
                    style: GoogleFonts.montserrat(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class RainbowAnimatedBorder extends StatefulWidget {
  const RainbowAnimatedBorder({
    super.key,
    required this.child,
    this.borderRadius = 16.0,
    this.strokeWidth = 2.0,
    this.animationDuration = const Duration(seconds: 2),
    this.fadeOutDuration = const Duration(seconds: 3),
    this.enableHover = true,
    this.colors,
  });

  final Widget child;
  final double borderRadius;
  final double strokeWidth;
  final Duration animationDuration;
  final Duration fadeOutDuration;
  final bool enableHover;
  final List<Color>? colors;

  @override
  State<RainbowAnimatedBorder> createState() => _RainbowAnimatedBorderState();
}

class _RainbowAnimatedBorderState extends State<RainbowAnimatedBorder>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isAnimating = true;
  Timer? _fadeTimer;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
    )..repeat();

    _startFadeTimer();
  }

  void _startFadeTimer() {
    _fadeTimer?.cancel();
    _fadeTimer = Timer(widget.fadeOutDuration, () {
      if (mounted) {
        setState(() {
          _isAnimating = false;
          _controller.stop();
        });
      }
    });
  }

  @override
  void dispose() {
    _fadeTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget content = Stack(
      alignment: Alignment.center,
      children: [
        Positioned.fill(
          child: AnimatedOpacity(
            opacity: _isAnimating ? 1 : 0,
            duration: const Duration(milliseconds: 300),
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return CustomPaint(
                  painter: _CometBorderPainter2(
                    progress: _controller.value,
                    borderWidth: widget.strokeWidth,
                    radius: widget.borderRadius + widget.strokeWidth,
                    colors: widget.colors,
                  ),
                );
              },
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.all(widget.strokeWidth),
          child: widget.child,
        ),
      ],
    );

    if (widget.enableHover) {
      content = MouseRegion(
        onEnter: (event) => setState(() {
          _isAnimating = true;
          _controller.repeat();
          //_startFadeTimer();
        }),
        onExit: (event) => setState(() {
          _isAnimating = false;
          _controller.stop();
          //_fadeTimer?.cancel();
        }),
        child: content,
      );
    }

    return content;
  }
}

class _CometBorderPainter2 extends CustomPainter {
  final double progress;
  final double borderWidth;
  final double radius;
  final List<Color>? colors;

  _CometBorderPainter2({
    required this.progress,
    required this.borderWidth,
    required this.radius,
    this.colors,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final rRect = RRect.fromRectAndRadius(rect, Radius.circular(radius));

    final gradientColors = colors ??
        [
          Colors.transparent,
          const Color.fromARGB(255, 26, 50, 230),
          const Color(0xFF4285F4),
          Colors.cyan,
          Colors.transparent,
        ];

    final stops = [0.0, 0.15, 0.3, 0.45, 0.6];
    final maxDim = math.max(size.width, size.height);
    final squareRect =
        Rect.fromCenter(center: rect.center, width: maxDim, height: maxDim);

    final sweepGradient = SweepGradient(
      colors: gradientColors,
      stops: stops,
      transform: GradientRotation(progress * 2 * math.pi),
    );

    final shader = sweepGradient.createShader(squareRect);

    // Glow layer: same stroke but wider and blurred.
    final glowPaint = Paint()
      ..shader = shader
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = borderWidth * 3
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20);

    canvas.drawRRect(rRect, glowPaint);

    final paint = Paint()
      ..shader = shader
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = borderWidth;

    canvas.drawRRect(rRect, paint);
  }

  @override
  bool shouldRepaint(covariant _CometBorderPainter2 oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

/// An animated neon progress bar that flows the same comet colours used on
/// the card border (deep-blue → Google-blue → cyan → white shimmer).
class NeonProgressBar extends StatefulWidget {
  const NeonProgressBar({
    super.key,
    required this.value,
    this.height = 3.0,
    this.borderRadius = 2.0,
    this.backgroundColor,
    this.colors,
  });

  /// Fill amount from 0.0 to 1.0.
  final double value;
  final double height;
  final double borderRadius;
  final Color? backgroundColor;

  /// Override the neon gradient colours.
  final List<Color>? colors;

  @override
  State<NeonProgressBar> createState() => _NeonProgressBarState();
}

class _NeonProgressBarState extends State<NeonProgressBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = widget.backgroundColor ??
        Theme.of(context).colorScheme.primary.withOpacity(0.15);
    return SizedBox(
      height: widget.height,
      width: double.infinity,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) => CustomPaint(
          painter: _NeonProgressPainter(
            value: widget.value.clamp(0.0, 1.0),
            progress: _controller.value,
            backgroundColor: bgColor,
            borderRadius: widget.borderRadius,
            colors: widget.colors,
          ),
        ),
      ),
    );
  }
}

class _NeonProgressPainter extends CustomPainter {
  final double value;
  final double progress;
  final Color backgroundColor;
  final double borderRadius;
  final List<Color>? colors;

  _NeonProgressPainter({
    required this.value,
    required this.progress,
    required this.backgroundColor,
    required this.borderRadius,
    this.colors,
  });

  static const _defaultColors = [
    Color.fromARGB(255, 26, 50, 230),
    Color(0xFF4285F4),
    Colors.cyan,
    Color(0xFF4285F4),
    Color.fromARGB(255, 26, 50, 230),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final radius = Radius.circular(borderRadius);
    final bgRRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      radius,
    );

    // Draw background track
    canvas.drawRRect(bgRRect, Paint()..color = backgroundColor);

    if (value <= 0 || size.width <= 0) return;

    final fillWidth = size.width * value;
    final fillRect = Rect.fromLTWH(0, 0, fillWidth, size.height);
    final fillRRect = RRect.fromRectAndRadius(fillRect, radius);

    final gradientColors = colors ?? _defaultColors;

    // Animated gradient: shift horizontally using tileMode mirror so it tiles
    // seamlessly. The begin/end sweep over [-3, 1] → [−1, 3] across two
    // animation cycles, giving a continuous left→right flow.
    final shift = -1.0 + 2.0 * progress; // −1 … +1
    final gradient = LinearGradient(
      colors: gradientColors,
      tileMode: TileMode.mirror,
      begin: Alignment(-3.0 + shift * 2, 0),
      end: Alignment(-1.0 + shift * 2, 0),
    );

    final shaderRect = Rect.fromLTWH(0, 0, size.width, size.height);
    final shader = gradient.createShader(shaderRect);

    // Glow: draw a blurred, slightly expanded version of the fill behind the bar.
    final glowExpand = size.height * 1.5;
    final glowRect = Rect.fromLTRB(
      fillRect.left,
      fillRect.top - glowExpand,
      fillRect.right,
      fillRect.bottom + glowExpand,
    );
    final glowRRect = RRect.fromRectAndRadius(glowRect, Radius.circular(borderRadius + glowExpand));
    canvas.drawRRect(
      glowRRect,
      Paint()
        ..shader = gradient.createShader(shaderRect)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20),
    );

    // Clip to the filled portion then draw gradient across full width so the
    // animation looks continuous regardless of the fill fraction.
    canvas.save();
    canvas.clipRRect(fillRRect);
    canvas.drawRect(
      shaderRect,
      Paint()..shader = shader,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _NeonProgressPainter old) =>
      old.value != value || old.progress != progress;
}

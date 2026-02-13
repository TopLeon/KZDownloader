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
  final Duration _animationDuration = const Duration(seconds: 3);

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

    final paint = Paint()
      ..shader = sweepGradient.createShader(squareRect)
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

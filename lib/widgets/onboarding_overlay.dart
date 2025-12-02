import 'package:flutter/material.dart';

/// First Run Experience (FRE) - 3-Step Onboarding Overlay
/// Only shown once after first install
class OnboardingOverlay extends StatefulWidget {
  final VoidCallback onComplete;
  final Size screenSize;

  const OnboardingOverlay({
    super.key,
    required this.onComplete,
    required this.screenSize,
  });

  @override
  State<OnboardingOverlay> createState() => _OnboardingOverlayState();
}

class _OnboardingOverlayState extends State<OnboardingOverlay>
    with SingleTickerProviderStateMixin {
  int _currentStep = 0;
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  final List<OnboardingStep> _steps = [
    OnboardingStep(
      id: 'center_aperture',
      title: '点击此处，开启全知之眼。',
      subtitle: 'Tap here to open the All-Seeing Eye',
      position: OnboardingPosition.center,
      spotlightRadius: 120,
    ),
    OnboardingStep(
      id: 'arena_tab',
      title: '在这里，攻克你的弱点。',
      subtitle: 'Conquer your weaknesses here',
      position: OnboardingPosition.bottomLeft,
      spotlightRadius: 60,
    ),
    OnboardingStep(
      id: 'calculator_icon',
      title: '这里有你最顺手的武器。',
      subtitle: 'Your best weapon lies here',
      position: OnboardingPosition.topRight,
      spotlightRadius: 50,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < _steps.length - 1) {
      setState(() {
        _currentStep++;
      });
      _controller.reset();
      _controller.forward();
    } else {
      // Onboarding complete
      widget.onComplete();
    }
  }

  @override
  Widget build(BuildContext context) {
    final step = _steps[_currentStep];
    final spotlightOffset = _getSpotlightOffset(step.position);

    return GestureDetector(
      onTap: _nextStep,
      child: Stack(
        children: [
          // Semi-transparent black overlay with cutout
          CustomPaint(
            size: widget.screenSize,
            painter: SpotlightPainter(
              spotlightCenter: spotlightOffset,
              spotlightRadius: step.spotlightRadius,
              opacity: _fadeAnimation.value,
            ),
          ),

          // Pulsing spotlight ring
          Positioned(
            left: spotlightOffset.dx - step.spotlightRadius,
            top: spotlightOffset.dy - step.spotlightRadius,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: _PulsingRing(radius: step.spotlightRadius),
            ),
          ),

          // Text instruction
          Positioned(
            left: 0,
            right: 0,
            top: _getTextPosition(step.position),
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  children: [
                    Text(
                      step.title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      step.subtitle,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 14,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Progress dots
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        _steps.length,
                        (index) => Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: index == _currentStep ? 24 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: index == _currentStep
                                ? const Color(0xFF07C160)
                                : Colors.white.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Tap anywhere to continue',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.6),
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Skip button
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            right: 16,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: TextButton(
                onPressed: widget.onComplete,
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.white.withOpacity(0.1),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Text(
                  'Skip',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Offset _getSpotlightOffset(OnboardingPosition position) {
    final size = widget.screenSize;
    switch (position) {
      case OnboardingPosition.center:
        return Offset(size.width / 2, size.height / 2);
      case OnboardingPosition.bottomLeft:
        return Offset(size.width * 0.15, size.height - 60);
      case OnboardingPosition.topRight:
        return Offset(size.width - 50, MediaQuery.of(context).padding.top + 60);
    }
  }

  double _getTextPosition(OnboardingPosition position) {
    final size = widget.screenSize;
    switch (position) {
      case OnboardingPosition.center:
        return size.height * 0.3;
      case OnboardingPosition.bottomLeft:
        return size.height * 0.15;
      case OnboardingPosition.topRight:
        return MediaQuery.of(context).padding.top + 180;
    }
  }
}

/// Spotlight painter with circular cutout
class SpotlightPainter extends CustomPainter {
  final Offset spotlightCenter;
  final double spotlightRadius;
  final double opacity;

  SpotlightPainter({
    required this.spotlightCenter,
    required this.spotlightRadius,
    required this.opacity,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withOpacity(0.85 * opacity)
      ..style = PaintingStyle.fill;

    // Create path with hole
    final path = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addOval(
        Rect.fromCircle(center: spotlightCenter, radius: spotlightRadius),
      )
      ..fillType = PathFillType.evenOdd;

    canvas.drawPath(path, paint);

    // Add soft glow around cutout
    final glowPaint = Paint()
      ..color = const Color(0xFF07C160).withOpacity(0.3 * opacity)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20);

    canvas.drawCircle(spotlightCenter, spotlightRadius, glowPaint);
  }

  @override
  bool shouldRepaint(SpotlightPainter oldDelegate) {
    return oldDelegate.spotlightCenter != spotlightCenter ||
        oldDelegate.spotlightRadius != spotlightRadius ||
        oldDelegate.opacity != opacity;
  }
}

/// Pulsing ring animation around spotlight
class _PulsingRing extends StatefulWidget {
  final double radius;

  const _PulsingRing({required this.radius});

  @override
  State<_PulsingRing> createState() => _PulsingRingState();
}

class _PulsingRingState extends State<_PulsingRing>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Container(
          width: widget.radius * 2,
          height: widget.radius * 2,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: const Color(
                0xFF07C160,
              ).withOpacity(0.5 * (1 - _pulseAnimation.value)),
              width: 3,
            ),
          ),
        );
      },
    );
  }
}

/// Onboarding step data model
class OnboardingStep {
  final String id;
  final String title;
  final String subtitle;
  final OnboardingPosition position;
  final double spotlightRadius;

  const OnboardingStep({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.position,
    required this.spotlightRadius,
  });
}

/// Position presets for spotlight
enum OnboardingPosition { center, bottomLeft, topRight }

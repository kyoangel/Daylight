import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

enum CatType { orange, calico, siam, black }

class WalkingCatPet extends StatefulWidget {
  final CatType type;
  const WalkingCatPet({super.key, this.type = CatType.orange});

  @override
  State<WalkingCatPet> createState() => _WalkingCatPetState();
}

class _WalkingCatPetState extends State<WalkingCatPet> with TickerProviderStateMixin {
  double _x = 100;
  double _y = 200;
  double _direction = 1; // 1 = right, -1 = left
  bool _isJumping = false;
  double _jumpYOffset = 0;
  final double _speed = 45.0; // Slightly slower for more "strolling" feel
  final double _padding = 20.0;
  
  late Timer _timer;
  Timer? _jumpTimer;
  late AnimationController _walkCycleController;
  late AnimationController _tailWagController;
  DateTime? _lastTick;

  @override
  void initState() {
    super.initState();
    
    _walkCycleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..repeat();

    _tailWagController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    _timer = Timer.periodic(const Duration(milliseconds: 32), (timer) {
      _updatePosition();
    });

    _scheduleNextJump();
  }

  void _scheduleNextJump() {
    _jumpTimer?.cancel();
    _jumpTimer = Timer(Duration(seconds: 8 + Random().nextInt(12)), () {
      if (mounted) {
        _triggerJump();
        _scheduleNextJump();
      }
    });
  }

  void _triggerJump() {
    if (_isJumping) return;
    setState(() => _isJumping = true);
    
    double peak = -50;
    int durationMs = 800;
    int steps = 30;
    int currentStep = 0;
    
    Timer.periodic(Duration(milliseconds: durationMs ~/ steps), (jumpTimer) {
      if (!mounted) {
        jumpTimer.cancel();
        return;
      }
      
      currentStep++;
      double t = currentStep / steps;
      setState(() {
        _jumpYOffset = 4 * peak * t * (1 - t);
      });

      if (currentStep >= steps) {
        jumpTimer.cancel();
        setState(() {
          _isJumping = false;
          _jumpYOffset = 0;
        });
      }
    });
  }

  void _updatePosition() {
    if (!mounted) return;
    final now = DateTime.now();
    if (_lastTick == null) {
      _lastTick = now;
      return;
    }
    final double dt = now.difference(_lastTick!).inMilliseconds / 1000.0;
    _lastTick = now;

    setState(() {
      final size = MediaQuery.of(context).size;
      _y = size.height - 180;
      _x += _direction * _speed * dt;

      if (_x > size.width - _padding - 50) {
        _x = size.width - _padding - 50;
        _direction = -1;
      } else if (_x < _padding) {
        _x = _padding;
        _direction = 1;
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _jumpTimer?.cancel();
    _walkCycleController.dispose();
    _tailWagController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: _x,
      top: _y + _jumpYOffset,
      child: IgnorePointer(
        child: AnimatedBuilder(
          animation: Listenable.merge([_walkCycleController, _tailWagController]),
          builder: (context, child) {
            // Drawn facing right, so if direction is 1 (right), use 1.0. If -1, flip to left.
            double scaleX = _direction == 1 ? 1.0 : -1.0;
            return Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()..scale(scaleX, 1.0),
              child: CustomPaint(
                size: const Size(60, 60),
                painter: _PixelCatPainter(
                  walkValue: _walkCycleController.value,
                  tailValue: _tailWagController.value,
                  isJumping: _isJumping,
                  type: widget.type,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _PixelCatPainter extends CustomPainter {
  final double walkValue;
  final double tailValue;
  final bool isJumping;
  final CatType type;

  _PixelCatPainter({
    required this.walkValue,
    required this.tailValue,
    required this.isJumping,
    required this.type,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Define colors based on type
    late Color primary;
    late Color secondary; // belly/face
    late Color detail;   // spots/eyes
    late Color detail2;  // eyes
    Color collar = Colors.transparent;

    switch (type) {
      case CatType.orange:
        primary = const Color(0xFFE8902A);
        secondary = Colors.white;
        detail = const Color(0xFFD67A1B);
        detail2 = const Color(0xFF2C2B2B);
        collar = const Color(0xFFCC3333);
        break;
      case CatType.calico:
        primary = Colors.white;
        secondary = const Color(0xFFE8902A);
        detail = const Color(0xFF4A4A4A);
        detail2 = const Color(0xFF2C2B2B);
        collar = const Color(0xFF4A4A4A);
        break;
      case CatType.siam:
        primary = Colors.white;
        secondary = const Color(0xFF5D5D5D);
        detail = const Color(0xFF5D5D5D);
        detail2 = const Color(0xFF33AAFF); // Blue eyes
        break;
      case CatType.black:
        primary = const Color(0xFF2C2B2B);
        secondary = const Color(0xFF2C2B2B);
        detail = const Color(0xFF1A1A1A);
        detail2 = const Color(0xFFFFAA00); // Orange eyes
        break;
    }

    final pMain = Paint()..color = primary;
    final pSec = Paint()..color = secondary;
    final pDet = Paint()..color = detail;
    final pDet2 = Paint()..color = detail2;
    final pCollar = Paint()..color = collar;
    final pOutline = Paint()..color = const Color(0xFF2C2B2B);
    
    const double s = 3.5; // Pixel size multiplier
    canvas.save();
    canvas.translate(size.width / 2 - 6 * s, size.height / 2);

    // 1. Legs Animation (Sine Wave)
    double legSwitch = isJumping ? 0 : sin(walkValue * 2 * pi);
    double legOffset = legSwitch * 1.5 * s;
    
    // Back legs
    canvas.drawRect(Rect.fromLTWH(2 * s + legOffset, 7 * s, 2 * s, 3 * s), pOutline); // Rear
    canvas.drawRect(Rect.fromLTWH(8 * s - legOffset, 7 * s, 2 * s, 3 * s), pOutline); // Front
    
    // 2. Body (with bounce)
    double bounce = isJumping ? 0 : (sin(walkValue * 2 * pi)).abs() * -1 * s;
    canvas.translate(0, bounce);

    // Body block
    canvas.drawRect(Rect.fromLTWH(0, 0, 11 * s, 7 * s), pMain);
    if (type == CatType.orange || type == CatType.siam) {
      canvas.drawRect(Rect.fromLTWH(0, 4 * s, 11 * s, 3 * s), pSec);
    } else if (type == CatType.calico) {
      canvas.drawRect(Rect.fromLTWH(0, 0, 4 * s, 4 * s), pDet); // Grey spot
      canvas.drawRect(Rect.fromLTWH(6 * s, 0, 5 * s, 3 * s), pSec); // Orange spot
    }

    // 3. Tail (Wagging) - keep behind body and away from face
    canvas.save();
    // Clip tail to the rear area to prevent overlapping the head.
    canvas.clipRect(Rect.fromLTWH(9 * s, -6 * s, 6 * s, 12 * s));
    canvas.translate(11 * s, 5 * s);
    canvas.rotate((tailValue - 0.5) * 0.3 - 0.12);
    canvas.drawRect(Rect.fromLTWH(0, -4 * s, 2 * s, 4 * s), pMain);
    if (type == CatType.calico) canvas.drawRect(Rect.fromLTWH(0, -4 * s, 2 * s, 2 * s), pSec);
    if (type == CatType.siam) canvas.drawRect(Rect.fromLTWH(0, -4 * s, 2 * s, 4 * s), pDet);
    canvas.restore();

    // 4. Head
    canvas.save();
    canvas.translate(-2 * s, -4 * s);
    canvas.drawRect(Rect.fromLTWH(0, 0, 8 * s, 7 * s), pMain); // Head base
    if (type == CatType.siam) canvas.drawRect(Rect.fromLTWH(0, 0, 8 * s, 4 * s), pDet);
    if (type == CatType.calico) canvas.drawRect(Rect.fromLTWH(0, 0, 4 * s, 4 * s), pDet);
    
    // Ears
    canvas.drawRect(Rect.fromLTWH(0, -2 * s, 2 * s, 2 * s), pMain);
    canvas.drawRect(Rect.fromLTWH(6 * s, -2 * s, 2 * s, 2 * s), pMain);
    if (type == CatType.siam) {
      canvas.drawRect(Rect.fromLTWH(0, -2 * s, 2 * s, 2 * s), pDet);
      canvas.drawRect(Rect.fromLTWH(6 * s, -2 * s, 2 * s, 2 * s), pDet);
    }

    // Face Detail
    if (type == CatType.orange) canvas.drawRect(Rect.fromLTWH(1 * s, 4 * s, 6 * s, 3 * s), pSec);
    
    // Eyes
    canvas.drawRect(Rect.fromLTWH(1 * s, 2 * s, 1.5 * s, 1.5 * s), pDet2);
    canvas.drawRect(Rect.fromLTWH(5.5 * s, 2 * s, 1.5 * s, 1.5 * s), pDet2);
    
    // Collar
    if (collar != Colors.transparent) {
      canvas.drawRect(Rect.fromLTWH(1 * s, 7 * s, 7 * s, 1 * s), pCollar);
    }

    canvas.restore();
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _PixelCatPainter oldDelegate) => true;
}

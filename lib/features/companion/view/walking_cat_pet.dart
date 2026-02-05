import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

class WalkingCatPet extends StatefulWidget {
  const WalkingCatPet({super.key});

  @override
  State<WalkingCatPet> createState() => _WalkingCatPetState();
}

class _WalkingCatPetState extends State<WalkingCatPet> with SingleTickerProviderStateMixin {
  double _x = 100;
  double _y = 200;
  double _direction = 1; // 1 for right, -1 for left
  bool _isJumping = false;
  double _jumpYOffset = 0;
  final double _speed = 50.0; // pixels per second
  final double _padding = 20.0;
  
  late Timer _timer;
  Timer? _jumpTimer;
  late AnimationController _bobController;
  DateTime? _lastTick;

  @override
  void initState() {
    super.initState();
    _bobController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    )..repeat(reverse: true);

    _timer = Timer.periodic(const Duration(milliseconds: 32), (timer) {
      _updatePosition();
    });

    // Randomly jump
    _scheduleNextJump();
  }

  void _scheduleNextJump() {
    _jumpTimer?.cancel();
    _jumpTimer = Timer(Duration(seconds: 5 + Random().nextInt(10)), () {
      if (mounted) {
        _triggerJump();
        _scheduleNextJump();
      }
    });
  }

  void _triggerJump() {
    if (_isJumping) return;
    setState(() => _isJumping = true);
    
    // Jump animation logic
    double startY = 0;
    double peak = -40;
    int durationMs = 800;
    int steps = 25;
    int currentStep = 0;
    
    Timer.periodic(Duration(milliseconds: durationMs ~/ steps), (jumpTimer) {
      if (!mounted) {
        jumpTimer.cancel();
        return;
      }
      
      currentStep++;
      double t = currentStep / steps; // 0.0 to 1.0
      // Parabolic jump: y = 4 * peak * t * (1 - t)
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
      final screenWidth = MediaQuery.of(context).size.width;
      
      // Keep it on a "line" - let's say bottom of the screen above the input
      _y = MediaQuery.of(context).size.height - 180;

      _x += _direction * _speed * dt;

      // Boundary check
      if (_x > screenWidth - _padding - 60) {
        _x = screenWidth - _padding - 60;
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
    _bobController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: _x,
      top: _y + _jumpYOffset,
      child: AnimatedBuilder(
        animation: _bobController,
        builder: (context, child) {
          double bobY = _isJumping ? 0 : _bobController.value * -4;
          return Transform.translate(
            offset: Offset(0, bobY),
            child: Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()
                ..scale(_direction == 1 ? -1.0 : 1.0, 1.0), // Flip based on direction
              child: Image.asset(
                'assets/icons/cute_cat_pet.png',
                width: 60,
                height: 60,
              ),
            ),
          );
        },
      ),
    );
  }
}

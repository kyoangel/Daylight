import 'dart:async';
import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

class WalkingCatPet extends StatefulWidget {
  const WalkingCatPet({super.key});

  @override
  State<WalkingCatPet> createState() => _WalkingCatPetState();
}

class _WalkingCatPetState extends State<WalkingCatPet> with TickerProviderStateMixin {
  double _x = 100;
  double _y = 200;
  double _direction = 1;
  bool _isJumping = false;
  double _jumpYOffset = 0;
  final double _speed = 65.0;
  final double _padding = 20.0;
  
  late Timer _timer;
  Timer? _jumpTimer;
  late AnimationController _waddleController;
  late Animation<double> _tiltAnimation;
  late Animation<double> _bounceAnimation;
  
  // Sprite state
  ui.Image? _spriteImage;
  int _currentFrame = 0;
  DateTime? _lastTick;
  ImageStream? _spriteStream;
  ImageStreamListener? _spriteListener;
  bool _spriteRequested = false;

  @override
  void initState() {
    super.initState();
    // Sprite load happens after dependencies are ready.
    _waddleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800), // Slower cycle for more relaxed walk
    )..repeat();

    // Tilt: Extremely subtle side-to-side shift
    _tiltAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 0.03).chain(CurveTween(curve: Curves.easeInOut)), weight: 25),
      TweenSequenceItem(tween: Tween(begin: 0.03, end: 0.0).chain(CurveTween(curve: Curves.easeInOut)), weight: 25),
      TweenSequenceItem(tween: Tween(begin: 0.0, end: -0.03).chain(CurveTween(curve: Curves.easeInOut)), weight: 25),
      TweenSequenceItem(tween: Tween(begin: -0.03, end: 0.0).chain(CurveTween(curve: Curves.easeInOut)), weight: 25),
    ]).animate(_waddleController);

    // Bounce: Very minimal vertical movement to simulate weight shift, not jumping
    _bounceAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: -1.5).chain(CurveTween(curve: Curves.easeInOut)), weight: 25),
      TweenSequenceItem(tween: Tween(begin: -1.5, end: 0.0).chain(CurveTween(curve: Curves.easeInOut)), weight: 25),
      TweenSequenceItem(tween: Tween(begin: 0.0, end: -1.5).chain(CurveTween(curve: Curves.easeInOut)), weight: 25),
      TweenSequenceItem(tween: Tween(begin: -1.5, end: 0.0).chain(CurveTween(curve: Curves.easeInOut)), weight: 25),
    ]).animate(_waddleController);

    _timer = Timer.periodic(const Duration(milliseconds: 32), (timer) {
      _updatePosition();
      if (!_isJumping) {
        _updateFrameFromController();
      }
    });

    _scheduleNextJump();
  }

  void _updateFrameFromController() {
    // Use only walk frames (0,1,2,1) to avoid the crouch frame during walking.
    const frameOrder = [0, 1, 2, 1];
    final int frame = frameOrder[(_waddleController.value * frameOrder.length).floor() % frameOrder.length];
    if (_currentFrame != frame) {
      setState(() {
        _currentFrame = frame;
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_spriteRequested) {
      _spriteRequested = true;
      _loadSprite();
    }
  }

  void _loadSprite() {
    if (_spriteStream != null && _spriteListener != null) {
      _spriteStream!.removeListener(_spriteListener!);
    }

    final provider = const AssetImage('assets/icons/cute_cat_spritesheet.png');
    final stream = provider.resolve(createLocalImageConfiguration(context));
    _spriteStream = stream;
    _spriteListener = ImageStreamListener((ImageInfo info, bool _) {
      if (!mounted) return;
      setState(() {
        _spriteImage = info.image;
      });
    });
    stream.addListener(_spriteListener!);
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
    setState(() {
      _isJumping = true;
      _currentFrame = 3;
    });
    
    double peak = -60;
    int durationMs = 800;
    int steps = 25;
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

      if (_x > size.width - _padding - 80) {
        _x = size.width - _padding - 80;
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
    _waddleController.dispose();
    if (_spriteStream != null && _spriteListener != null) {
      _spriteStream!.removeListener(_spriteListener!);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_spriteImage == null) {
      return const SizedBox.shrink();
    }

    return Positioned(
      left: _x,
      top: _y + _jumpYOffset,
      child: IgnorePointer(
        child: AnimatedBuilder(
          animation: _waddleController,
          builder: (context, child) {
            double stepBounce = _isJumping ? 0 : _bounceAnimation.value;
            double tilt = _isJumping ? 0 : _tiltAnimation.value;
            
            return Transform.translate(
              offset: Offset(0, stepBounce),
              child: Transform.rotate(
                angle: tilt,
                alignment: Alignment.bottomCenter,
                child: Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.identity()
                    ..scale(_direction == 1 ? 1.0 : -1.0, 1.0),
                  child: CustomPaint(
                    size: const Size(80, 80),
                    painter: _SpritePainter(_spriteImage!, _currentFrame),
                  ),
                ),
            ),
          );
          },
        ),
      ),
    );
  }
}

class _SpritePainter extends CustomPainter {
  final ui.Image image;
  final int frame;
  _SpritePainter(this.image, this.frame);

  @override
  void paint(Canvas canvas, Size size) {
    final width = image.width.toDouble();
    final height = image.height.toDouble();
    int cols = 2;
    int rows = 2;
    if (width >= height * 4) {
      cols = 4;
      rows = 1;
    } else if (height >= width * 4) {
      cols = 1;
      rows = 4;
    }

    final fw = width / cols;
    final fh = height / rows;
    final totalFrames = cols * rows;
    final safeFrame = frame % totalFrames;
    final col = safeFrame % cols;
    final row = safeFrame ~/ cols;
    
    Rect src = Rect.fromLTWH(col * fw, row * fh, fw, fh);
    Rect dst = Rect.fromLTWH(0, 0, size.width, size.height);
    
    canvas.drawImageRect(
      image, 
      src, 
      dst, 
      Paint()..filterQuality = ui.FilterQuality.medium
    );
  }

  @override
  bool shouldRepaint(_SpritePainter oldDelegate) => 
    oldDelegate.frame != frame || oldDelegate.image != image;
}

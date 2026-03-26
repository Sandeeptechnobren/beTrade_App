import 'dart:async';
import 'dart:math';
import 'package:betrade/presentation/auth/auth_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SuccessScreen extends StatefulWidget {
  const SuccessScreen({super.key});

  @override
  State<SuccessScreen> createState() => _SuccessScreenState();
}

class Particle {
  double x;
  double y;
  double speed;
  double size;
  double angle;
  double rotationSpeed;
  Color color;

  Particle({
    required this.x,
    required this.y,
    required this.speed,
    required this.size,
    required this.angle,
    required this.rotationSpeed,
    required this.color,
  });
}

class _SuccessScreenState extends State<SuccessScreen>
    with TickerProviderStateMixin {

  late AnimationController _emojiController;
  late Animation<double> _scaleAnim;

  final Random random = Random();
  List<Particle> particles = [];

  @override
  void initState() {
    super.initState();
    _emojiController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);

    _scaleAnim = Tween(begin: 0.9, end: 1.1).animate(
      CurvedAnimation(parent: _emojiController, curve: Curves.easeInOut),
    );

    for (int i = 0; i < 40; i++) {
      particles.add(_createParticle());
    }

    Timer.periodic(const Duration(milliseconds: 16), (timer) {
      if (!mounted) return;
      setState(() {
        for (var p in particles) {
          p.y += p.speed;
          p.x += sin(p.angle) * 0.002;
          p.angle += p.rotationSpeed;

          if (p.y > 1) {
            particles[particles.indexOf(p)] = _createParticle(top: true);
          }
        }
      });
    });
    Future.delayed(const Duration(seconds:2), () {
      if (!mounted) return;
  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>AuthScreen()));
    });
  }

  Particle _createParticle({bool top = false}) {
    return Particle(
      x: random.nextDouble(),
      y: top ? 0 : random.nextDouble(),
      speed: 0.003 + random.nextDouble() * 0.01,
      size: 4 + random.nextDouble() * 6,
      angle: random.nextDouble() * pi,
      rotationSpeed: (random.nextDouble() - 0.5) * 0.2,
      color: random.nextBool() ? Colors.white : Colors.purpleAccent,
    );
  }

  @override
  void dispose() {
    _emojiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              "assets/images/backgroundthread.png",
              fit: BoxFit.cover,
            ),
          ),
          ...particles.map((p) {
            return Positioned(
              left: p.x * 1.sw,
              top: p.y * 1.sh,
              child: Transform.rotate(
                angle: p.angle,
                child: Container(
                  width: p.size.w,
                  height: (p.size * 2).h,
                  decoration: BoxDecoration(
                    color: p.color,
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
              ),
            );
          }).toList(),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ScaleTransition(
                  scale: _scaleAnim,
                  child: Image.asset(
                    "assets/images/Emoji1.png",
                    height:376.h,
                  ),
                ),
                SizedBox(height: 20.h),
                Text(
                  "Sign Up \n successful 🎉",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 44.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    height: 0.9,
                  ),
                ),
                SizedBox(height: 30.h),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
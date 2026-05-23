// import 'dart:async';
// import 'dart:math';
// import 'package:betrade/presentation/auth/auth_screen.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
//
// class SuccessScreen extends StatefulWidget {
//   const SuccessScreen({super.key});
//
//   @override
//   State<SuccessScreen> createState() => _SuccessScreenState();
// }
//
// class Particle {
//   double x;
//   double y;
//   double speed;
//   double size;
//   double angle;
//   double rotationSpeed;
//   Color color;
//
//   Particle({
//     required this.x,
//     required this.y,
//     required this.speed,
//     required this.size,
//     required this.angle,
//     required this.rotationSpeed,
//     required this.color,
//   });
// }
//
// class _SuccessScreenState extends State<SuccessScreen>
//     with TickerProviderStateMixin {
//   late AnimationController _emojiController;
//   late Animation<double> _scaleAnim;
//
//   final Random random = Random();
//   List<Particle> particles = [];
//
//   @override
//   void initState() {
//     super.initState();
//     _emojiController = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 800),
//     )..repeat(reverse: true);
//
//     _scaleAnim = Tween(begin: 0.9, end: 1.1).animate(
//       CurvedAnimation(parent: _emojiController, curve: Curves.easeInOut),
//     );
//
//     for (int i = 0; i < 40; i++) {
//       particles.add(_createParticle());
//     }
//
//     Timer.periodic(const Duration(milliseconds: 16), (timer) {
//       if (!mounted) return;
//       setState(() {
//         for (var p in particles) {
//           p.y += p.speed;
//           p.x += sin(p.angle) * 0.002;
//           p.angle += p.rotationSpeed;
//
//           if (p.y > 1) {
//             particles[particles.indexOf(p)] = _createParticle(top: true);
//           }
//         }
//       });
//     });
//     Future.delayed(const Duration(seconds: 2), () {
//       if (!mounted) return;
//       Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>AuthScreen()));
//     });
//   }
//
//   Particle _createParticle({bool top = false}) {
//     return Particle(
//       x: random.nextDouble(),
//       y: top ? 0 : random.nextDouble(),
//       speed: 0.003 + random.nextDouble() * 0.01,
//       size: 4 + random.nextDouble() * 6,
//       angle: random.nextDouble() * pi,
//       rotationSpeed: (random.nextDouble() - 0.5) * 0.2,
//       color: random.nextBool() ? Colors.white : Colors.purpleAccent,
//     );
//   }
//
//   @override
//   void dispose() {
//     _emojiController.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Stack(
//         children: [
//           Positioned.fill(
//             child: Image.asset(
//               "assets/images/animationBg.png",
//               fit: BoxFit.cover,
//             ),
//           ),
//           Positioned.fill(
//             child: Image.asset("assets/images/CoverImg.png", fit: BoxFit.cover),
//           ),
//           ...particles.map((p) {
//             return Positioned(
//               left: p.x * 1.sw,
//               top: p.y * 1.sh,
//               child: Transform.rotate(
//                 angle: p.angle,
//                 child: Container(
//                   width: p.size.w,
//                   height: (p.size * 2).h,
//                   decoration: BoxDecoration(
//                     color: p.color,
//                     borderRadius: BorderRadius.circular(2.r),
//                   ),
//                 ),
//               ),
//             );
//           }).toList(),
//           Center(
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 ScaleTransition(
//                   scale: _scaleAnim,
//                   child: Image.asset("assets/images/Emoji1.png", height: 376.h),
//                 ),
//                 SizedBox(height: 20.h),
//                 Text(
//                   "Sign Up \n successful 🎉",
//                   textAlign: TextAlign.center,
//                   style: TextStyle(
//                     fontSize: 44.sp,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.white,
//                     height: 0.9,
//                   ),
//                 ),
//                 SizedBox(height: 30.h),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'dart:async';
import 'dart:math';
import 'package:betrade/data/services/local_storage.dart';
import 'package:betrade/presentation/screens/main_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SuccessScreen extends StatefulWidget {
  const SuccessScreen({super.key});

  @override
  State<SuccessScreen> createState() => _SuccessScreenState();
}

class Particle {
  double x, y, speed, size, angle, rotationSpeed;
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

  late AnimationController _entryController;
  late AnimationController _pulseController;

  late Animation<double> _moveX;
  late Animation<double> _moveY;
  late Animation<double> _entryScale;
  late Animation<double> _pulseScale;

  final Random random = Random();
  final List<Particle> particles = [];
  Timer? _particleTimer;

  @override
  void initState() {
    super.initState();

    /// ENTRY ANIMATION
    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    /// PULSE ANIMATION
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _moveX = Tween<double>(begin: -0.6, end: 0).animate(
      CurvedAnimation(parent: _entryController, curve: Curves.easeOutExpo),
    );

    _moveY = Tween<double>(begin: 0.8, end: 0).animate(
      CurvedAnimation(parent: _entryController, curve: Curves.easeOutExpo),
    );

    _entryScale = Tween<double>(begin: 0.1, end: 1).animate(
      CurvedAnimation(parent: _entryController, curve: Curves.easeOutBack),
    );

    _pulseScale = Tween<double>(begin: 0.9, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _entryController.forward();

    _entryController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _pulseController.repeat(reverse: true);
      }
    });

    /// PARTICLES
    for (int i = 0; i < 40; i++) {
      particles.add(_createParticle());
    }

    _particleTimer = Timer.periodic(const Duration(milliseconds: 16), (_) {
      if (!mounted) return;

      setState(() {
        for (int i = 0; i < particles.length; i++) {
          final p = particles[i];
          p.y += p.speed;
          p.x += sin(p.angle) * 0.002;
          p.angle += p.rotationSpeed;

          if (p.y > 1) {
            particles[i] = _createParticle(top: true);
          }
        }
      });
    });
    // After the success animation finishes, drop the user into the main
    // app. The signup OTP verify in step 2 has already persisted the
    // token, so they're already authenticated — sending them back to
    // AuthScreen here (the old behaviour) forced a redundant login.
    //
    // docUploadStatus = 0 surfaces the KYC banner inside MainScreen, which
    // satisfies the "verification should start immediately after signup"
    // requirement (issue #13).
    Future.delayed(const Duration(seconds: 4), () {
      if (!mounted) return;
      final docUploadStatus = LocalStorage.getDocUploadStatus() ?? 0;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => MainScreen(
            showWelcomePopup: true,
            docUploadStatus: docUploadStatus,
          ),
        ),
        (route) => false,
      );
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
    _particleTimer?.cancel();
    _entryController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              "assets/images/animationBg.png",
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: Image.asset(
              "assets/images/CoverImg.png",
              fit: BoxFit.cover,
            ),
          ),

          /// PARTICLES
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
          }),
              // .toList(),

          /// EMOJI + TEXT
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedBuilder(
                  animation: Listenable.merge([
                    _entryController,
                    _pulseController,
                  ]),
                  builder: (context, child) {
                    final t = _entryController.value;

                    double radius = (1 - t) * 160;
                    double angle = t * 3 * pi;

                    double dx = cos(angle) * radius;
                    double dy = sin(angle) * radius;

                    double baseX = _moveX.value * screenWidth;
                    double baseY = _moveY.value * screenHeight;

                    double finalX = baseX + dx;
                    double finalY = baseY + dy;

                    double scale;
                    if (t < 0.6) {
                      scale = _entryScale.value;
                    } else if (t < 1.0) {
                      scale = 1;
                    } else {
                      scale = _pulseScale.value;
                    }

                    return Transform.translate(
                      offset: Offset(finalX, finalY),
                      child: Transform.scale(
                        scale: scale,
                        child: child,
                      ),
                    );
                  },
                  child: Image.asset(
                    "assets/images/Emoji1.png",
                    height: 376.h,
                  ),
                ),
                SizedBox(height:20.h),
                Text(
                  "Sign Up\nSuccessful 🎉",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 44.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    height: 1.0,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
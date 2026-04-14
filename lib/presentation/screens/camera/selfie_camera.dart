// import 'package:betrade/presentation/screens/camera/selfie_preview_screen.dart';
// import 'package:camera/camera.dart';
// import 'package:flutter/material.dart';
//
// class SelfieCameraScreen extends StatefulWidget {
//   @override
//   State<SelfieCameraScreen> createState() => _SelfieCameraScreenState();
// }
//
// class _SelfieCameraScreenState extends State<SelfieCameraScreen> {
//   CameraController? controller;
//   List<CameraDescription> cameras = [];
//
//   bool isLoading = true;
//   String? error;
//
//   @override
//   void initState() {
//     super.initState();
//     initCamera();
//   }
//
//   Future<void> initCamera() async {
//     try {
//       // 🔥 Get cameras
//       cameras = await availableCameras();
//
//       if (cameras.isEmpty) {
//         setState(() {
//           error = "No camera found";
//           isLoading = false;
//         });
//         return;
//       }
//
//       // ✅ Safe front camera selection
//       final frontCamera = cameras.firstWhere(
//             (cam) => cam.lensDirection == CameraLensDirection.front,
//         orElse: () => cameras.first,
//       );
//
//       controller = CameraController(
//         frontCamera,
//         ResolutionPreset.high,
//         enableAudio: false,
//       );
//
//       await controller!.initialize();
//
//       if (!mounted) return;
//
//       setState(() {
//         isLoading = false;
//       });
//     } catch (e) {
//       debugPrint("Selfie Camera Error: $e");
//
//       if (!mounted) return;
//
//       setState(() {
//         error = "Camera failed to load";
//         isLoading = false;
//       });
//     }
//   }
//
//   @override
//   void dispose() {
//     controller?.dispose(); // 🔥 VERY IMPORTANT
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     /// 🔄 Loading state
//     if (isLoading) {
//       return const Scaffold(
//         backgroundColor: Colors.black,
//         body: Center(child: CircularProgressIndicator()),
//       );
//     }
//
//     /// ❌ Error state
//     if (error != null) {
//       return Scaffold(
//         backgroundColor: Colors.black,
//         body: Center(
//           child: Text(
//             error!,
//             style: const TextStyle(color: Colors.white),
//           ),
//         ),
//       );
//     }
//
//     /// ⚠️ Safety check
//     if (controller == null || !controller!.value.isInitialized) {
//       return const Scaffold(
//         backgroundColor: Colors.black,
//         body: Center(child: Text("Camera not ready")),
//       );
//     }
//
//     return Scaffold(
//       backgroundColor: Colors.black,
//       body: Stack(
//         children: [
//           CameraPreview(controller!),
//
//           /// Title
//           Positioned(
//             top: 60,
//             left: 20,
//             child: const Text(
//               "Take a Selfie",
//               style: TextStyle(color: Colors.white, fontSize: 18),
//             ),
//           ),
//
//           /// Capture button
//           Positioned(
//             bottom: 40,
//             left: 0,
//             right: 0,
//             child: Center(
//               child: GestureDetector(
//                 onTap: captureImage,
//                 child: Container(
//                   height: 75,
//                   width: 75,
//                   decoration: BoxDecoration(
//                     shape: BoxShape.circle,
//                     border: Border.all(color: Colors.white, width: 4),
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Future<void> captureImage() async {
//     try {
//       if (controller == null || !controller!.value.isInitialized) return;
//
//       final file = await controller!.takePicture();
//
//       if (!mounted) return;
//
//       Navigator.push(
//         context,
//         MaterialPageRoute(
//           builder: (_) => SelfiePreviewScreen(imagePath: file.path),
//         ),
//       );
//     } catch (e) {
//       debugPrint("Capture error: $e");
//     }
//   }
// }

import 'package:betrade/presentation/screens/camera/selfie_preview_screen.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:permission_handler/permission_handler.dart';

class SelfieCameraScreen extends StatefulWidget {
  @override
  State<SelfieCameraScreen> createState() => _SelfieCameraScreenState();
}

class _SelfieCameraScreenState extends State<SelfieCameraScreen> {
  CameraController? _controller;
  List<CameraDescription> _cameras = [];

  bool _isLoading = true;
  bool _isDisposed = false;
  bool _isInitializing = false;
  bool _isNavigating = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  @override
  void dispose() {
    _isDisposed = true;
    _controller?.dispose();
    super.dispose();
  }

  // ✅ FIX #1: Safe setState with mounted check
  void _safeSetState(VoidCallback fn) {
    if (!_isDisposed && mounted) {
      setState(fn);
    }
  }

  // ✅ FIX #2: Safe navigation with guard
  void _safeNavigateToPreview(String imagePath) {
    if (_isDisposed || !mounted || _isNavigating) return;
    _isNavigating = true;

    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (!_isDisposed && mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => SelfiePreviewScreen(imagePath: imagePath),
          ),
        );
      }
      _isNavigating = false;
    });
  }

  // ✅ FIX #3: Show permission denied dialog
  void _showPermissionDeniedDialog() {
    if (_isDisposed || !mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text("Camera Permission Required"),
        content: const Text("Please enable camera access in Settings to take selfie."),
        actions: [
          TextButton(
            onPressed: () {
              if (mounted) Navigator.pop(context);
            },
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              openAppSettings();
            },
            child: const Text("Open Settings"),
          ),
        ],
      ),
    );
  }

  Future<void> _initCamera() async {
    if (_isDisposed) return;

    try {
      // Request permission
      final status = await Permission.camera.request();

      if (_isDisposed || !mounted) return;

      if (!status.isGranted) {
        _safeSetState(() {
          _error = "Camera permission denied";
          _isLoading = false;
        });
        _showPermissionDeniedDialog();
        return;
      }

      // ✅ FIX #4: Safe availableCameras with try-catch
      List<CameraDescription> cameras;
      try {
        cameras = await availableCameras();
      } catch (e) {
        debugPrint("❌ availableCameras error: $e");
        _safeSetState(() {
          _error = "Failed to access camera";
          _isLoading = false;
        });
        return;
      }

      if (_isDisposed || !mounted) return;

      if (cameras.isEmpty) {
        _safeSetState(() {
          _error = "No camera found";
          _isLoading = false;
        });
        return;
      }

      _cameras = cameras;

      // Select front camera
      final frontCamera = cameras.firstWhere(
            (cam) => cam.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );

      // ✅ FIX #5: Prevent multiple initializations
      if (_isInitializing) return;
      _isInitializing = true;

      _controller = CameraController(
        frontCamera,
        ResolutionPreset.high,
        enableAudio: false,
      );

      // ✅ FIX #6: Safe controller initialization with try-catch
      try {
        await _controller!.initialize();
      } catch (e) {
        debugPrint("❌ Controller initialize error: $e");
        _safeSetState(() {
          _error = "Camera failed to initialize";
          _isLoading = false;
        });
        _isInitializing = false;
        return;
      }

      if (_isDisposed || !mounted) {
        _isInitializing = false;
        return;
      }

      _safeSetState(() {
        _isLoading = false;
      });
      _isInitializing = false;

    } catch (e) {
      debugPrint("❌ initCamera error: $e");
      if (!_isDisposed && mounted) {
        _safeSetState(() {
          _error = "Camera failed to load";
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _captureImage() async {
    if (_isDisposed || !mounted) return;

    // ✅ FIX #7: Safe capture with validation
    if (_controller == null || !_controller!.value.isInitialized) {
      _safeSetState(() {
        _error = "Camera not ready";
      });
      return;
    }

    try {
      final file = await _controller!.takePicture();

      if (_isDisposed || !mounted) return;

      if (file.path.isNotEmpty) {
        _safeNavigateToPreview(file.path);
      }
    } catch (e) {
      debugPrint("❌ Capture error: $e");
      if (!_isDisposed && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to capture selfie")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isDisposed) return const SizedBox();

    // Loading state
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // Error state
    if (_error != null) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _error!,
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  _safeSetState(() {
                    _error = null;
                    _isLoading = true;
                  });
                  _initCamera();
                },
                child: const Text("Retry"),
              ),
            ],
          ),
        ),
      );
    }

    // Camera not ready state
    if (_controller == null || !_controller!.value.isInitialized) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Text(
            "Camera not ready",
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    }

    // ✅ FIX #8: Safe CameraPreview with RepaintBoundary
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          RepaintBoundary(
            child: CameraPreview(_controller!),
          ),

          // Title
          const Positioned(
            top: 60,
            left: 20,
            child: Text(
              "Take a Selfie",
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
          ),

          // Capture button
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Center(
              child: GestureDetector(
                onTap: _captureImage,
                child: Container(
                  height: 75,
                  width: 75,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 4),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
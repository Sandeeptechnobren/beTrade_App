// import 'package:camera/camera.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:permission_handler/permission_handler.dart';
// class CameraScreen extends StatefulWidget {
//   final bool isFront;
//
//   const CameraScreen({super.key, required this.isFront});
//
//   @override
//   State<CameraScreen> createState() => _CameraScreenState();
// }
//
// class _CameraScreenState extends State<CameraScreen> {
//   CameraController? controller;
//   List<CameraDescription> cameras = [];
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
//       final status = await Permission.camera.request();
//
//       if (!status.isGranted) {
//         setState(() {
//           error = "Camera permission denied";
//           isLoading = false;
//         });
//         return;
//       }
//
//       // ✅ Get cameras
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
//       // ✅ Select front/back camera
//       CameraDescription selectedCamera;
//
//       if (widget.isFront) {
//         selectedCamera = cameras.firstWhere(
//               (cam) => cam.lensDirection == CameraLensDirection.front,
//           orElse: () => cameras.first,
//         );
//       } else {
//         selectedCamera = cameras.firstWhere(
//               (cam) => cam.lensDirection == CameraLensDirection.back,
//           orElse: () => cameras.first,
//         );
//       }
//
//       controller = CameraController(
//         selectedCamera,
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
//       debugPrint("Camera error: $e");
//       if (!mounted) return;
//       setState(() {
//         error = "Camera failed to load";
//         isLoading = false;
//       });
//     }
//   }
//
//   @override
//   void dispose() {
//     controller?.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     if (isLoading) {
//       return const Scaffold(
//         backgroundColor: Colors.black,
//         body: Center(child: CircularProgressIndicator()),
//       );
//     }
//
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
//           /// 🔳 Overlay
//           ColorFiltered(
//             colorFilter: ColorFilter.mode(
//               Colors.black.withOpacity(0.7),
//               BlendMode.srcOut,
//             ),
//             child: Stack(
//               children: [
//                 Container(
//                   decoration: const BoxDecoration(
//                     color: Colors.black,
//                     backgroundBlendMode: BlendMode.dstOut,
//                   ),
//                 ),
//                 Center(
//                   child: Container(
//                     width: 300.w,
//                     height: 180.h,
//                     decoration: BoxDecoration(
//                       color: Colors.white,
//                       borderRadius: BorderRadius.circular(16.r),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//
//           /// Border
//           Center(
//             child: Container(
//               width: 300.w,
//               height: 180.h,
//               decoration: BoxDecoration(
//                 border: Border.all(color: Colors.white, width: 1.5.w),
//                 borderRadius: BorderRadius.circular(16.r),
//               ),
//             ),
//           ),
//
//           /// Corners
//           Center(
//             child: SizedBox(
//               width: 300.w,
//               height: 180.h,
//               child: Stack(
//                 children: [
//                   buildCorner(top: 0, left: 0),
//                   buildCorner(top: 0, right: 0),
//                   buildCorner(bottom: 0, left: 0),
//                   buildCorner(bottom: 0, right: 0),
//                 ],
//               ),
//             ),
//           ),
//
//           /// Title
//           Positioned(
//             top: 60.h,
//             left: 20.w,
//             child: Text(
//               widget.isFront ? "ID Card (Front)" : "ID Card (Back)",
//               style: TextStyle(color: Colors.white, fontSize: 18.sp),
//             ),
//           ),
//
//           /// Instructions
//           Positioned(
//             bottom: 160.h,
//             left: 20.w,
//             right: 20.w,
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 instruction("Place your ID on a flat surface"),
//                 instruction("Make sure all corners are visible"),
//                 instruction("Ensure text is clear and readable"),
//                 instruction("Avoid glare or shadows"),
//               ],
//             ),
//           ),
//
//           /// Capture button
//           Positioned(
//             bottom: 40.h,
//             left: 0,
//             right: 0,
//             child: Center(
//               child: GestureDetector(
//                 onTap: captureImage,
//                 child: Container(
//                   height: 75.h,
//                   width: 75.w,
//                   decoration: BoxDecoration(
//                     shape: BoxShape.circle,
//                     border: Border.all(color: Colors.white, width: 4.w),
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
//   Widget instruction(String text) {
//     return Padding(
//       padding: EdgeInsets.only(bottom: 6.h),
//       child: Text(
//         "• $text",
//         style: TextStyle(color: Colors.white70, fontSize: 13.sp),
//       ),
//     );
//   }
//
//   Widget buildCorner({
//     double? top,
//     double? left,
//     double? right,
//     double? bottom,
//   }) {
//     return Positioned(
//       top: top,
//       left: left,
//       right: right,
//       bottom: bottom,
//       child: Container(
//         width: 30.w,
//         height: 30.h,
//         decoration: BoxDecoration(
//           border: Border(
//             top: top != null
//                 ? BorderSide(color: Colors.white, width: 3.w)
//                 : BorderSide.none,
//             left: left != null
//                 ? BorderSide(color: Colors.white, width: 3.w)
//                 : BorderSide.none,
//             right: right != null
//                 ? BorderSide(color: Colors.white, width: 3.w)
//                 : BorderSide.none,
//             bottom: bottom != null
//                 ? BorderSide(color: Colors.white, width: 3.w)
//                 : BorderSide.none,
//           ),
//         ),
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
//       Navigator.pop(context, file.path);
//     } catch (e) {
//       debugPrint("Capture error: $e");
//     }
//   }
// }

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:permission_handler/permission_handler.dart';

class CameraScreen extends StatefulWidget {
  final bool isFront;

  const CameraScreen({super.key, required this.isFront});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  CameraController? _controller;
  List<CameraDescription> _cameras = [];
  bool _isLoading = true;
  bool _isDisposed = false;
  String? _error;
  bool _isInitializing = false;
  bool _isNavigating = false;

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

  void _safeSetState(VoidCallback fn) {
    if (!_isDisposed && mounted) {
      setState(fn);
    }
  }

  // ✅ FIX #1: Safe navigation with guard
  void _safePop({dynamic result}) {
    if (_isDisposed || !mounted || _isNavigating) return;
    _isNavigating = true;

    try {
      Navigator.pop(context, result);
    } catch (e) {
      debugPrint("❌ Pop error: $e");
    } finally {
      _isNavigating = false;
    }
  }

  void _showPermissionDeniedDialog() {
    if (_isDisposed || !mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text("Camera Permission Required"),
        content: const Text("Please enable camera access in Settings to take photos."),
        actions: [
          TextButton(
            onPressed: () {
              _safePop();
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

  // ✅ FIX #2: Safe snackbar with mounted check
  void _showSnackBar(String message) {
    if (_isDisposed || !mounted) return;

    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (!_isDisposed && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      }
    });
  }

  Future<void> _initCamera() async {
    if (_isDisposed) return;

    try {
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

      CameraDescription selectedCamera;
      if (widget.isFront) {
        selectedCamera = cameras.firstWhere(
              (cam) => cam.lensDirection == CameraLensDirection.front,
          orElse: () => cameras.first,
        );
      } else {
        selectedCamera = cameras.firstWhere(
              (cam) => cam.lensDirection == CameraLensDirection.back,
          orElse: () => cameras.first,
        );
      }

      if (_isInitializing) return;
      _isInitializing = true;

      _controller = CameraController(
        selectedCamera,
        ResolutionPreset.high,
        enableAudio: false,
      );

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
        _safePop(result: file.path);
      }
    } catch (e) {
      debugPrint("❌ Capture error: $e");
      _showSnackBar("Failed to capture image");
    }
  }

  Widget _instruction(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 6.h),
      child: Text(
        "• $text",
        style: TextStyle(color: Colors.white70, fontSize: 13.sp),
      ),
    );
  }

  Widget _buildCorner({
    double? top,
    double? left,
    double? right,
    double? bottom,
  }) {
    return Positioned(
      top: top,
      left: left,
      right: right,
      bottom: bottom,
      child: Container(
        width: 30.w,
        height: 30.h,
        decoration: BoxDecoration(
          border: Border(
            top: top != null
                ? BorderSide(color: Colors.white, width: 3.w)
                : BorderSide.none,
            left: left != null
                ? BorderSide(color: Colors.white, width: 3.w)
                : BorderSide.none,
            right: right != null
                ? BorderSide(color: Colors.white, width: 3.w)
                : BorderSide.none,
            bottom: bottom != null
                ? BorderSide(color: Colors.white, width: 3.w)
                : BorderSide.none,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isDisposed) return const SizedBox();

    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator()),
      );
    }

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
              SizedBox(height: 20.h),
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

    if (_controller == null || !_controller!.value.isInitialized) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: Text("Camera not ready", style: TextStyle(color: Colors.white))),
      );
    }

    // ✅ FIX #3: Safe CameraPreview with key to prevent rebuild race
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          if (_controller != null && _controller!.value.isInitialized)
            RepaintBoundary(
              child: CameraPreview(_controller!),
            ),

          ColorFiltered(
            colorFilter: ColorFilter.mode(
              Colors.black.withOpacity(0.7),
              BlendMode.srcOut,
            ),
            child: Stack(
              children: [
                Container(
                  decoration: const BoxDecoration(
                    color: Colors.black,
                    backgroundBlendMode: BlendMode.dstOut,
                  ),
                ),
                Center(
                  child: Container(
                    width: 300.w,
                    height: 180.h,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                  ),
                ),
              ],
            ),
          ),

          Center(
            child: Container(
              width: 300.w,
              height: 180.h,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white, width: 1.5.w),
                borderRadius: BorderRadius.circular(16.r),
              ),
            ),
          ),

          Center(
            child: SizedBox(
              width: 300.w,
              height: 180.h,
              child: Stack(
                children: [
                  _buildCorner(top: 0, left: 0),
                  _buildCorner(top: 0, right: 0),
                  _buildCorner(bottom: 0, left: 0),
                  _buildCorner(bottom: 0, right: 0),
                ],
              ),
            ),
          ),

          Positioned(
            top: 60.h,
            left: 20.w,
            child: Text(
              widget.isFront ? "ID Card (Front)" : "ID Card (Back)",
              style: TextStyle(color: Colors.white, fontSize: 18.sp),
            ),
          ),

          Positioned(
            bottom: 160.h,
            left: 20.w,
            right: 20.w,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _instruction("Place your ID on a flat surface"),
                _instruction("Make sure all corners are visible"),
                _instruction("Ensure text is clear and readable"),
                _instruction("Avoid glare or shadows"),
              ],
            ),
          ),

          Positioned(
            bottom: 40.h,
            left: 0,
            right: 0,
            child: Center(
              child: GestureDetector(
                onTap: _captureImage,
                child: Container(
                  height: 75.h,
                  width: 75.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 4.w),
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
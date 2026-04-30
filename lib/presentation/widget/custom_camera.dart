// import 'dart:io';
// import 'dart:async';
// import 'package:camera/camera.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:image/image.dart' as img;
//
// class CustomCameraScreen extends StatefulWidget {
//   const CustomCameraScreen({super.key});
//
//   @override
//   State<CustomCameraScreen> createState() => _CustomCameraScreenState();
// }
//
// class _CustomCameraScreenState extends State<CustomCameraScreen>
//     with WidgetsBindingObserver, TickerProviderStateMixin {
//   CameraController? _controller;
//   List<CameraDescription> _cameras = [];
//   int _selectedCameraIndex = 0;
//   bool _isInitialized = false;
//   bool _isTakingPhoto = false;
//
//   // Flash modes
//   FlashMode _flashMode = FlashMode.off;
//
//   // Zoom
//   double _zoomLevel = 0.0;
//   double _minZoom = 1.0;
//   double _maxZoom = 1.0;
//
//   // Focus
//   bool _isAutoFocusEnabled = true;
//
//   // Animation
//   AnimationController? _flashAnimController;
//   Animation<double>? _flashAnimation;
//
//   // Camera quality
//   ResolutionPreset _resolutionPreset = ResolutionPreset.high;
//
//   // Timer for auto-disabling focus indicator
//   Timer? _focusTimer;
//   Offset? _focusPoint;
//   bool _showFocusIndicator = false;
//
//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addObserver(this);
//     SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
//
//     _initFlashAnimation();
//     _initCameras();
//   }
//
//   void _initFlashAnimation() {
//     _flashAnimController = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 150),
//     );
//     _flashAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
//       CurvedAnimation(
//         parent: _flashAnimController!,
//         curve: Curves.easeOut,
//       ),
//     );
//   }
//
//   Future<void> _initCameras() async {
//     try {
//       _cameras = await availableCameras();
//       if (_cameras.isEmpty) return;
//
//       // Default to back camera if available
//       final backCameraIndex = _cameras.indexWhere(
//               (camera) => camera.lensDirection == CameraLensDirection.back
//       );
//       _selectedCameraIndex = backCameraIndex != -1 ? backCameraIndex : 0;
//
//       await _initCamera(_selectedCameraIndex);
//     } catch (e) {
//       debugPrint("❌ Error getting cameras: $e");
//     }
//   }
//
//   Future<void> _initCamera(int index) async {
//     if (_controller != null) {
//       await _controller!.dispose();
//       _controller = null;
//     }
//
//     if (mounted) setState(() => _isInitialized = false);
//
//     try {
//       if (index >= _cameras.length) index = 0;
//
//       _controller = CameraController(
//         _cameras[index],
//         _resolutionPreset,
//         enableAudio: false,
//         imageFormatGroup: ImageFormatGroup.jpeg,
//       );
//
//       await _controller!.initialize();
//       await _controller!.lockCaptureOrientation(DeviceOrientation.portraitUp);
//
//       // Get zoom levels
//       _minZoom = await _controller!.getMinZoomLevel();
//       _maxZoom = await _controller!.getMaxZoomLevel();
//       _zoomLevel = _minZoom;
//
//       // Set auto focus mode
//       if (_isAutoFocusEnabled) {
//         await _controller!.setFocusMode(FocusMode.auto);
//         await _controller!.setExposureMode(ExposureMode.auto);
//       }
//
//       if (mounted) {
//         setState(() => _isInitialized = true);
//       }
//     } catch (e) {
//       debugPrint("❌ Camera init error: $e");
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Failed to initialize camera')),
//         );
//       }
//     }
//   }
//
//   Future<void> _flipCamera() async {
//     if (!_isInitialized) return;
//
//     _selectedCameraIndex = _selectedCameraIndex == 0 ? 1 : 0;
//     await _initCamera(_selectedCameraIndex);
//
//     // Reset zoom when flipping
//     if (mounted) {
//       setState(() {
//         _zoomLevel = _minZoom;
//       });
//     }
//   }
//
//   Future<void> _toggleFlash() async {
//     if (_controller == null || !_controller!.value.isInitialized) return;
//
//     setState(() {
//       if (_flashMode == FlashMode.off) {
//         _flashMode = FlashMode.auto;
//       } else if (_flashMode == FlashMode.auto) {
//         _flashMode = FlashMode.always;
//       } else if (_flashMode == FlashMode.always) {
//         _flashMode = FlashMode.torch;
//       } else {
//         _flashMode = FlashMode.off;
//       }
//     });
//
//     await _controller!.setFlashMode(_flashMode);
//   }
//
//   Future<void> _handleFocus(TapDownDetails details) async {
//     if (_controller == null || !_controller!.value.isInitialized) return;
//
//     final RenderBox box = context.findRenderObject() as RenderBox;
//     final Offset localPosition = box.globalToLocal(details.globalPosition);
//
//     // Calculate focus point (0-1 range)
//     final Size size = box.size;
//     final Offset focusPoint = Offset(
//       localPosition.dx / size.width,
//       localPosition.dy / size.height,
//     );
//
//     // Show focus indicator
//     setState(() {
//       _focusPoint = localPosition;
//       _showFocusIndicator = true;
//     });
//
//     // Cancel previous timer
//     _focusTimer?.cancel();
//     _focusTimer = Timer(const Duration(milliseconds: 500), () {
//       if (mounted) {
//         setState(() => _showFocusIndicator = false);
//       }
//     });
//
//     // Auto focus
//     if (_isAutoFocusEnabled) {
//       await _controller!.setFocusMode(FocusMode.auto);
//       await _controller!.setExposurePoint(focusPoint);
//       await _controller!.setFocusPoint(focusPoint);
//     }
//   }
//
//   void _updateZoom(double value) {
//     if (_controller == null || !_controller!.value.isInitialized) return;
//
//     setState(() {
//       _zoomLevel = _minZoom + (_maxZoom - _minZoom) * value;
//     });
//
//     _controller!.setZoomLevel(_zoomLevel);
//   }
//
//   Future<void> _takePhoto() async {
//     if (_controller == null ||
//         !_controller!.value.isInitialized ||
//         _isTakingPhoto) return;
//
//     setState(() => _isTakingPhoto = true);
//
//     // Play shutter animation
//     _flashAnimController?.forward().then((_) => _flashAnimController?.reverse());
//
//     try {
//       final XFile photo = await _controller!.takePicture();
//
//       // Optional: Optimize image before returning
//       final File optimizedImage = await _optimizeImage(File(photo.path));
//
//       if (mounted) {
//         Navigator.pop(context, optimizedImage);
//       }
//     } catch (e) {
//       debugPrint("❌ Take photo error: $e");
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Failed to capture photo')),
//         );
//         setState(() => _isTakingPhoto = false);
//       }
//     }
//   }
//
//   Future<File> _optimizeImage(File imageFile) async {
//     try {
//       final bytes = await imageFile.readAsBytes();
//       final image = img.decodeImage(bytes);
//
//       if (image == null) return imageFile;
//
//       // Resize if too large (max 1920px)
//       final resized = img.copyResize(image, width: 1920);
//
//       // Compress with 85% quality
//       final compressed = img.encodeJpg(resized, quality: 85);
//
//       final tempDir = await getTemporaryDirectory();
//       final optimizedFile = File('${tempDir.path}/optimized_${DateTime.now().millisecondsSinceEpoch}.jpg');
//       await optimizedFile.writeAsBytes(compressed);
//
//       // Delete original
//       await imageFile.delete();
//
//       return optimizedFile;
//     } catch (e) {
//       debugPrint("❌ Image optimization error: $e");
//       return imageFile;
//     }
//   }
//
//   Widget _buildCameraPreview() {
//     if (_controller == null || !_controller!.value.isInitialized) {
//       return const Center(
//         child: CircularProgressIndicator(color: Colors.white),
//       );
//     }
//
//     return GestureDetector(
//       onTapDown: _handleFocus,
//       child: Container(
//         color: Colors.black,
//         child: CameraPreview(_controller!),
//       ),
//     );
//   }
//
//   Widget _buildZoomSlider() {
//     if (_maxZoom <= _minZoom) return const SizedBox.shrink();
//
//     return Positioned(
//       bottom: MediaQuery.of(context).padding.bottom + 120.h,
//       left: 16.w,
//       right: 16.w,
//       child: Container(
//         padding: EdgeInsets.symmetric(horizontal: 12.w),
//         decoration: BoxDecoration(
//           color: Colors.black.withOpacity(0.5),
//           borderRadius: BorderRadius.circular(20.r),
//         ),
//         child: Slider(
//           value: (_zoomLevel - _minZoom) / (_maxZoom - _minZoom),
//           onChanged: _updateZoom,
//           activeColor: Colors.white,
//           inactiveColor: Colors.white30,
//         ),
//       ),
//     );
//   }
//
//   Widget _buildTopBar() {
//     return Positioned(
//       top: MediaQuery.of(context).padding.top + 12.h,
//       left: 16.w,
//       right: 16.w,
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           _circleButton(
//             icon: Icons.close,
//             onTap: () => Navigator.pop(context),
//             color: Colors.black54,
//           ),
//
//           // Flash mode button
//           _circleButton(
//             icon: _getFlashIcon(),
//             onTap: _toggleFlash,
//             color: Colors.black54,
//           ),
//
//           // Camera quality indicator
//           Container(
//             padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
//             decoration: BoxDecoration(
//               color: Colors.black54,
//               borderRadius: BorderRadius.circular(20.r),
//             ),
//             child: Text(
//               _getCameraName(),
//               style: TextStyle(
//                 color: Colors.white,
//                 fontSize: 12.sp,
//                 fontWeight: FontWeight.w500,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   IconData _getFlashIcon() {
//     switch (_flashMode) {
//       case FlashMode.auto:
//         return Icons.flash_auto;
//       case FlashMode.always:
//         return Icons.flash_on;
//       case FlashMode.torch:
//         return Icons.flashlight_on;
//       default:
//         return Icons.flash_off;
//     }
//   }
//
//   String _getCameraName() {
//     if (_selectedCameraIndex >= _cameras.length) return "Camera";
//     final lensDir = _cameras[_selectedCameraIndex].lensDirection;
//     return lensDir == CameraLensDirection.front ? "Front" : "Back";
//   }
//
//   Widget _circleButton({
//     required IconData icon,
//     required VoidCallback onTap,
//     Color color = Colors.black54,
//   }) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         width: 44.w,
//         height: 44.w,
//         decoration: BoxDecoration(
//           color: color,
//           shape: BoxShape.circle,
//           border: Border.all(color: Colors.white24, width: 1),
//         ),
//         child: Icon(icon, color: Colors.white, size: 20.sp),
//       ),
//     );
//   }
//
//   Widget _buildBottomControls() {
//     return Positioned(
//       bottom: MediaQuery.of(context).padding.bottom + 30.h,
//       left: 0,
//       right: 0,
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//         crossAxisAlignment: CrossAxisAlignment.center,
//         children: [
//           // Gallery button (placeholder)
//           _circleButton(
//             icon: Icons.photo_library,
//             onTap: () {
//               // Implement gallery picker
//             },
//             color: Colors.black54,
//           ),
//
//           // Shutter button
//           GestureDetector(
//             onTap: _isTakingPhoto ? null : _takePhoto,
//             child: AnimatedContainer(
//               duration: const Duration(milliseconds: 100),
//               width: _isTakingPhoto ? 64.w : 80.w,
//               height: _isTakingPhoto ? 64.w : 80.w,
//               decoration: BoxDecoration(
//                 shape: BoxShape.circle,
//                 color: Colors.white,
//                 border: Border.all(
//                   color: Colors.white,
//                   width: 4,
//                 ),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.white.withOpacity(0.3),
//                     blurRadius: 12,
//                     spreadRadius: 2,
//                   ),
//                 ],
//               ),
//               child: _isTakingPhoto
//                   ? Padding(
//                 padding: EdgeInsets.all(16.w),
//                 child: const CircularProgressIndicator(
//                   color: Colors.black,
//                   strokeWidth: 2,
//                 ),
//               )
//                   : null,
//             ),
//           ),
//
//           // Flip camera button
//           _circleButton(
//             icon: Icons.flip_camera_ios_rounded,
//             onTap: _flipCamera,
//             color: Colors.black54,
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildFocusIndicator() {
//     if (!_showFocusIndicator || _focusPoint == null) return const SizedBox.shrink();
//
//     return Positioned(
//       left: _focusPoint!.dx - 25.w,
//       top: _focusPoint!.dy - 25.h,
//       child: AnimatedOpacity(
//         opacity: _showFocusIndicator ? 1.0 : 0.0,
//         duration: const Duration(milliseconds: 200),
//         child: Container(
//           width: 50.w,
//           height: 50.w,
//           decoration: BoxDecoration(
//             border: Border.all(color: Colors.yellow, width: 2),
//             borderRadius: BorderRadius.circular(25.r),
//           ),
//           child: const Center(
//             child: Icon(Icons.center_focus_strong, color: Colors.yellow, size: 30),
//           ),
//         ),
//       ),
//     );
//   }
//
//   @override
//   void didChangeAppLifecycleState(AppLifecycleState state) {
//     if (_controller == null || !_controller!.value.isInitialized) return;
//
//     if (state == AppLifecycleState.inactive) {
//       _controller?.dispose();
//     } else if (state == AppLifecycleState.resumed) {
//       _initCamera(_selectedCameraIndex);
//     }
//   }
//
//   @override
//   void dispose() {
//     _focusTimer?.cancel();
//     _flashAnimController?.dispose();
//     _controller?.dispose();
//     WidgetsBinding.instance.removeObserver(this);
//     SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.black,
//       body: Stack(
//         fit: StackFit.expand,
//         children: [
//           _buildCameraPreview(),
//           if (_flashAnimation != null)
//             AnimatedBuilder(
//               animation: _flashAnimation!,
//               builder: (_, __) => Opacity(
//                 opacity: _flashAnimation!.value * 0.8,
//                 child: Container(color: Colors.white),
//               ),
//             ),
//           _buildFocusIndicator(),
//           _buildTopBar(),
//           _buildZoomSlider(),
//           _buildBottomControls(),
//         ],
//       ),
//     );
//   }
// }

import 'dart:io';
import 'dart:async';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as img;

class CustomCameraScreen extends StatefulWidget {
  const CustomCameraScreen({super.key});

  @override
  State<CustomCameraScreen> createState() => _CustomCameraScreenState();
}

class _CustomCameraScreenState extends State<CustomCameraScreen>
    with WidgetsBindingObserver, TickerProviderStateMixin {
  CameraController? _controller;
  List<CameraDescription> _cameras = [];
  int _selectedCameraIndex = 0;
  bool _isInitialized = false;
  bool _isTakingPhoto = false;

  FlashMode _flashMode = FlashMode.off;

  double _zoomLevel = 0.0;
  double _minZoom = 1.0;
  double _maxZoom = 1.0;

  bool _isAutoFocusEnabled = true;

  AnimationController? _flashAnimController;
  Animation<double>? _flashAnimation;

  ResolutionPreset _resolutionPreset = ResolutionPreset.high;

  Timer? _focusTimer;
  Offset? _focusPoint;
  bool _showFocusIndicator = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    _initFlashAnimation();
    _initCameras();
  }

  void _initFlashAnimation() {
    _flashAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _flashAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _flashAnimController!,
        curve: Curves.easeOut,
      ),
    );
  }

  Future<void> _initCameras() async {
    try {
      _cameras = await availableCameras();
      if (_cameras.isEmpty) return;

      final backCameraIndex = _cameras.indexWhere(
            (camera) => camera.lensDirection == CameraLensDirection.back,
      );
      _selectedCameraIndex = backCameraIndex != -1 ? backCameraIndex : 0;

      await _initCamera(_selectedCameraIndex);
    } catch (e) {
      debugPrint("❌ Error getting cameras: $e");
    }
  }

  Future<void> _initCamera(int index) async {
    if (_controller != null) {
      await _controller!.dispose();
      _controller = null;
    }

    if (mounted) setState(() => _isInitialized = false);

    try {
      if (index >= _cameras.length) index = 0;

      _controller = CameraController(
        _cameras[index],
        _resolutionPreset,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );

      await _controller!.initialize();
      await _controller!.lockCaptureOrientation(DeviceOrientation.portraitUp);

      _minZoom = await _controller!.getMinZoomLevel();
      _maxZoom = await _controller!.getMaxZoomLevel();
      _zoomLevel = _minZoom;
      if (_isAutoFocusEnabled) {
        await _controller!.setFocusMode(FocusMode.auto);
        await _controller!.setExposureMode(ExposureMode.auto);
      }
      await _controller!.setZoomLevel(_minZoom);

      if (mounted) {
        setState(() => _isInitialized = true);
      }
    } catch (e) {
      debugPrint("❌ Camera init error: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to initialize camera')),
        );
      }
    }
  }

  Future<void> _flipCamera() async {
    if (!_isInitialized) return;

    _selectedCameraIndex = _selectedCameraIndex == 0 ? 1 : 0;
    await _initCamera(_selectedCameraIndex);

    if (mounted) {
      setState(() {
        _zoomLevel = _minZoom;
      });
    }
  }

  Future<void> _toggleFlash() async {
    if (_controller == null || !_controller!.value.isInitialized) return;

    setState(() {
      if (_flashMode == FlashMode.off) {
        _flashMode = FlashMode.auto;
      } else if (_flashMode == FlashMode.auto) {
        _flashMode = FlashMode.always;
      } else if (_flashMode == FlashMode.always) {
        _flashMode = FlashMode.torch;
      } else {
        _flashMode = FlashMode.off;
      }
    });

    await _controller!.setFlashMode(_flashMode);
  }

  Future<void> _handleFocus(TapDownDetails details) async {
    if (_controller == null || !_controller!.value.isInitialized) return;

    final RenderBox box = context.findRenderObject() as RenderBox;
    final Offset localPosition = box.globalToLocal(details.globalPosition);

    final Size size = box.size;
    final Offset focusPoint = Offset(
      localPosition.dx / size.width,
      localPosition.dy / size.height,
    );

    setState(() {
      _focusPoint = localPosition;
      _showFocusIndicator = true;
    });

    _focusTimer?.cancel();
    _focusTimer = Timer(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() => _showFocusIndicator = false);
      }
    });

    if (_isAutoFocusEnabled) {
      await _controller!.setFocusMode(FocusMode.auto);
      await _controller!.setExposurePoint(focusPoint);
      await _controller!.setFocusPoint(focusPoint);
    }
  }

  void _updateZoom(double value) {
    if (_controller == null || !_controller!.value.isInitialized) return;

    setState(() {
      _zoomLevel = _minZoom + (_maxZoom - _minZoom) * value;
    });

    _controller!.setZoomLevel(_zoomLevel);
  }

  Future<void> _takePhoto() async {
    if (_controller == null ||
        !_controller!.value.isInitialized ||
        _isTakingPhoto) return;

    setState(() => _isTakingPhoto = true);

    _flashAnimController?.forward().then((_) => _flashAnimController?.reverse());

    try {
      final XFile photo = await _controller!.takePicture();

      final File optimizedImage = await _optimizeImage(File(photo.path));

      if (mounted) {
        Navigator.pop(context, optimizedImage);
      }
    } catch (e) {
      debugPrint("❌ Take photo error: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to capture photo')),
        );
        setState(() => _isTakingPhoto = false);
      }
    }
  }

  Future<File> _optimizeImage(File imageFile) async {
    try {
      final bytes = await imageFile.readAsBytes();
      final image = img.decodeImage(bytes);

      if (image == null) return imageFile;

      final resized = img.copyResize(image, width: 1920);

      final compressed = img.encodeJpg(resized, quality: 85);

      final tempDir = await getTemporaryDirectory();
      final optimizedFile = File(
          '${tempDir.path}/optimized_${DateTime.now().millisecondsSinceEpoch}.jpg');
      await optimizedFile.writeAsBytes(compressed);

      await imageFile.delete();

      return optimizedFile;
    } catch (e) {
      debugPrint("❌ Image optimization error: $e");
      return imageFile;
    }
  }
  Widget _buildCameraPreview() {
    if (_controller == null || !_controller!.value.isInitialized) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }

    final previewSize = _controller!.value.previewSize;
    if (previewSize == null) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }

    return GestureDetector(
      onTapDown: _handleFocus,
      child: Container(
        color: Colors.black,
        child: ClipRect(
          child: SizedBox.expand(
            child: FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                // sensor landscape mein hota hai — width/height swap karna padega
                width: previewSize.height,
                height: previewSize.width,
                child: CameraPreview(_controller!),
              ),
            ),
          ),
        ),
      ),
    );
  }
  //
  // Widget _buildCameraPreview() {
  //   if (_controller == null || !_controller!.value.isInitialized) {
  //     return const Center(
  //       child: CircularProgressIndicator(color: Colors.white),
  //     );
  //   }
  //
  //   // Fill the screen properly — fixes the "zoomed out / letterboxed" look
  //   final mediaSize = MediaQuery.of(context).size;
  //   final scale = 1 / (_controller!.value.aspectRatio * mediaSize.aspectRatio);
  //
  //   return GestureDetector(
  //     onTapDown: _handleFocus,
  //     child: Container(
  //       color: Colors.black,
  //       child: ClipRect(
  //         child: Transform.scale(
  //           scale: scale,
  //           alignment: Alignment.center,
  //           child: CameraPreview(_controller!),
  //         ),
  //       ),
  //     ),
  //   );
  // }

  Widget _buildZoomSlider() {
    if (_maxZoom <= _minZoom) return const SizedBox.shrink();

    return Positioned(
      bottom: MediaQuery.of(context).padding.bottom + 120.h,
      left: 16.w,
      right: 16.w,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.5),
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Slider(
          value: (_zoomLevel - _minZoom) / (_maxZoom - _minZoom),
          onChanged: _updateZoom,
          activeColor: Colors.white,
          inactiveColor: Colors.white30,
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 12.h,
      left: 16.w,
      right: 16.w,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _circleButton(
            icon: Icons.close,
            onTap: () => Navigator.pop(context),
            color: Colors.black54,
          ),
          _circleButton(
            icon: _getFlashIcon(),
            onTap: _toggleFlash,
            color: Colors.black54,
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: Colors.black54,
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Text(
              _getCameraName(),
              style: TextStyle(
                color: Colors.white,
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getFlashIcon() {
    switch (_flashMode) {
      case FlashMode.auto:
        return Icons.flash_auto;
      case FlashMode.always:
        return Icons.flash_on;
      case FlashMode.torch:
        return Icons.flashlight_on;
      default:
        return Icons.flash_off;
    }
  }

  String _getCameraName() {
    if (_selectedCameraIndex >= _cameras.length) return "Camera";
    final lensDir = _cameras[_selectedCameraIndex].lensDirection;
    return lensDir == CameraLensDirection.front ? "Front" : "Back";
  }

  Widget _circleButton({
    required IconData icon,
    required VoidCallback onTap,
    Color color = Colors.black54,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44.w,
        height: 44.w,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white24, width: 1),
        ),
        child: Icon(icon, color: Colors.white, size: 20.sp),
      ),
    );
  }

  Widget _buildBottomControls() {
    return Positioned(
      bottom: MediaQuery.of(context).padding.bottom + 30.h,
      left: 0,
      right: 0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _circleButton(
            icon: Icons.photo_library,
            onTap: () {},
            color: Colors.black54,
          ),
          GestureDetector(
            onTap: _isTakingPhoto ? null : _takePhoto,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 100),
              width: _isTakingPhoto ? 64.w : 80.w,
              height: _isTakingPhoto ? 64.w : 80.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                border: Border.all(
                  color: Colors.white,
                  width: 4,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.white.withOpacity(0.3),
                    blurRadius: 12,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: _isTakingPhoto
                  ? Padding(
                padding: EdgeInsets.all(16.w),
                child: const CircularProgressIndicator(
                  color: Colors.black,
                  strokeWidth: 2,
                ),
              )
                  : null,
            ),
          ),
          _circleButton(
            icon: Icons.flip_camera_ios_rounded,
            onTap: _flipCamera,
            color: Colors.black54,
          ),
        ],
      ),
    );
  }

  Widget _buildFocusIndicator() {
    if (!_showFocusIndicator || _focusPoint == null) {
      return const SizedBox.shrink();
    }

    return Positioned(
      left: _focusPoint!.dx - 25.w,
      top: _focusPoint!.dy - 25.h,
      child: AnimatedOpacity(
        opacity: _showFocusIndicator ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 200),
        child: Container(
          width: 50.w,
          height: 50.w,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.yellow, width: 2),
            borderRadius: BorderRadius.circular(25.r),
          ),
          child: const Center(
            child: Icon(Icons.center_focus_strong,
                color: Colors.yellow, size: 30),
          ),
        ),
      ),
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_controller == null || !_controller!.value.isInitialized) return;

    if (state == AppLifecycleState.inactive) {
      _controller?.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initCamera(_selectedCameraIndex);
    }
  }

  @override
  void dispose() {
    _focusTimer?.cancel();
    _flashAnimController?.dispose();
    _controller?.dispose();
    WidgetsBinding.instance.removeObserver(this);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          _buildCameraPreview(),
          if (_flashAnimation != null)
            AnimatedBuilder(
              animation: _flashAnimation!,
              builder: (_, __) => Opacity(
                opacity: _flashAnimation!.value * 0.8,
                child: Container(color: Colors.white),
              ),
            ),
          _buildFocusIndicator(),
          _buildTopBar(),
          _buildZoomSlider(),
          _buildBottomControls(),
        ],
      ),
    );
  }
}
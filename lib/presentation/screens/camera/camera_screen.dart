import 'dart:io';
import 'dart:math' as math;

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import 'preview_screen.dart';

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
  bool _isProcessing = false; // capture + crop guard / loader

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

      // ID-card capture always uses the rear lens. `widget.isFront` only
      // drives the on-screen label (front vs back side of the card) — the
      // selfie step has its own SelfieCameraScreen.
      final CameraDescription selectedCamera = cameras.firstWhere(
        (cam) => cam.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );

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
    if (_isDisposed || !mounted || _isProcessing) return;

    if (_controller == null || !_controller!.value.isInitialized) {
      _safeSetState(() {
        _error = "Camera not ready";
      });
      return;
    }

    _safeSetState(() => _isProcessing = true);

    // Read the on-screen geometry while context is valid (before awaits).
    final Size screen = MediaQuery.of(context).size;
    final double boxW = 300.w;
    final double boxH = 180.h;

    try {
      final file = await _controller!.takePicture();
      if (_isDisposed || !mounted) return;

      // Crop the full frame down to just the centered overlay box.
      final String croppedPath =
          await _cropToBox(file.path, screen: screen, boxW: boxW, boxH: boxH);
      if (_isDisposed || !mounted) return;

      // Figma: confirm via a Retake / Use Photo preview before accepting.
      final used = await Navigator.push<String>(
        context,
        MaterialPageRoute(
          builder: (_) => PreviewScreen(
            imagePath: croppedPath,
            isFront: widget.isFront,
          ),
        ),
      );
      if (_isDisposed || !mounted) return;

      if (used != null && used.isNotEmpty) {
        _safePop(result: used);
      } else {
        // Retake — stay on the camera and allow another shot.
        _safeSetState(() => _isProcessing = false);
      }
    } catch (e) {
      debugPrint("❌ Capture error: $e");
      _showSnackBar("Failed to capture image");
      _safeSetState(() => _isProcessing = false);
    }
  }

  /// Crops the captured full-frame photo down to the centered overlay box.
  /// The live preview fills the screen with [BoxFit.cover] and the box is
  /// centered, so the same centered fraction of the image is what the user
  /// framed. Falls back to the original path on any decode/crop failure.
  Future<String> _cropToBox(
    String sourcePath, {
    required Size screen,
    required double boxW,
    required double boxH,
  }) async {
    try {
      final bytes = await File(sourcePath).readAsBytes();
      final decoded = img.decodeImage(bytes);
      if (decoded == null) return sourcePath;

      // Apply EXIF orientation so pixel coords match the upright preview.
      final baked = img.bakeOrientation(decoded);
      final int imgW = baked.width;
      final int imgH = baked.height;

      // Invert the BoxFit.cover transform: the box maps to a centered
      // rectangle of the source image, scaled by the cover factor.
      final double coverScale =
          math.max(screen.width / imgW, screen.height / imgH);
      final int cropW = (boxW / coverScale).round().clamp(1, imgW).toInt();
      final int cropH = (boxH / coverScale).round().clamp(1, imgH).toInt();
      final int cropX = ((imgW - cropW) / 2).round().clamp(0, imgW - cropW).toInt();
      final int cropY = ((imgH - cropH) / 2).round().clamp(0, imgH - cropH).toInt();

      final cropped = img.copyCrop(
        baked,
        x: cropX,
        y: cropY,
        width: cropW,
        height: cropH,
      );
      final jpg = img.encodeJpg(cropped, quality: 90);

      final dir = await getTemporaryDirectory();
      final outPath =
          '${dir.path}/id_${widget.isFront ? "front" : "back"}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      await File(outPath).writeAsBytes(jpg);

      // Remove the original full-frame capture (best-effort).
      try {
        await File(sourcePath).delete();
      } catch (_) {}

      return outPath;
    } catch (e) {
      debugPrint("❌ Crop error (falling back to full image): $e");
      return sourcePath;
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

  /// Live preview scaled to fill the screen (BoxFit.cover) so the centered
  /// overlay box frames exactly the region cropped on capture.
  Widget _coverPreview() {
    final previewSize = _controller!.value.previewSize;
    if (previewSize == null) {
      return RepaintBoundary(child: CameraPreview(_controller!));
    }
    return ClipRect(
      child: SizedBox.expand(
        child: FittedBox(
          fit: BoxFit.cover,
          child: SizedBox(
            // Sensor is landscape — swap width/height for portrait display.
            width: previewSize.height,
            height: previewSize.width,
            child: RepaintBoundary(child: CameraPreview(_controller!)),
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
            Positioned.fill(
              child: _coverPreview(),
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
                onTap: _isProcessing ? null : _captureImage,
                child: Container(
                  height: 75.h,
                  width: 75.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _isProcessing ? Colors.white24 : Colors.transparent,
                    border: Border.all(color: Colors.white, width: 4.w),
                  ),
                  child: _isProcessing
                      ? Padding(
                          padding: EdgeInsets.all(22.w),
                          child: const CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : null,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
import 'package:betrade/presentation/screens/camera/selfie_preview_screen.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class SelfieCameraScreen extends StatefulWidget {
  @override
  State<SelfieCameraScreen> createState() => _SelfieCameraScreenState();
}

class _SelfieCameraScreenState extends State<SelfieCameraScreen> {
  CameraController? controller;
  List<CameraDescription> cameras = [];

  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    initCamera();
  }

  Future<void> initCamera() async {
    try {
      // 🔥 Get cameras
      cameras = await availableCameras();

      if (cameras.isEmpty) {
        setState(() {
          error = "No camera found";
          isLoading = false;
        });
        return;
      }

      // ✅ Safe front camera selection
      final frontCamera = cameras.firstWhere(
            (cam) => cam.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );

      controller = CameraController(
        frontCamera,
        ResolutionPreset.high,
        enableAudio: false,
      );

      await controller!.initialize();

      if (!mounted) return;

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      debugPrint("Selfie Camera Error: $e");

      if (!mounted) return;

      setState(() {
        error = "Camera failed to load";
        isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    controller?.dispose(); // 🔥 VERY IMPORTANT
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    /// 🔄 Loading state
    if (isLoading) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    /// ❌ Error state
    if (error != null) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Text(
            error!,
            style: const TextStyle(color: Colors.white),
          ),
        ),
      );
    }

    /// ⚠️ Safety check
    if (controller == null || !controller!.value.isInitialized) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: Text("Camera not ready")),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          CameraPreview(controller!),

          /// Title
          Positioned(
            top: 60,
            left: 20,
            child: const Text(
              "Take a Selfie",
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
          ),

          /// Capture button
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Center(
              child: GestureDetector(
                onTap: captureImage,
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

  Future<void> captureImage() async {
    try {
      if (controller == null || !controller!.value.isInitialized) return;

      final file = await controller!.takePicture();

      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => SelfiePreviewScreen(imagePath: file.path),
        ),
      );
    } catch (e) {
      debugPrint("Capture error: $e");
    }
  }
}
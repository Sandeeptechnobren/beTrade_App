import 'package:betrade/presentation/screens/camera/selfie_preview_screen.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class SelfieCameraScreen extends StatefulWidget {
  @override
  State<SelfieCameraScreen> createState() => _SelfieCameraScreenState();
}
class _SelfieCameraScreenState extends State<SelfieCameraScreen> {
  CameraController? controller;
  List<CameraDescription>? cameras;
  @override
  void initState() {
    super.initState();
    initCamera();
  }
  Future<void> initCamera() async {
    cameras = await availableCameras();
    final frontCamera = cameras!.firstWhere(
      (cam) => cam.lensDirection == CameraLensDirection.front,);
    controller = CameraController(frontCamera, ResolutionPreset.high);
    await controller!.initialize();
    setState(() {});
  }
  @override
  Widget build(BuildContext context) {
    if (controller == null || !controller!.value.isInitialized) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          CameraPreview(controller!),
          Positioned(
            top: 60,
            left: 20,
            child: Text(
              "Take a Selfie",
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
          ),
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
    final file = await controller!.takePicture();
    Navigator.push(context, MaterialPageRoute(builder: (_) => SelfiePreviewScreen(imagePath: file.path),),);
  }
}

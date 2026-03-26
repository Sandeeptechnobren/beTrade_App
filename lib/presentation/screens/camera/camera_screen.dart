import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class CameraScreen extends StatefulWidget {
  final bool isFront;

  const CameraScreen({required this.isFront});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  CameraController? controller;
  List<CameraDescription>? cameras;

  @override
  void initState() {
    super.initState();
    initCamera();
  }

  Future<void> initCamera() async {
    cameras = await availableCameras();
    controller = CameraController(cameras![0], ResolutionPreset.high);
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

          // 🔥 DARK OVERLAY WITH CUTOUT
          ColorFiltered(
            colorFilter: ColorFilter.mode(
              Colors.black.withOpacity(0.7),
              BlendMode.srcOut,
            ),
            child: Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.black,
                    backgroundBlendMode: BlendMode.dstOut,
                  ),
                ),
                Center(
                  child: Container(
                    width: 300,
                    height: 180,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 🔲 BORDER
          Center(
            child: Container(
              width: 300,
              height: 180,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white, width: 1.5),
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),

          // ✨ CORNER MARKERS
          Center(
            child: SizedBox(
              width: 300,
              height: 180,
              child: Stack(
                children: [
                  buildCorner(top: 0, left: 0),
                  buildCorner(top: 0, right: 0),
                  buildCorner(bottom: 0, left: 0),
                  buildCorner(bottom: 0, right: 0),
                ],
              ),
            ),
          ),

          // 📝 TITLE
          Positioned(
            top: 60,
            left: 20,
            child: Text(
              widget.isFront ? "ID Card (Front)" : "ID Card (Back)",
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
          ),

          // 📄 INSTRUCTIONS
          Positioned(
            bottom: 160,
            left: 20,
            right: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                instruction("Place your ID on a flat surface"),
                instruction("Make sure all corners are visible"),
                instruction("Ensure text is clear and readable"),
                instruction("Avoid glare or shadows"),
              ],
            ),
          ),

          // 🔘 CAPTURE BUTTON
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
          )
        ],
      ),
    );
  }

  Widget instruction(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        "• $text",
        style: TextStyle(color: Colors.white70),
      ),
    );
  }

  Widget buildCorner({
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
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          border: Border(
            top: top != null
                ? BorderSide(color: Colors.white, width: 3)
                : BorderSide.none,
            left: left != null
                ? BorderSide(color: Colors.white, width: 3)
                : BorderSide.none,
            right: right != null
                ? BorderSide(color: Colors.white, width: 3)
                : BorderSide.none,
            bottom: bottom != null
                ? BorderSide(color: Colors.white, width: 3)
                : BorderSide.none,
          ),
        ),
      ),
    );
  }

  Future<void> captureImage() async {
    final file = await controller!.takePicture();

    Navigator.pop(context, file.path);
  }
}
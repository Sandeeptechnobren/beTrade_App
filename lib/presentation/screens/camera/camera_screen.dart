import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CameraScreen extends StatefulWidget {
  final bool isFront;

  const CameraScreen({super.key, required this.isFront});

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
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          CameraPreview(controller!),
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
                  buildCorner(top: 0, left: 0),
                  buildCorner(top: 0, right: 0),
                  buildCorner(bottom: 0, left: 0),
                  buildCorner(bottom: 0, right: 0),
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
                instruction("Place your ID on a flat surface"),
                instruction("Make sure all corners are visible"),
                instruction("Ensure text is clear and readable"),
                instruction("Avoid glare or shadows"),
              ],
            ),
          ),
          Positioned(
            bottom: 40.h,
            left: 0,
            right: 0,
            child: Center(
              child: GestureDetector(
                onTap: captureImage,
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

  Widget instruction(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 6.h),
      child: Text(
        "• $text",
        style: TextStyle(color: Colors.white70, fontSize: 13.sp),
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

  Future<void> captureImage() async {
    final file = await controller!.takePicture();
    Navigator.pop(context, file.path);
  }
}

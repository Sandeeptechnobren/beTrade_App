// import 'dart:io';
//
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
//
// class SelfiePreviewScreen extends StatelessWidget {
//   final String imagePath;
//   const SelfiePreviewScreen({required this.imagePath});
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.black,
//       body: Column(
//         children: [
//           Expanded(child: Image.file(File(imagePath), fit: BoxFit.cover)),
//           Padding(
//             padding:EdgeInsets.all(20.w),
//             child: Row(
//               children: [
//                 Expanded(
//                   child: OutlinedButton(
//                     onPressed: () => Navigator.pop(context),
//                     child: Text("Retake", style: TextStyle(color: Colors.white),),
//                   ),
//                 ),
//                 SizedBox(width: 12.w),
//                 Expanded(
//                   child: ElevatedButton(
//                     style: ElevatedButton.styleFrom(backgroundColor: Colors.white,),
//                     onPressed: () {
//                       Navigator.pop(context);
//                       Navigator.pop(context, imagePath);
//                     },
//                     child: Text("Use Photo", style: TextStyle(color: Colors.black),),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SelfiePreviewScreen extends StatefulWidget {
  final String imagePath;

  const SelfiePreviewScreen({super.key, required this.imagePath});

  @override
  State<SelfiePreviewScreen> createState() => _SelfiePreviewScreenState();
}

class _SelfiePreviewScreenState extends State<SelfiePreviewScreen> {
  bool _isDisposed = false;
  bool _isNavigating = false;

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
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

  // ✅ FIX #2: Safe double pop (pop twice with delay)
  void _safeDoublePop({dynamic result}) {
    if (_isDisposed || !mounted || _isNavigating) return;
    _isNavigating = true;

    try {
      // First pop (close current screen)
      Navigator.pop(context);

      // Use post frame callback for second pop to ensure first pop completes
      SchedulerBinding.instance.addPostFrameCallback((_) {
        if (!_isDisposed && mounted) {
          try {
            Navigator.pop(context, result);
          } catch (e) {
            debugPrint("❌ Second pop error: $e");
          }
        }
        _isNavigating = false;
      });
    } catch (e) {
      debugPrint("❌ Double pop error: $e");
      _isNavigating = false;
    }
  }

  // ✅ FIX #3: Check if file exists
  bool _doesFileExist() {
    try {
      if (widget.imagePath.isEmpty) return false;
      final file = File(widget.imagePath);
      return file.existsSync();
    } catch (e) {
      debugPrint("❌ File check error: $e");
      return false;
    }
  }

  // ✅ FIX #4: Safe image widget with error handling
  Widget _buildImage() {
    if (!_doesFileExist()) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.broken_image,
              size: 80,
              color: Colors.white54,
            ),
            const SizedBox(height: 16),
            Text(
              "Image not found",
              style: TextStyle(color: Colors.white54, fontSize: 16.sp),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _safePop(),
              child: const Text("Go Back"),
            ),
          ],
        ),
      );
    }

    return Image.file(
      File(widget.imagePath),
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        debugPrint("❌ Image decode error: $error");
        return Container(
          color: Colors.grey.shade800,
          child: const Center(
            child: Icon(
              Icons.broken_image,
              size: 50,
              color: Colors.white54,
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: [
          Expanded(child: _buildImage()),
          Padding(
            padding: EdgeInsets.all(20.w),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.white),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                    ),
                    onPressed: () => _safePop(),
                    child: const Text(
                      "Retake",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                    ),
                    onPressed: () => _safeDoublePop(result: widget.imagePath),
                    child: const Text(
                      "Use Photo",
                      style: TextStyle(color: Colors.black),
                    ),
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

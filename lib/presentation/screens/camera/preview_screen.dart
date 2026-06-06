// import 'dart:io';
// import 'package:flutter/material.dart';
// class PreviewScreen extends StatelessWidget {
//   final String imagePath;
//   final bool isFront;
//   const PreviewScreen({required this.imagePath, required this.isFront});
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.black,
//       body: SafeArea(
//         child: Column(
//           children: [
//             Padding(
//               padding: const EdgeInsets.all(16),
//               child: Row(
//                 children: [
//                   Icon(Icons.arrow_back, color: Colors.white),
//                   SizedBox(width: 10),
//                   Text(
//                     isFront ? "ID Card (Front)" : "ID Card (Back)",
//                     style: TextStyle(color: Colors.white, fontSize: 18),
//                   ),
//                 ],
//               ),
//             ),
//             Expanded(
//               child: Center(
//                 child: Container(
//                   margin: EdgeInsets.symmetric(horizontal: 20),
//                   decoration: BoxDecoration(
//                     borderRadius: BorderRadius.circular(16),
//                     border: Border.all(color: Colors.white, width: 1),
//                   ),
//                   child: ClipRRect(
//                     borderRadius: BorderRadius.circular(16),
//                     child: Image.file(File(imagePath), fit: BoxFit.cover),
//                   ),
//                 ),
//               ),
//             ),
//             Padding(
//               padding: const EdgeInsets.all(20),
//               child: Row(
//                 children: [
//                   Expanded(
//                     child: OutlinedButton(
//                       style: OutlinedButton.styleFrom(
//                         side: BorderSide(color: Colors.white),
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(30),
//                         ),
//                         padding: EdgeInsets.symmetric(vertical: 14),
//                       ),
//                       onPressed: () {
//                         Navigator.pop(context);
//                       },
//                       child: Text(
//                         "Retake",
//                         style: TextStyle(color: Colors.white),
//                       ),
//                     ),
//                   ),
//                   SizedBox(width: 12),
//                   Expanded(
//                     child: ElevatedButton(
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: Colors.white,
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(30),
//                         ),
//                         padding: EdgeInsets.symmetric(vertical: 14),
//                       ),
//                       onPressed: () {
//                         Navigator.pop(context, imagePath);
//                       },
//                       child: Text(
//                         "Use Photo",
//                         style: TextStyle(color: Colors.black),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'dart:io';
import 'package:flutter/material.dart';

class PreviewScreen extends StatefulWidget {
  final String imagePath;
  final bool isFront;

  const PreviewScreen({
    super.key,
    required this.imagePath,
    required this.isFront,
  });

  @override
  State<PreviewScreen> createState() => _PreviewScreenState();
}

class _PreviewScreenState extends State<PreviewScreen> {
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

  // ✅ FIX #2: Check if file exists
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

  // ✅ FIX #3: Safe image widget with error handling
  Widget _buildImage() {
    if (!_doesFileExist()) {
      return Column(
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
            style: TextStyle(color: Colors.white54, fontSize: 16),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => _safePop(),
            child: const Text("Go Back"),
          ),
        ],
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Image.file(
        File(widget.imagePath),
        fit: BoxFit.contain,
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
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // ✅ FIX #4: Proper back button with GestureDetector
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => _safePop(),
                    child: const Icon(Icons.arrow_back, color: Colors.white),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    widget.isFront ? "ID Card (Front)" : "ID Card (Back)",
                    style: const TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Center(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white, width: 1),
                  ),
                  child: _buildImage(),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.white),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: () => _safePop(),
                      child: const Text(
                        "Retake",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: () => _safePop(result: widget.imagePath),
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
      ),
    );
  }
}

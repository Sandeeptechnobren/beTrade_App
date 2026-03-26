import 'dart:io';

import 'package:flutter/material.dart';


class SelfiePreviewScreen extends StatelessWidget {
  final String imagePath;

  const SelfiePreviewScreen({required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: [
          Expanded(
            child: Image.file(
              File(imagePath),
              fit: BoxFit.cover,
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                // Retake
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text("Retake",
                        style: TextStyle(color: Colors.white)),
                  ),
                ),

                SizedBox(width: 12),

                // Use Photo
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                    ),
                    onPressed: () {
                      Navigator.pop(context); // back to camera
                      Navigator.pop(context, imagePath); // return to step
                    },
                    child: Text("Use Photo",
                        style: TextStyle(color: Colors.black)),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
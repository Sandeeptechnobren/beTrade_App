import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SelfiePreviewScreen extends StatelessWidget {
  final String imagePath;
  const SelfiePreviewScreen({required this.imagePath});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: [
          Expanded(child: Image.file(File(imagePath), fit: BoxFit.cover)),
          Padding(
            padding:EdgeInsets.all(20.w),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text("Retake", style: TextStyle(color: Colors.white),),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.white,),
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.pop(context, imagePath);
                    },
                    child: Text("Use Photo", style: TextStyle(color: Colors.black),),
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

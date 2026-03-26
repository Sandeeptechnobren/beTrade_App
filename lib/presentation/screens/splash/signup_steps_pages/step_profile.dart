import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/theme/app_text_style.dart';

class StepProfile extends StatefulWidget {
  final Function(File) onImageSelected;
  const StepProfile({super.key, required this.onImageSelected});
  @override
  State<StepProfile> createState() => _StepProfileState();
}

class _StepProfileState extends State<StepProfile> {
  File? selectedImage;
  final ImagePicker picker = ImagePicker();
  List<String> avatarList = [
    "assets/images/avt1 (1).png",
    "assets/images/avt1 (2).png",
    "assets/images/avt1 (3).png",
    "assets/images/avt1 (4).png",
    "assets/images/avt1 (5).png",
    "assets/images/avt1 (6).png",
    "assets/images/avt1 (7).png",
    "assets/images/avt1 (8).png",
    "assets/images/avt1 (9).png",
    "assets/images/avt1 (10).png",
    "assets/images/avt1 (11).png",
    "assets/images/avt1 (12).png",
    "assets/images/avt1 (13).png",
    "assets/images/avt1 (14).png",
    "assets/images/avt1 (15).png",
    "assets/images/avt1 (16).png",
  ];
  String? selectedAvatar;

  Future pickFromCamera() async {
    final picked = await picker.pickImage(source: ImageSource.camera);
    if (picked != null) {
      final file = File(picked.path);
      setState(() => selectedImage = file);
      widget.onImageSelected(file);
    }
  }

  Future pickFromGallery() async {
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      final file = File(picked.path);
      setState(() => selectedImage = file);
      widget.onImageSelected(file);
    }
  }

  void openOptionsSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40.w,
                height: 4.h,
                margin: EdgeInsets.only(bottom: 12.h),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10.r),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: Icon(Icons.arrow_back_ios_new, size: 18.sp),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                      ),
                      SizedBox(width: 10.w),
                      Text(
                        "Select an Option",
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 5.h),
                  Divider(thickness: 1, color: Colors.grey.shade300),
                ],
              ),
              SizedBox(height: 10.h),
              optionTile(
                icon: Icons.camera_alt,
                text: "Take a Selfie",
                onTap: () {
                  Navigator.pop(context);
                  pickFromCamera();
                },
              ),
              SizedBox(height: 10.h),
              optionTile(
                icon: Icons.image,
                text: "Choose from Gallery",
                onTap: () {
                  Navigator.pop(context);
                  pickFromGallery();
                },
              ),
              SizedBox(height: 10.h),
              optionTile(
                icon: Icons.emoji_emotions_outlined,
                text: "Select an Avatar",
                onTap: () {
                  Navigator.pop(context);
                  openAvatarSheet();
                },
              ),
              SizedBox(height: 10.h),
            ],
          ),
        );
      },
    );
  }

  Widget optionTile({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(14.r),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8.w),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 20.sp, color: Colors.black87),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                text,
                style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500),
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 16.sp),
          ],
        ),
      ),
    );
  }

  void openAvatarSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return Container(
          height: 500.h,
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
          ),
          child: Column(
            children: [
              Container(
                width: 40.w,
                height: 4.h,
                margin: EdgeInsets.only(bottom: 12.h),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10.r),
                ),
              ),

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: Icon(Icons.arrow_back_ios_new, size: 18.sp),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                      ),
                      SizedBox(width: 10.w),
                      Text("Select an Avatar", style: AppTextStyle.heading),
                    ],
                  ),
                  SizedBox(height: 5.h),
                  Divider(thickness: 1, color: Colors.grey.shade300),
                ],
              ),
              SizedBox(height: 10.h),
              Expanded(
                child: GridView.builder(
                  itemCount: avatarList.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    crossAxisSpacing: 12.w,
                    mainAxisSpacing: 12.h,
                  ),
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        selectedAvatar = avatarList[index];
                        setState(() {});

                        Navigator.pop(context);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: selectedAvatar == avatarList[index]
                              ? Border.all(color: Colors.purple, width: 2.w)
                              : null,
                        ),
                        child: CircleAvatar(
                          radius: 31.r,
                          backgroundColor: Colors.grey.shade100,
                          backgroundImage: AssetImage(avatarList[index]),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Add Profile Picture", style: AppTextStyle.heading),
        SizedBox(height: 20.h),
        GestureDetector(
          onTap: openOptionsSheet,
          child: Container(
            height: 180.h,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(15.r),
            ),
            child: selectedImage == null
                ? Icon(Icons.add_a_photo)
                : Image.file(selectedImage!, fit: BoxFit.cover),
          ),
        ),
      ],
    );
  }
}

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_style.dart';
import '../../../data/provider/profile_provider.dart';
import '../../widget/common_bottom_sheet.dart';
import '../../widget/common_header.dart';
import '../../widget/customSnackBar.dart';
import 'select_avatar_sheet.dart';

/// "Edit Profile Photo" sheet — three options:
///   • Take a Selfie       → camera (image_picker)
///   • Choose from Gallery → gallery (image_picker)
///   • Select an Avatar    → opens the avatar grid sheet
///
/// Camera/gallery picks are uploaded straight away via
/// `ProfileProvider.updateProfile`; the avatar path is handled by
/// `SelectAvatarSheet`.
class EditProfilePhotoSheet extends StatefulWidget {
  final ScrollController scrollController;

  const EditProfilePhotoSheet({super.key, required this.scrollController});

  @override
  State<EditProfilePhotoSheet> createState() => _EditProfilePhotoSheetState();
}

class _EditProfilePhotoSheetState extends State<EditProfilePhotoSheet> {
  bool _uploading = false;

  Future<void> _pick(ImageSource source) async {
    if (_uploading) return;
    try {
      final picker = ImagePicker();
      final XFile? picked = await picker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 1024,
      );
      if (picked == null) return; // user cancelled
      await _upload(File(picked.path));
    } catch (e) {
      debugPrint("❌ Image pick error: $e");
      if (mounted) {
        CustomSnackBar.showError(
          context,
          message: source == ImageSource.camera
              ? "Could not open the camera"
              : "Could not open the gallery",
        );
      }
    }
  }

  Future<void> _upload(File file) async {
    if (!mounted) return;
    setState(() => _uploading = true);

    final provider = context.read<ProfileProvider>();
    final p = provider.profile;

    final ok = await provider.updateProfile(
      firstName: p?.firstName ?? '',
      lastName: p?.lastName ?? '',
      phone: p?.phone ?? '',
      image: file,
    );

    if (!mounted) return;
    setState(() => _uploading = false);

    if (ok) {
      CustomSnackBar.showSuccess(context, message: "Profile photo updated");
      Navigator.of(context).pop();
    } else {
      CustomSnackBar.showError(context, message: "Failed to update photo");
    }
  }

  void _openAvatars() {
    if (_uploading) return;
    CommonBottomSheet.open(
      context: context,
      // Fixed = content-hugging: the sheet is exactly as tall as the grid
      // (Figma ≈ 434px), with no draggable expansion and no empty white band.
      fixed: true,
      builder: (controller) =>
          SelectAvatarSheet(scrollController: controller),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Content-hugging (mainAxisSize.min) — opened via CommonBottomSheet
    // `fixed: true`, so the sheet is exactly this tall (Figma ≈ 360px) and
    // doesn't drag/scroll.
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const CommonHeader(title: "Edit Profile Photo", showDivider: true),
        Padding(
          padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 20.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _option(
                "assets/svgs/camera.svg",
                "Take a Selfie",
                    () => _pick(ImageSource.camera),
              ),
              SizedBox(height: 12.h,),
              _option(
                "assets/svgs/galary.svg",
                "Choose from Gallery",
                    () => _pick(ImageSource.gallery),
              ),
              SizedBox(height: 12.h,),
              _option(
                "assets/svgs/smile.svg",
                "Select an Avatar",
                _openAvatars,
              ),
              if (_uploading) ...[
                SizedBox(height: 24.h),
                Center(
                  child: SizedBox(
                    width: 26.w,
                    height: 26.w,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor:
                          AlwaysStoppedAnimation<Color>(AppColors.primary),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
  Widget _option(String asset, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: _uploading ? null : onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 18.h),
        decoration: BoxDecoration(
          color: AppColors.iconContainerDynamic(context),
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Row(
          children: [
            SvgPicture.asset(
              asset,
              width: 28.w,
              height: 28.w,
              fit: BoxFit.contain,
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontFamily: AppTextStyle.fontFamily,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimaryDynamic(context),
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16.sp,
              color: AppColors.textPrimaryDynamic(context),
            ),
          ],
        ),
      ),
    );
  }
  //
  // Widget _option(String asset, String label, VoidCallback onTap) {
  //   return GestureDetector(
  //     onTap: _uploading ? null : onTap,
  //     behavior: HitTestBehavior.opaque,
  //     child: Container(
  //       padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 18.h),
  //       decoration: BoxDecoration(
  //         // Figma input row — #F4F4F5, radius 15.6
  //         color: const Color(0xFFF4F4F5),
  //         borderRadius: BorderRadius.circular(16.r),
  //       ),
  //       child: Row(
  //         children: [
  //           Image.asset(asset, width: 28.w, height: 28.w, fit: BoxFit.contain),
  //           SizedBox(width: 12.w),
  //           Expanded(
  //             child: Text(
  //               label,
  //               style: TextStyle(
  //                 fontFamily: AppTextStyle.fontFamily,
  //                 fontSize: 16.sp,
  //                 fontWeight: FontWeight.w500,
  //                 color: const Color(0xFF18181B),
  //               ),
  //             ),
  //           ),
  //           Icon(
  //             Icons.arrow_forward_ios,
  //             size: 16.sp,
  //             color: const Color(0xFF1C274C),
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }
}

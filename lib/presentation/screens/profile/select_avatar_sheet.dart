import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/provider/profile_provider.dart';
import '../../widget/common_header.dart';
import '../../widget/customSnackBar.dart';

/// "Select an Avatar" sheet — a 4×4 grid of the 16 bundled avatars
/// (`assets/images/avt1 (1..16).png`). Tapping one converts the asset
/// to a temp file and uploads it via `ProfileProvider.updateProfile`
/// (the backend's `avatar` field only accepts a file part).
class SelectAvatarSheet extends StatefulWidget {
  final ScrollController scrollController;

  const SelectAvatarSheet({super.key, required this.scrollController});

  @override
  State<SelectAvatarSheet> createState() => _SelectAvatarSheetState();
}

class _SelectAvatarSheetState extends State<SelectAvatarSheet> {
  bool _uploading = false;
  int? _selected;

  // assets/images/avt1 (1).png ... avt1 (16).png
  static final List<String> _avatars =
      List.generate(16, (i) => 'assets/images/avt1 (${i + 1}).png');

  Future<void> _selectAvatar(int index) async {
    if (_uploading) return;
    setState(() {
      _uploading = true;
      _selected = index;
    });

    final provider = context.read<ProfileProvider>();
    final p = provider.profile;

    try {
      // Bundled asset → temporary File so it can be sent as the multipart
      // `avatar` part (the API doesn't take an asset path / URL).
      final data = await rootBundle.load(_avatars[index]);
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/avatar_${index + 1}.png');
      await file.writeAsBytes(
        data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes),
      );

      final ok = await provider.updateProfile(
        firstName: p?.firstName ?? '',
        lastName: p?.lastName ?? '',
        phone: p?.phone ?? '',
        image: file,
      );

      if (!mounted) return;
      setState(() => _uploading = false);

      if (ok) {
        // Snackbar first (app-level messenger survives the pop), then
        // close both sheets (avatar + edit-photo) back to Profile.
        CustomSnackBar.showSuccess(context, message: "Avatar updated");
        Navigator.of(context).popUntil((route) => route.isFirst);
      } else {
        CustomSnackBar.showError(context, message: "Failed to update avatar");
      }
    } catch (e) {
      debugPrint("❌ Avatar upload error: $e");
      if (!mounted) return;
      setState(() => _uploading = false);
      CustomSnackBar.showError(context, message: "Something went wrong");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const CommonHeader(title: "Select an Avatar", showDivider: true),
        Expanded(
          child: GridView.builder(
            controller: widget.scrollController,
            padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 12.h),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              mainAxisSpacing: 16.h,
              crossAxisSpacing: 13.w,
            ),
            itemCount: _avatars.length,
            itemBuilder: (context, i) {
              final selected = _selected == i;
              return GestureDetector(
                onTap: () => _selectAvatar(i),
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: selected
                          ? AppColors.primary
                          : const Color(0xFFF4F4F5),
                      width: selected ? 2.5 : 1,
                    ),
                    image: DecorationImage(
                      image: AssetImage(_avatars[i]),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: (_uploading && selected)
                      ? Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.black.withValues(alpha: 0.35),
                          ),
                          child: Center(
                            child: SizedBox(
                              width: 18.w,
                              height: 18.w,
                              child: const CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        )
                      : null,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

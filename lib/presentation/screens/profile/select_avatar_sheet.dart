import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/provider/profile_provider.dart';
import '../../widget/common_header.dart';
import '../../widget/customSnackBar.dart';

/// "Select an Avatar" sheet — a 4×4 grid of the 16 bundled avatar SVGs
/// (`assets/svgs/Frame 25..28*.svg`). Tapping one rasterizes the SVG to a
/// PNG temp file and uploads it via `ProfileProvider.updateProfile`
/// (the backend's `avatar` field only accepts a raster file part).
class SelectAvatarSheet extends StatefulWidget {
  final ScrollController scrollController;

  const SelectAvatarSheet({super.key, required this.scrollController});

  @override
  State<SelectAvatarSheet> createState() => _SelectAvatarSheetState();
}

class _SelectAvatarSheetState extends State<SelectAvatarSheet> {
  bool _uploading = false;
  int? _selected;

  // 16 frame avatars from assets/svgs/ (Frame 25..28 variants).
  static const List<String> _avatars = [
    'assets/svgs/Frame 25.svg',
    'assets/svgs/Frame 25 (1).svg',
    'assets/svgs/Frame 25 (2).svg',
    'assets/svgs/Frame 25 (3).svg',
    'assets/svgs/Frame 26.svg',
    'assets/svgs/Frame 26 (1).svg',
    'assets/svgs/Frame 26 (2).svg',
    'assets/svgs/Frame 26 (3).svg',
    'assets/svgs/Frame 27.svg',
    'assets/svgs/Frame 27 (1).svg',
    'assets/svgs/Frame 27 (2).svg',
    'assets/svgs/Frame 27 (3).svg',
    'assets/svgs/Frame 28.svg',
    'assets/svgs/Frame 28 (1).svg',
    'assets/svgs/Frame 28 (2).svg',
    'assets/svgs/Frame 28 (3).svg',
  ];

  Future<void> _selectAvatar(int index) async {
    if (_uploading) return;
    setState(() {
      _uploading = true;
      _selected = index;
    });

    final provider = context.read<ProfileProvider>();
    final p = provider.profile;

    try {
      // SVG avatar → rasterized PNG temp file so it can be sent as the
      // multipart `avatar` part (the API only accepts a raster file).
      final dir = await getTemporaryDirectory();
      final file = await _svgToPngFile(
        _avatars[index],
        '${dir.path}/avatar_${index + 1}.png',
      );
      if (file == null) {
        if (!mounted) return;
        setState(() => _uploading = false);
        CustomSnackBar.showError(context, message: "Failed to update avatar");
        return;
      }

      final ok = await provider.updateProfile(
        firstName: p?.firstName ?? '',
        lastName: p?.lastName ?? '',
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
    // Content-hugging (mainAxisSize.min) — opened via CommonBottomSheet
    // `fixed: true`, so the sheet is exactly this tall (Figma ≈ 434px) and
    // doesn't drag/scroll. The grid shrink-wraps and never scrolls.
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const CommonHeader(title: "Select an Avatar", showDivider: true),
        Padding(
          padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 12.h),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
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
                          : AppColors.borderDynamic(context),
                      width: selected ? 2.5 : 1,
                    ),
                  ),
                  child: ClipOval(
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        SvgPicture.asset(_avatars[i], fit: BoxFit.cover),
                        if (_uploading && selected)
                          DecoratedBox(
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
                          ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

/// Rasterizes a bundled SVG asset to a PNG temp file (preserving aspect ratio)
/// so it can be uploaded as a raster image. Returns null on failure.
Future<File?> _svgToPngFile(String assetPath, String outPath,
    {int maxSize = 512}) async {
  try {
    final String rawSvg = await rootBundle.loadString(assetPath);
    final info = await vg.loadPicture(SvgStringLoader(rawSvg), null);
    final double w = info.size.width;
    final double h = info.size.height;
    final double maxSide = w > h ? w : h;
    final double scale = maxSide > 0 ? maxSize / maxSide : 1.0;
    int outW = (w * scale).round();
    int outH = (h * scale).round();
    if (outW < 1) outW = 1;
    if (outH < 1) outH = 1;
    final ui.PictureRecorder recorder = ui.PictureRecorder();
    final ui.Canvas canvas = ui.Canvas(recorder);
    canvas.scale(scale, scale);
    canvas.drawPicture(info.picture);
    final ui.Picture raster = recorder.endRecording();
    final ui.Image image = await raster.toImage(outW, outH);
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    info.picture.dispose();
    raster.dispose();
    image.dispose();
    if (bytes == null) return null;
    final file = File(outPath);
    await file.writeAsBytes(bytes.buffer.asUint8List());
    return file;
  } catch (e) {
    debugPrint("❌ SVG→PNG raster error: $e");
    return null;
  }
}

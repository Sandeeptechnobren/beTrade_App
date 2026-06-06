import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_style.dart';
import '../../../widget/common_header.dart';
import '../../../widget/customSnackBar.dart';
import '../../../widget/custom_camera.dart';

class StepProfile extends StatefulWidget {
  final Function(File) onImageSelected;
  final Function(bool) onValidationChanged;

  const StepProfile({
    super.key,
    required this.onImageSelected,
    required this.onValidationChanged,
  });

  @override
  State<StepProfile> createState() => _StepProfileState();
}

class _StepProfileState extends State<StepProfile> {
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  // 16 frame avatars from assets/svgs/ (Frame 25..28 variants).
  final List<String> _avatarList = const [
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
  String? _selectedAvatar;
  bool _isDisposed = false;
  bool _isProcessing = false;

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  void _safeSetState(VoidCallback fn) {
    if (!_isDisposed && mounted) {
      setState(fn);
    }
  }

  Future<File> _copyImageToTempDirectory(File originalImage,
      {bool isCamera = false}) async {
    try {
      final Directory tempDir = await getTemporaryDirectory();
      final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      // Camera images ka extension force karo .jpg
      final String fileName = 'profile_image_$timestamp.jpg';
      final String tempPath = '${tempDir.path}/$fileName';

      final File tempFile = await originalImage.copy(tempPath);
      print("✅ Image copied to: ${tempFile.path}");
      return tempFile;
    } catch (e) {
      print("❌ Error copying image: $e");
      return originalImage;
    }
  }

  Future<File> _compressAndSaveImage(File originalImage) async {
    try {
      final Directory tempDir = await getTemporaryDirectory();
      final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      final String targetPath = '${tempDir.path}/profile_image_$timestamp.jpg';

      final XFile? compressedXFile =
          await FlutterImageCompress.compressAndGetFile(
        originalImage.path,
        targetPath,
        quality: 70, // 70% quality kaafi hai
        minWidth: 800, // max width 800px
        minHeight: 800, // max height 800px
        format: CompressFormat.jpeg,
      );

      if (compressedXFile == null) {
        print("❌ Compression failed, using original");
        return originalImage;
      }

      final File compressedFile = File(compressedXFile.path);
      print(
          "✅ Compressed: ${await compressedFile.length()} bytes at ${compressedFile.path}");
      return compressedFile;
    } catch (e) {
      print("❌ Compress error: $e");
      return originalImage;
    }
  }

  void _updateImage(File file) {
    if (_isDisposed || !mounted) return;

    _safeSetState(() => _selectedImage = file);

    try {
      widget.onImageSelected(file);
      widget.onValidationChanged(true);
    } catch (e) {
      debugPrint("❌ Image update error: $e");
    }
  }

  Future<bool> _requestCameraPermission() async {
    try {
      final status = await Permission.camera.request();
      if (status.isGranted) return true;
      if (status.isPermanentlyDenied) {
        if (mounted) {
          _showPermissionDeniedDialog();
        }
        return false;
      }
      return false;
    } catch (e) {
      debugPrint("❌ Permission error: $e");
      return false;
    }
  }

  Future<bool> _requestGalleryPermission() async {
    try {
      final status = await Permission.photos.request();
      if (status.isGranted) return true;
      if (status.isPermanentlyDenied) {
        if (mounted) {
          _showPermissionDeniedDialog();
        }
        return false;
      }
      return false;
    } catch (e) {
      debugPrint("❌ Permission error: $e");
      return false;
    }
  }

  void _showPermissionDeniedDialog() {
    if (_isDisposed || !mounted) return;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Permission Required"),
        content: const Text(
            "Please enable camera and photo access in Settings to use this feature."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              openAppSettings();
            },
            child: const Text("Open Settings"),
          ),
        ],
      ),
    );
  }

  Future<void> _pickFromCamera() async {
    if (_isDisposed || !mounted || _isProcessing) return;
    _isProcessing = true;

    final hasPermission = await _requestCameraPermission();
    if (!hasPermission) {
      _isProcessing = false;
      return;
    }

    try {
      final File? photo = await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const CustomCameraScreen()),
      );

      if (_isDisposed || !mounted) return;

      if (photo != null) {
        final File compressedFile = await _compressAndSaveImage(photo);
        _updateImage(compressedFile);
      }
    } catch (e) {
      debugPrint("❌ Camera error: $e");
      if (mounted) _showError("Failed to capture image");
    } finally {
      if (!_isDisposed && mounted) _isProcessing = false;
    }
  }

  Future<void> _pickAvatar(String assetPath) async {
    if (_isDisposed || !mounted || _isProcessing) return;
    _isProcessing = true;

    try {
      // Close the avatar sheet immediately for a snappy feel.
      if (Navigator.of(context).canPop()) {
        Navigator.pop(context);
      }

      // 1. Rasterize the bundled SVG avatar to a PNG temp file.
      final tempDir = await getTemporaryDirectory();
      final srcPath =
          '${tempDir.path}/avatar_src_${DateTime.now().millisecondsSinceEpoch}.png';
      final srcFile = await _svgToPngFile(assetPath, srcPath);

      if (_isDisposed || !mounted) return;
      if (srcFile == null) {
        _showError("Failed to set avatar");
        return;
      }

      // 2. Run it through the same JPEG compression pipeline as
      //    camera / gallery so completeSignup uploads a consistent format.
      final File compressedFile = await _compressAndSaveImage(srcFile);

      if (_isDisposed || !mounted) return;

      // 3. Mark visual selection and propagate to the parent.
      _safeSetState(() {
        _selectedAvatar = assetPath;
      });
      _updateImage(compressedFile);
    } catch (e) {
      debugPrint("❌ Avatar picker error: $e");
      if (mounted) _showError("Failed to set avatar");
    } finally {
      if (!_isDisposed && mounted) _isProcessing = false;
    }
  }

  Future<void> _pickFromGallery() async {
    if (_isDisposed || !mounted || _isProcessing) return;
    _isProcessing = true;

    final hasPermission = await _requestGalleryPermission();
    if (!hasPermission) {
      _isProcessing = false;
      return;
    }

    try {
      final picked = await _picker.pickImage(source: ImageSource.gallery);
      if (_isDisposed || !mounted) return;

      if (picked != null) {
        final File originalFile = File(picked.path);
        // ← sirf yahi line change hui
        final File compressedFile = await _compressAndSaveImage(originalFile);
        _updateImage(compressedFile);
      }
    } catch (e) {
      debugPrint("❌ Gallery error: $e");
      if (mounted) _showError("Failed to select image");
    } finally {
      if (!_isDisposed && mounted) _isProcessing = false;
    }
  }

  void _showError(String message) {
    if (_isDisposed || !mounted) return;
    CustomSnackBar.showError(
      context,
      message: message,
      duration: const Duration(seconds: 3),
    );
  }

  // Widget _safeAvatarImage(String path, bool isSelected) {
  //   return Container(
  //     decoration: BoxDecoration(
  //       shape: BoxShape.circle,
  //       border: isSelected
  //           ? Border.all(
  //         color: AppColors.primary,
  //         width: 2.w,
  //       )
  //           : null,
  //     ),
  //     child: CircleAvatar(
  //       radius: 31.r,
  //       backgroundColor: AppColors.inputFieldBgDynamic(context),
  //       backgroundImage: AssetImage(path),
  //       onBackgroundImageError: (_, __) {
  //         debugPrint("❌ Avatar missing: $path");
  //       },
  //       child: Container(
  //         decoration: BoxDecoration(
  //           shape: BoxShape.circle,
  //           color: Colors.grey.shade300,
  //         ),
  //         child: const Icon(Icons.person),
  //       ),
  //     ),
  //   );
  // }

  Widget _safeAvatarImage(String path, bool isSelected) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: isSelected
            ? Border.all(
                color: AppColors.primary,
                width: 2.w,
              )
            : null,
      ),
      child: ClipOval(
        child: SvgPicture.asset(
          path,
          width: 62.w,
          height: 62.w,
          fit: BoxFit.cover,
          placeholderBuilder: (_) {
            return Container(
              width: 62.w,
              height: 62.w,
              color: Colors.grey.shade300,
              child: const Icon(Icons.person),
            );
          },
        ),
      ),
    );
  }

  void _openOptionsSheet() {
    if (_isDisposed || !mounted) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildOptionsSheet(context),
    );
  }

  Widget _buildOptionsSheet(BuildContext context) {
    return Container(
      // padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      decoration: BoxDecoration(
        color: AppColors.cardBackgroundDynamic(context),
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.r)),
      ),
      child: Padding(
        padding: EdgeInsets.only(bottom: 20.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CommonHeader(
                    title: "Select an option", showDivider: true),
              ],
            ),
            SizedBox(height: 10.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 0.h),
              child: _optionTile("assets/images/c.png", "Take a Selfie", () {
                Navigator.pop(context);
                _pickFromCamera();
              }),
            ),
            SizedBox(height: 10.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 0.h),
              child:
                  _optionTile("assets/images/g.png", "Choose from Gallery", () {
                Navigator.pop(context);
                _pickFromGallery();
              }),
            ),
            SizedBox(height: 10.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 0.h),
              child: _optionTile("assets/images/smile.png", "Select an Avatar",
                  () {
                Navigator.pop(context);
                _openAvatarSheet();
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _optionTile(String asset, String text, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 18.h),
        decoration: BoxDecoration(
          // Figma input row — #F4F4F5, radius 15.6
          color: AppColors.iconContainerDynamic(context),
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Row(
          children: [
            Image.asset(asset, width: 28.w, height: 28.w, fit: BoxFit.contain),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                text,
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

  void _openAvatarSheet() {
    if (_isDisposed || !mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildAvatarSheet(context),
    );
  }

  Widget _buildAvatarSheet(BuildContext context) {
    return Container(
      height: 470.h,
      // padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      decoration: BoxDecoration(
        color: AppColors.cardBackgroundDynamic(context),
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.r)),
      ),
      child: Column(
        children: [
          const CommonHeader(title: "Select an Avatar", showDivider: true),
          SizedBox(height: 10.h),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
              child: GridView.builder(
                itemCount: _avatarList.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  crossAxisSpacing: 12.w,
                  mainAxisSpacing: 12.h,
                ),
                itemBuilder: (context, index) {
                  final avatarPath = _avatarList[index];
                  final isSelected = _selectedAvatar == avatarPath;

                  return GestureDetector(
                    onTap: () => _pickAvatar(avatarPath),
                    child: _safeAvatarImage(avatarPath, isSelected),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isDisposed) return const SizedBox();

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Add Profile Picture",
            style: AppTextStyle.heading.copyWith(
              color: AppColors.textPrimaryDynamic(context),
            ),
          ),
          SizedBox(height: 20.h),
          GestureDetector(
            onTap: _openOptionsSheet,
            child: Container(
              height: 300.h,
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.inputFieldBgDynamic(context),
                borderRadius: BorderRadius.circular(15.r),
                border: Border.all(
                  color: AppColors.borderDynamic(context),
                ),
              ),
              child: _selectedImage == null
                  ? Icon(
                      Icons.add_a_photo,
                      size: 40.sp,
                      color: AppColors.textSecondaryDynamic(context),
                    )
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(15.r),
                      child: Image.file(
                        _selectedImage!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Icon(Icons.error),
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Rasterizes a bundled SVG asset to a PNG temp file (preserving aspect ratio)
/// so it can be compressed/uploaded as a raster image. Returns null on failure.
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

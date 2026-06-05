import 'dart:io';
import 'package:betrade/core/theme/app_colors.dart';
import 'package:betrade/core/theme/app_text_style.dart';
import 'package:betrade/presentation/screens/verification/step_heder.dart';
import 'package:betrade/presentation/widget/purple_button.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax/iconsax.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../core/config/api_endpoint.dart';
import '../../../core/network/dio_client.dart';
import '../../../data/model/country_model.dart';
import '../../../data/services/local_storage.dart';
import '../../../data/services/profile_service.dart';
import '../../widget/customSnackBar.dart';
import '../camera/camera_screen.dart';
import '../camera/selfie_camera.dart';
import '../main_screen.dart';
import 'country_services_step_one.dart';

class VerificationFlow extends StatefulWidget {
  @override
  State<VerificationFlow> createState() => _VerificationFlowState();
}

class _VerificationFlowState extends State<VerificationFlow> {
  int currentStep = 0;
  File? selfieImage;
  bool isSelfieUploaded = false;
  File? frontImage;
  File? backImage;
  bool isLoading = true;
  bool isFrontUploaded = false;
  bool isBackUploaded = false;
  bool isSubmittingKyc = false;
  bool _isProcessingNext = false; // step-0 "Next" loader (preferences POST)
  bool _isDisposed = false;
  bool _isNavigating = false;

  final ImagePicker picker = ImagePicker();
  List<CountryModel> countries = [];
  CountryModel? selectedCountry;
  List<DropdownItem> languages = [];
  DropdownItem? language;
  String? selectedCurrency;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (!_isDisposed && mounted) {
        loadAllData();
      }
    });
  }

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

  // ✅ FIX #1: Safe data extraction
  dynamic _safeGetData(dynamic data, String key) {
    try {
      if (data != null && data is Map<String, dynamic>) {
        return data[key];
      }
      return null;
    } catch (e) {
      debugPrint("❌ Data extraction error: $e");
      return null;
    }
  }

  Future<void> loadAllData() async {
    if (_isDisposed) return;

    try {
      _safeSetState(() => isLoading = true);

      final countryRes = await CountryService.fetchCountries();
      if (!_isDisposed && mounted) {
        countries = countryRes ?? [];
        if (countries.isNotEmpty) {
          selectedCountry = countries.first;
          selectedCurrency = selectedCountry?.currency;
        }
      }

      final token = LocalStorage.getToken();
      if (token == null) {
        _safeSetState(() => isLoading = false);
        return;
      }

      final response = await DioClient.instance.get(
        ApiEndpoints.languages,
        options: Options(
          headers: {
            "Accept": "application/json",
            "Authorization": "Bearer $token",
          },
          receiveTimeout: const Duration(seconds: 30),
          sendTimeout: const Duration(seconds: 30),
        ),
      );

      if (!_isDisposed && mounted && response.statusCode == 200) {
        final data = response.data;
        final dataList = _safeGetData(data, 'data');

        if (dataList is List) {
          languages = dataList
              .where((e) => e != null && e is Map)
              .map((e) => DropdownItem(
            id: (e['id'] ?? 0) as int,
            name: (e['name'] ?? '') as String,
          ))
              .toList();
          if (languages.isNotEmpty) {
            language = languages.first;
          }
        }
      }

      if (!_isDisposed && mounted) {
        _safeSetState(() => isLoading = false);
      }
    } catch (e) {
      debugPrint("❌ Load data error: $e");
      if (!_isDisposed && mounted) {
        _safeSetState(() => isLoading = false);
        _showError("Failed to load data");
      }
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

  bool isStep2Valid() {
    return frontImage != null && backImage != null;
  }

  /// Builds a Dio MultipartFile from a local image. The `field` arg is kept
  /// for caller-side readability; in Dio the field name is supplied via the
  /// FormData map key, not on the MultipartFile itself.
  Future<MultipartFile?> _safeMultipartFile(String field, File file) async {
    try {
      if (!await file.exists()) {
        debugPrint("❌ File does not exist: ${file.path}");
        return null;
      }
      return await MultipartFile.fromFile(file.path);
    } catch (e) {
      debugPrint("❌ MultipartFile error: $e");
      return null;
    }
  }
  void _navigateToTab(int index) {
    if (_isDisposed || !mounted || _isNavigating) return;
    _isNavigating = true;
    Future.delayed(const Duration(milliseconds: 100), () {
      if (!_isDisposed && mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => MainScreen(initialIndex: index)),
              (route) => false,
        );
      }
    });
  }

  /// Figma "You're verified 🎉" success popup shown after a successful KYC
  /// submit. "Make a Deposit" → Portfolio tab (3); "Skip for now" → Home (0).
  Future<void> _showVerifiedDialog() async {
    if (_isDisposed || !mounted) return;
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) {
        final bool isDark =
            Theme.of(dialogCtx).brightness == Brightness.dark;
        return PopScope(
          canPop: false,
          child: Dialog(
            backgroundColor: AppColors.cardBackgroundDynamic(dialogCtx),
            insetPadding: EdgeInsets.symmetric(horizontal: 28.w),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(32.r),
            ),
            child: Padding(
              padding: EdgeInsets.all(20.w),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "You're verified 🎉",
                    style: TextStyle(
                      fontFamily: 'SFProRounded',
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimaryDynamic(dialogCtx),
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    "Your account is ready. Make a deposit to start trading on live markets.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'SFProRounded',
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w400,
                      color: isDark
                          ? AppColors.textSecondaryDynamic(dialogCtx)
                          : const Color(0xFF52525B),
                    ),
                  ),
                  SizedBox(height: 20.h),
                  // Make a Deposit → Portfolio tab
                  SizedBox(
                    width: double.infinity,
                    height: 60.h,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        backgroundColor: const Color(0xFF8E10FC),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(32.r),
                        ),
                      ),
                      onPressed: () {
                        Navigator.of(dialogCtx).pop();
                        _navigateToTab(3);
                      },
                      child: Text(
                        "Make a Deposit",
                        style: TextStyle(
                          fontFamily: 'SFProRounded',
                          fontSize: 15.6.sp,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 12.h),
                  // Skip for now → Home tab
                  SizedBox(
                    width: double.infinity,
                    height: 60.h,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        backgroundColor:
                            AppColors.cardBackgroundDynamic(dialogCtx),
                        side: BorderSide(
                          color: AppColors.borderDynamic(dialogCtx),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(32.r),
                        ),
                      ),
                      onPressed: () {
                        Navigator.of(dialogCtx).pop();
                        _navigateToTab(0);
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Skip for now",
                            style: TextStyle(
                              fontFamily: 'SFProRounded',
                              fontSize: 15.6.sp,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimaryDynamic(dialogCtx),
                            ),
                          ),
                          SizedBox(width: 4.w),
                          Icon(
                            Icons.arrow_forward_ios,
                            size: 16.sp,
                            color: AppColors.textPrimaryDynamic(dialogCtx),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> submitKyc() async {
    debugPrint("\n========== 🔵 SUBMIT KYC STARTED ==========");

    if (isSubmittingKyc || _isDisposed) {
      debugPrint("⏭️  Skipped: isSubmittingKyc=$isSubmittingKyc, _isDisposed=$_isDisposed");
      return;
    }

    if (frontImage == null || backImage == null || selfieImage == null) {
      debugPrint("❌ Missing images — front=${frontImage != null}, back=${backImage != null}, selfie=${selfieImage != null}");
      _showError("Please upload all images");
      return;
    }

    _safeSetState(() => isSubmittingKyc = true);

    try {
      final token = LocalStorage.getToken();
      debugPrint("📌 Token: ${token == null ? "❌ NULL" : "✅ length=${token.length}, prefix=${token.substring(0, token.length > 12 ? 12 : token.length)}…"}");
      if (token == null) {
        _showError("Authentication failed");
        return;
      }

      debugPrint("📌 Source files:");
      debugPrint("   front:  ${frontImage!.path}  (size=${await frontImage!.length()} bytes)");
      debugPrint("   back:   ${backImage!.path}  (size=${await backImage!.length()} bytes)");
      debugPrint("   selfie: ${selfieImage!.path}  (size=${await selfieImage!.length()} bytes)");

      final frontFile = await _safeMultipartFile('id_front', frontImage!);
      final backFile = await _safeMultipartFile('id_back', backImage!);
      final selfieFile = await _safeMultipartFile('selfie', selfieImage!);

      if (frontFile == null || backFile == null || selfieFile == null) {
        debugPrint("❌ Multipart conversion failed — front=${frontFile != null}, back=${backFile != null}, selfie=${selfieFile != null}");
        _showError("Failed to prepare files. Please try again.");
        return;
      }

      final formData = FormData.fromMap({
        'id_front': frontFile,
        'id_back': backFile,
        'selfie': selfieFile,
      });

      debugPrint("📌 URL: ${ApiEndpoints.kycSubmit}");
      debugPrint("📌 Method: POST (multipart)");
      debugPrint("📌 Form fields: ${formData.fields}");
      debugPrint("📌 Form files (count=${formData.files.length}):");
      for (final f in formData.files) {
        debugPrint("   ${f.key} -> filename=${f.value.filename}, length=${f.value.length}, contentType=${f.value.contentType}");
      }

      debugPrint("⏱️  Sending request...");
      final stopwatch = Stopwatch()..start();
      final response = await DioClient.multipartInstance.post(
        ApiEndpoints.kycSubmit,
        data: formData,
        options: Options(
          headers: {
            "Authorization": "Bearer $token",
            "Accept": "application/json",
          },
        ),
      );
      stopwatch.stop();

      debugPrint("⏱️  Response received in ${stopwatch.elapsedMilliseconds} ms");
      debugPrint("📌 Response status: ${response.statusCode}");
      debugPrint("📌 Response headers: ${response.headers.map}");
      debugPrint("📌 Response data type: ${response.data.runtimeType}");
      debugPrint("📌 Response body: ${response.data}");

      // Try to surface backend-reported doc_upload_status if it's in the response
      if (response.data is Map) {
        final m = response.data as Map;
        debugPrint("🔍 status field:            ${m['status']}");
        debugPrint("🔍 message field:           ${m['message']}");
        debugPrint("🔍 doc_upload_status field: ${m['doc_upload_status']}");
        if (m['data'] is Map) {
          final d = m['data'] as Map;
          debugPrint("🔍 data.doc_upload_status:  ${d['doc_upload_status']}");
          debugPrint("🔍 data keys:               ${d.keys.toList()}");
        }
        if (m['user'] is Map) {
          final u = m['user'] as Map;
          debugPrint("🔍 user.doc_upload_status:  ${u['doc_upload_status']}");
          debugPrint("🔍 user keys:               ${u.keys.toList()}");
        }
      }

      if (!_isDisposed && mounted) {
        if (response.statusCode == 200) {
          await LocalStorage.setDocUploadStatus(1);
          debugPrint("✅ Persisted doc_upload_status = 1 locally");
          debugPrint("==========================================\n");
          // Google users have no avatar (signup avatar step skipped) — reuse
          // the KYC selfie as their profile picture. Awaited so the avatar is
          // in place before we land on Home; best-effort (never throws).
          await _setSelfieAsAvatarIfNeeded();
          if (_isDisposed || !mounted) return;
          await _showVerifiedDialog();
        } else {
          debugPrint("❌ Non-200 status, treating as failure");
          debugPrint("==========================================\n");
          _showError("KYC submission failed. Please try again.");
        }
      }
    } on DioException catch (e) {
      debugPrint("❌ DioException type:    ${e.type}");
      debugPrint("❌ DioException message: ${e.message}");
      debugPrint("❌ Status code:          ${e.response?.statusCode}");
      debugPrint("❌ Response headers:     ${e.response?.headers.map}");
      debugPrint("❌ Response data:        ${e.response?.data}");
      debugPrint("❌ Request path:         ${e.requestOptions.uri}");
      debugPrint("==========================================\n");
      if (!_isDisposed && mounted) {
        _showError("An error occurred. Please try again.");
      }
    } catch (e, stack) {
      debugPrint("❌ Unexpected error: $e");
      debugPrint("❌ Stack: $stack");
      debugPrint("==========================================\n");
      if (!_isDisposed && mounted) {
        _showError("An error occurred. Please try again.");
      }
    } finally {
      if (!_isDisposed && mounted) {
        _safeSetState(() => isSubmittingKyc = false);
      }
    }
  }

  /// New Google users skip the signup avatar step, so their profile has no
  /// picture. When such a user finishes KYC, reuse the selfie they just
  /// uploaded as their profile avatar — via the existing /edit-profile
  /// endpoint (no backend change). Only fills an EMPTY avatar, so a user who
  /// already chose a picture during signup is left untouched. Best-effort:
  /// wrapped in try/catch so it never blocks KYC completion.
  Future<void> _setSelfieAsAvatarIfNeeded() async {
    if (selfieImage == null) return;
    try {
      final profile = await ProfileService.getProfile();
      if (profile == null) return;
      if (profile.avatar.trim().isNotEmpty) {
        debugPrint("ℹ️ Avatar already set — skipping selfie-as-avatar");
        return;
      }
      debugPrint("🖼️ No avatar on file — setting KYC selfie as profile avatar");
      await ProfileService.updateProfile(
        firstName: profile.firstName,
        lastName: profile.lastName,
        phone: profile.phone ?? '',
        image: selfieImage,
      );
    } catch (e) {
      debugPrint("Set selfie-as-avatar error (ignored): $e");
    }
  }

  Future<void> submitStep1() async {
    debugPrint("\n========== 🔵 SUBMIT STEP1 (preferences) ==========");
    if (_isDisposed) {
      debugPrint("⏭️  Skipped: _isDisposed=true");
      return;
    }

    try {
      final token = LocalStorage.getToken();
      debugPrint("📌 Token: ${token == null ? "❌ NULL" : "✅ length=${token.length}"}");
      if (token == null) return;

      final body = {
        "country_id": selectedCountry?.id,
        "preferred_language_id": language?.id,
      };
      debugPrint("📌 URL:    ${ApiEndpoints.preferences}");
      debugPrint("📌 Method: POST");
      debugPrint("📌 Body:   $body");
      debugPrint("📌 selectedCountry: id=${selectedCountry?.id}, name=${selectedCountry?.name}, currency=${selectedCountry?.currency}");
      debugPrint("📌 language:        id=${language?.id}, name=${language?.name}");

      final response = await DioClient.instance.post(
        ApiEndpoints.preferences,
        data: body,
        options: Options(
          headers: {
            "Accept": "application/json",
            "Authorization": "Bearer $token",
          },
          receiveTimeout: const Duration(seconds: 30),
          sendTimeout: const Duration(seconds: 30),
        ),
      );

      debugPrint("📌 Response status: ${response.statusCode}");
      debugPrint("📌 Response body:   ${response.data}");
      debugPrint("====================================================\n");
    } on DioException catch (e) {
      debugPrint("❌ submitStep1 DioException type:    ${e.type}");
      debugPrint("❌ submitStep1 DioException message: ${e.message}");
      debugPrint("❌ Status code:                      ${e.response?.statusCode}");
      debugPrint("❌ Response data:                    ${e.response?.data}");
      debugPrint("====================================================\n");
    } catch (e, stack) {
      debugPrint("❌ submitStep1 unexpected error: $e");
      debugPrint("❌ Stack: $stack");
      debugPrint("====================================================\n");
    }
  }

  bool isStepValid() {
    return selectedCountry != null && language != null;
  }

  void nextStep() async {
    if (_isDisposed || _isProcessingNext) return;

    if (currentStep == 0) {
      _safeSetState(() => _isProcessingNext = true);
      await submitStep1();
      if (_isDisposed || !mounted) return;
      _safeSetState(() => _isProcessingNext = false);
    }
    if (currentStep < 2 && mounted) {
      _safeSetState(() => currentStep++);
    }
  }

  Widget _safeImage(File? file, {double? height, double? width}) {
    if (file == null) {
      return Icon(
        Icons.add_a_photo,
        size: 40.sp,
        color: AppColors.textSecondaryDynamic(context),
      );
    }

    return Image.file(
      file,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        debugPrint("❌ Image decode error: $error");
        return Icon(
          Icons.broken_image,
          size: 40.sp,
          color: AppColors.textSecondaryDynamic(context),
        );
      },
    );
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

  void _showPermissionDeniedDialog() {
    if (_isDisposed || !mounted) return;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Camera Permission Required"),
        content: const Text("Please enable camera access in Settings to take photos."),
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
  //
  // Future<void> openCamera(bool isFront) async {
  //   if (_isDisposed || !mounted) return;
  //
  //   final hasPermission = await _requestCameraPermission();
  //   if (!hasPermission) return;
  //
  //   try {
  //     final result = await Navigator.push(
  //       context,
  //       MaterialPageRoute(builder: (_) => CameraScreen(isFront: isFront))
  //     );
  //
  //     if (!_isDisposed && mounted && result != null) {
  //       _safeSetState(() {
  //         if (isFront) {
  //           frontImage = File(result);
  //           isFrontUploaded = true;
  //         } else {
  //           backImage = File(result);
  //           isBackUploaded = true;
  //         }
  //       });
  //     }
  //   } catch (e) {
  //     debugPrint("❌ Camera error: $e");
  //     _showError("Failed to capture image");
  //   }
  // }
  Future<void> openCamera(bool isFront) async {
    if (_isDisposed || !mounted) return;

    final hasPermission = await _requestCameraPermission();
    if (!hasPermission) return;
    if (_isDisposed || !mounted) return;

    try {
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => CameraScreen(
            isFront: isFront,
          ),
        ),
      );

      if (!_isDisposed && mounted && result != null) {
        _safeSetState(() {
          if (isFront) {
            frontImage = File(result);
            isFrontUploaded = true;
          } else {
            backImage = File(result);
            isBackUploaded = true;
          }
        });
      }
    } catch (e) {
      debugPrint("Camera error: $e");
      _showError("Failed to capture image");
    }
  }


  Future<void> openSelfieCamera() async {
    if (_isDisposed || !mounted) return;

    final hasPermission = await _requestCameraPermission();
    if (!hasPermission) return;
    if (_isDisposed || !mounted) return;

    try {
      final result = await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => SelfieCameraScreen()),
      );

      if (!_isDisposed && mounted && result != null) {
        _safeSetState(() {
          selfieImage = File(result);
          isSelfieUploaded = true;
        });
      }
    } catch (e) {
      debugPrint("❌ Selfie camera error: $e");
      _showError("Failed to capture selfie");
    }
  }

  Widget buildStepContent() {
    switch (currentStep) {
      case 0: return step1();
      case 1: return step2();
      case 2: return step3();
      default: return step1();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isDisposed) return const SizedBox();

    return Material(
      color: AppColors.cardBackgroundDynamic(context),
      child: SafeArea(
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.symmetric(vertical: 10.h),
              height: 5.h,
              width: 50.w,
              decoration: BoxDecoration(
                color: AppColors.borderDynamic(context),
                borderRadius: BorderRadius.circular(10.r),
              ),
            ),
            StepHeader(currentStep: currentStep),
            Expanded(
              child: isLoading
                  ? Center(
                child: CircularProgressIndicator(
                  color: AppColors.primary,
                ),
              )
                  : buildStepContent(),
            ),
            if (currentStep != 2)
              Padding(
                padding: EdgeInsets.all(16.w),
                child: currentStep == 1
                    ? _continueButton()
                    : SizedBox(
                        height: 55.h,
                        width: double.infinity,
                        child: Button(
                          title: "Next",
                          isLoading: _isProcessingNext,
                          onPressed: () {
                            if (currentStep == 0 && isStepValid()) {
                              nextStep();
                            }
                          },
                        ),
                      ),
              ),
          ],
        ),
      ),
    );
  }

  Widget step1() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Divider(color: AppColors.borderDynamic(context)),
          SizedBox(height: 20.h),
          buildCountryDropdown(),
          buildCurrencyDropdown(),
          buildLanguageDropdown(),
        ],
      ),
    );
  }

  Widget buildCountryDropdown() {
    // Check if selectedCountry exists in countries list
    final validCountry = countries.any((c) => c.id == selectedCountry?.id)
        ? selectedCountry
        : (countries.isNotEmpty ? countries.first : null);

    if (validCountry != selectedCountry && validCountry != null) {
      selectedCountry = validCountry;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Country", style:AppTextStyle.smallNav),
        SizedBox(height: 8.h),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w),
          decoration: BoxDecoration(
            color: AppColors.inputFieldBgDynamic(context),
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: AppColors.borderDynamic(context)),
          ),
          child:
          DropdownButton<CountryModel>(
            value: validCountry,
            isExpanded: true,
            underline: const SizedBox(),

            /// ✅ THIS IS THE FIX
            selectedItemBuilder: (context) {
              return countries.map((e) {
                return Row(
                  children: [
                    ClipOval(
                      child: Image.network(
                        e.flag ?? "",
                        width: 23,
                        height: 23,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Icon(Icons.flag),
                      ),
                    ),
                    SizedBox(width: 8),
                    Text(e.name ?? 'Unknown'),
                  ],
                );
              }).toList();
            },

            items: countries.map((e) {
              return DropdownMenuItem(
                value: e,
                child: Row(
                  children: [
                    ClipOval(
                      child: Image.network(
                        e.flag ?? "",
                        width: 23.4.w,
                        height: 23.4.h,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Icon(Icons.flag),
                      ),
                    ),
                    SizedBox(width: 8),
                    Text(e.name ?? 'Unknown'),
                  ],
                ),
              );
            }).toList(),

            onChanged: (val) {
              if (val == null) return;
              _safeSetState(() {
                selectedCountry = val;
                selectedCurrency = val.currency;
              });
            },
          )
        ),
        SizedBox(height: 16.h),
      ],
    );
  }

  Widget buildCurrencyDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Currency", style:AppTextStyle.smallNav),
        SizedBox(height: 8.h),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w),
          decoration: BoxDecoration(
            color: AppColors.inputFieldBgDynamic(context),
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: AppColors.borderDynamic(context)),
          ),
          child: DropdownButton<String>(
            value: selectedCurrency,
            isExpanded: true,
            underline: const SizedBox(),
            dropdownColor: AppColors.cardBackgroundDynamic(context),
            style: TextStyle(color: AppColors.textPrimaryDynamic(context)),
            items: selectedCurrency != null
                ? [DropdownMenuItem(value: selectedCurrency, child: Text(selectedCurrency!))]
                : [],
            onChanged: null,
          ),
        ),
        SizedBox(height: 16.h),
      ],
    );
  }

  Widget buildLanguageDropdown() {
    // ✅ FIX #4: Safe language dropdown with validation
    final validLanguage = languages.any((l) => l.id == language?.id)
        ? language
        : (languages.isNotEmpty ? languages.first : null);

    if (validLanguage != language && validLanguage != null) {
      language = validLanguage;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Language", style:AppTextStyle.smallNav),
        SizedBox(height: 8.h),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w),
          decoration: BoxDecoration(
            color: AppColors.inputFieldBgDynamic(context),
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: AppColors.borderDynamic(context)),
          ),
          child: languages.isEmpty
              ? Padding(
            padding: EdgeInsets.all(12.w),
            child: Text("No Language Found"),
          )
              : DropdownButton<DropdownItem>(
            value: validLanguage,
            isExpanded: true,
            underline: const SizedBox(),
            dropdownColor: AppColors.cardBackgroundDynamic(context),
            style: TextStyle(color: AppColors.textPrimaryDynamic(context)),
            items: languages.map((e) {
              return DropdownMenuItem(
                value: e,
                child: Text(e.name),
              );
            }).toList(),
            onChanged: (val) {
              if (val == null) return;
              _safeSetState(() => language = val);
            },
          ),
        ),
        SizedBox(height: 16.h),
      ],
    );
  }

  Widget step2() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 20.h),
          buildUploadBox("ID Card (Front)", frontImage, () => openCamera(true)),
          buildUploadBox("ID Card (Back)", backImage, () => openCamera(false)),
        ],
      ),
    );
  }

  /// Figma "Continue" button for the Upload-Ghana-Card step (step 1).
  /// 50% opacity / disabled until BOTH ID images are captured.
  Widget _continueButton() {
    final bool enabled = isStep2Valid();
    return SizedBox(
      width: double.infinity,
      height: 60.h,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: const Color(0xFF8E10FC),
          disabledBackgroundColor: const Color(0xFF8E10FC).withValues(alpha: 0.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(32.r),
          ),
        ),
        onPressed: enabled ? nextStep : null,
        child: Text(
          "Continue",
          style: TextStyle(
            fontFamily: 'SFProRounded',
            fontSize: 15.6.sp,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget step3() {
    final bool enabled = isSelfieUploaded && !isSubmittingKyc;
    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Divider(color: AppColors.borderDynamic(context)),
          SizedBox(height: 20.h),
          // Figma: "Selfie of Yourself" label (16 / w600 / #09090B)
          Text(
            "Selfie of Yourself",
            style: TextStyle(
              fontFamily: 'SFProRounded',
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimaryDynamic(context),
            ),
          ),
          SizedBox(height: 12.h),
          buildSelfieBox(),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            height: 60.h,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                elevation: 0,
                backgroundColor: const Color(0xFF8E10FC),
                disabledBackgroundColor:
                    const Color(0xFF8E10FC).withValues(alpha: 0.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(32.r),
                ),
              ),
              onPressed: enabled
                  ? () async {
                      if (frontImage == null || backImage == null) {
                        _showError("Upload ID images first");
                        return;
                      }
                      await submitKyc();
                    }
                  : null,
              child: isSubmittingKyc
                  ? SizedBox(
                      height: 24.h,
                      width: 24.h,
                      child: const CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      "Verify my account",
                      style: TextStyle(
                        fontFamily: 'SFProRounded',
                        fontSize: 15.6.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildUploadBox(String title, File? image, VoidCallback onTap) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Figma: 16px / w600 / #09090B
        Text(
          title,
          style: TextStyle(
            fontFamily: 'SFProRounded',
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimaryDynamic(context),
          ),
        ),
        SizedBox(height: 12.h),
        GestureDetector(
          onTap: onTap,
          child: Container(
            height: 200.h,
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.iconContainerDynamic(context), // Figma #F4F4F5
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16.r),
              child: image == null
                  ? Center(
                      child: Icon(
                        Iconsax.gallery_add,
                        size: 56.sp,
                        color: const Color(0xFFA1A1AA), // Figma #A1A1AA
                      ),
                    )
                  : SizedBox.expand(child: _safeImage(image)),
            ),
          ),
        ),
        SizedBox(height: 24.h),
      ],
    );
  }

  Widget buildSelfieBox() {
    return GestureDetector(
      onTap: openSelfieCamera,
      child: Container(
        height: 200.h,
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.iconContainerDynamic(context), // Figma #F4F4F5
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16.r),
          child: selfieImage == null
              ? Center(
                  child: Icon(
                    Iconsax.gallery_add,
                    size: 56.sp,
                    color: const Color(0xFFA1A1AA), // Figma #A1A1AA
                  ),
                )
              : SizedBox.expand(child: _safeImage(selfieImage)),
        ),
      ),
    );
  }
}

class DropdownItem {
  final int id;
  final String name;
  DropdownItem({required this.id, required this.name});

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DropdownItem && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
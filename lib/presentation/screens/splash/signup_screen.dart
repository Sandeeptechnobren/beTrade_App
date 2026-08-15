import 'package:betrade/presentation/screens/main_screen.dart';
import 'package:betrade/presentation/screens/signin/attach_phone_screen.dart';
import 'package:betrade/presentation/screens/splash/signup_steps_pages/Gender_step.dart';
import 'package:betrade/presentation/screens/splash/signup_steps_pages/OTP_step.dart';
import 'package:betrade/presentation/screens/splash/signup_steps_pages/authlayout.dart';
import 'package:betrade/presentation/screens/splash/signup_steps_pages/stepPhone.dart';
import 'package:betrade/presentation/screens/splash/signup_steps_pages/step_name.dart';
import 'package:betrade/presentation/screens/splash/signup_steps_pages/step_profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../../../core/animations/success_animation.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/provider/signin_provider.dart';
import '../../../data/provider/signup_provider.dart';
import '../../auth/auth_screen.dart';
import '../../widget/customSnackBar.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  int step = 1;
  bool isLoading = false;
  bool _isProcessing = false;
  bool _isDisposed = false;
  bool isPhoneValid = false;
  bool isOtpValid = false;
  bool isGenderValid = false;
  bool isNameValid = false;
  bool isProfileValid = false;
  String _otpError = '';

  void next() {
    if (_isDisposed || !mounted) return;
    if (step < 5) {
      setState(() {
        step++;
        _isProcessing = false;
      });
    }
  }

  //
  // void back() {
  //   if (_isDisposed || !mounted) return;
  //   if (step > 1 && !isLoading && !_isProcessing) {
  //     setState(() {
  //       step--;
  //       _isProcessing = false;
  //     });
  //   }
  // }

  void back() {
    if (_isDisposed || !mounted) return;
    if (step == 1) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const AuthScreen(),
        ),
      );
      return;
    }
    if (step > 1 && !isLoading && !_isProcessing) {
      setState(() {
        step--;
        _isProcessing = false;
      });
    }
  }

  Widget getStep(SignupProvider provider) {
    if (_isDisposed) return const SizedBox();
    switch (step) {
      case 1:
        return StepPhone(
          onChanged: (val) {
            if (!_isDisposed && mounted) provider.setPhone(val);
          },
          onValidationChanged: (isValid) {
            if (!_isDisposed && mounted) {
              setState(() => isPhoneValid = isValid);
            }
          },
        );

      case 2:
        return StepOtp(
          errorText: _otpError,
          onChanged: (val) {
            if (!_isDisposed && mounted) {
              provider.setOtp(val);
              // Clear the verify error the moment the user edits the code.
              if (_otpError.isNotEmpty) setState(() => _otpError = '');
            }
          },
          onValidationChanged: (isValid) {
            if (!_isDisposed && mounted) {
              setState(() => isOtpValid = isValid);
            }
          },
        );

      case 3:
        return StepGender(
          onChanged: (val) {
            if (!_isDisposed && mounted) provider.setGender(val);
          },
          onValidationChanged: (isValid) {
            if (!_isDisposed && mounted) {
              setState(() => isGenderValid = isValid);
            }
          },
        );

      case 4:
        return StepName(
          onChanged: (f, l, e) {
            if (!_isDisposed && mounted) provider.setName(f, l, e);
          },
          onValidationChanged: (isValid) {
            if (!_isDisposed && mounted) {
              setState(() => isNameValid = isValid);
            }
          },
        );

      case 5:
        return StepProfile(
          onImageSelected: (file) {
            if (!_isDisposed && mounted) provider.setProfileImage(file);
          },
          onValidationChanged: (isValid) {
            if (!_isDisposed && mounted) {
              setState(() => isProfileValid = isValid);
            }
          },
        );

      default:
        return const Center(child: Text("Done"));
    }
  }

  bool get isCurrentStepValid {
    switch (step) {
      case 1:
        return isPhoneValid;
      case 2:
        return isOtpValid;
      case 3:
        return isGenderValid;
      case 4:
        return isNameValid;
      case 5:
        return isProfileValid;
      default:
        return false;
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

  void _navigateToSuccess() {
    if (_isDisposed || !mounted) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && !_isDisposed) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const SuccessScreen()),
        );
      }
    });
  }

  bool _isSuccess(dynamic result) {
    if (result == null) return false;
    if (result is bool) return result;
    if (result is Map) return result['success'] == true;
    return false;
  }

  Future<void> handleContinue(SignupProvider provider) async {
    // Prevent multiple taps and disposed state
    if (_isDisposed || !mounted) return;
    if (isLoading || _isProcessing) return;
    if (!isCurrentStepValid) return;

    setState(() => _isProcessing = true);

    try {
      switch (step) {
        case 1: // Phone step
          {
            // final sent = await provider.sendOtp();
            final result = await provider.sendOtp();
            if (_isDisposed || !mounted) return;

            if (result["success"]) {
              next();
            } else {
              _showError(result["message"]);
              if (mounted) setState(() => _isProcessing = false);
            }
          }
          break;

        case 2: // OTP step - Validate OTP here
          {
            final verified = await provider.verifyOtp(provider.otp);
            if (_isDisposed || !mounted) return;

            if (_isSuccess(verified) && mounted) {
              // ✅ OTP is correct - Move to Gender page
              next();
            } else {
              // ❌ OTP is invalid - Stay on OTP page.
              //
              // Previously we wiped `isOtpValid = false` AND cleared
              // `provider.otp` here. That produced the client-reported bug:
              // the 6 cells in StepOtp still showed the user's input
              // (their controllers weren't cleared) but the Continue
              // button became `onPressed: null` — taps felt unresponsive.
              //
              // Leave the user's input intact so they can correct a
              // single digit and retry without re-entering all 6 cells.
              // Show a clear, persistent inline error + guidance under the
              // cells (StepOtp renders `errorText`) instead of a transient
              // toast — QA #1 reported wrong-OTP gave "no feedback".
              setState(() {
                _otpError =
                    "That code is incorrect. Check it and try again, or tap Resend for a new one.";
                _isProcessing = false;
              });
            }
          }
          break;

        case 3: // Gender step
          if (mounted) next();
          break;

        case 4: // Name step
          if (mounted) next();
          break;

        case 5: // Profile step - Final submission
          if (mounted) {
            setState(() => isLoading = true);
          }

          // completeSignup returns a typed envelope:
          //   { success, message, data?, doc_upload_status? }
          // AuthService already persisted the Sanctum token + FCM token
          // + doc_upload_status by the time we reach this branch, so on
          // success we can route straight to SuccessScreen → MainScreen
          // (the user is already authenticated).
          final result = await provider.completeSignup();

          if (_isDisposed || !mounted) return;

          if (_isSuccess(result)) {
            _navigateToSuccess();
          } else {
            // Surface the backend's actual error message — "Email already
            // taken", "OTP expired", etc. — instead of the previous
            // generic "Signup failed" snackbar.
            final rawMessage = result['message'];
            final message = rawMessage is String && rawMessage.isNotEmpty
                ? rawMessage
                : "Signup failed. Please try again.";
            _showError(message);
            if (mounted) {
              setState(() {
                isLoading = false;
                _isProcessing = false;
              });
            }
          }
          break;
      }
    } catch (e, stackTrace) {
      if (_isDisposed || !mounted) return;

      debugPrint("❌ Signup error: $e");
      debugPrint("📚 Stack: $stackTrace");

      _showError("An error occurred. Please try again.");
      if (mounted) {
        setState(() {
          isLoading = false;
          _isProcessing = false;
        });
      }
    }
  }

  /// Continue-with-Apple entry point on the signup phone step.
  ///
  /// A successful Apple sign-in returns a JWT directly from the backend,
  /// so the remaining signup steps (OTP, gender, name, profile) are
  /// skipped — the user lands on MainScreen the same way a returning
  /// user does. Re-entry is gated via [_isProcessing] (shared with the
  /// Continue button) so a double-tap can't fire both flows.
  Future<void> _handleAppleSignIn() async {
    if (_isDisposed || !mounted || _isProcessing) return;

    setState(() => _isProcessing = true);
    try {
      final result =
          await context.read<AuthProvider>().signInWithApple();

      if (_isDisposed || !mounted) return;

      // User dismissed Apple's sheet — keep the UI silent.
      if (result['cancelled'] == true) return;

      if (result['success'] == true) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const MainScreen()),
          (route) => false,
        );
      } else {
        _showError((result['message'] as String?)?.isNotEmpty == true
            ? result['message']
            : "Apple sign-in failed. Please try again.");
      }
    } catch (e) {
      debugPrint("Apple sign-in handler error: $e");
      if (_isDisposed || !mounted) return;
      _showError("Something went wrong. Please try again.");
    } finally {
      if (!_isDisposed && mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  /// Continue-with-Google on the signup phone step — popup-only milestone.
  ///
  /// Opens the Google account chooser and confirms which account was picked.
  /// No navigation/backend yet (pending the senior's decision). Re-entry is
  /// gated via [_isProcessing], shared with the Continue/Apple flows.
  Future<void> _handleGoogleSignIn() async {
    if (_isDisposed || !mounted || _isProcessing) return;

    setState(() => _isProcessing = true);
    try {
      final result = await context.read<AuthProvider>().signInWithGoogle();

      if (_isDisposed || !mounted) return;

      // User dismissed the chooser — keep the UI silent.
      if (result['cancelled'] == true) return;

      if (result['success'] == true) {
        if (_isDisposed || !mounted) return;
        if (result['needs_phone'] == true) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AttachPhoneScreen(
                email: result['email'] as String?,
              ),
            ),
          );
        } else {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const MainScreen()),
            (route) => false,
          );
        }
      } else {
        _showError((result['message'] as String?)?.isNotEmpty == true
            ? result['message']
            : "Google sign-in failed. Please try again.");
      }
    } catch (e) {
      debugPrint("Google sign-in handler error: $e");
      if (_isDisposed || !mounted) return;
      _showError("Something went wrong. Please try again.");
    } finally {
      if (!_isDisposed && mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  // Mirrors the Login screen's Google + Apple buttons. Both are now wired:
  // Google -> [_handleGoogleSignIn] (popup-only for now), Apple ->
  // [_handleAppleSignIn] (usable on iOS).
  Widget _buildSocialAuthButtons(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: SizedBox(
            height: 50.h,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                side: BorderSide(
                  color: AppColors.borderDynamic(context),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25.r),
                ),
                backgroundColor: AppColors.buttonSecondaryDynamic(context),
              ),
              onPressed: _isProcessing ? null : _handleGoogleSignIn,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Continue with",
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: AppColors.textPrimaryDynamic(context),
                    ),
                  ),
                  SizedBox(width: 5.w),
                  SvgPicture.asset(
                    "assets/svgs/google.svg",
                    height: 19.h,
                    width: 19.w,
                  ),
                ],
              ),
            ),
          ),
        ),
        // Apple button always visible. On Android the package can't open
        // the native sheet; AuthProvider.signInWithApple catches the
        // unsupported case and surfaces a friendly message.
        SizedBox(width: 10.w),
        Expanded(
          child: SizedBox(
            height: 50.h,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                side: BorderSide(
                  color: AppColors.borderDynamic(context),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25.r),
                ),
                backgroundColor:
                    AppColors.buttonSecondaryDynamic(context),
              ),
              onPressed: _isProcessing ? null : _handleAppleSignIn,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Continue with",
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: AppColors.textPrimaryDynamic(context),
                    ),
                  ),
                  SizedBox(width: 2.w),
                  SvgPicture.asset(
                    "assets/svgs/apple.svg",
                    height: 20.h,
                    colorFilter: ColorFilter.mode(
                      isDarkMode ? Colors.white : Colors.black,
                      BlendMode.srcIn,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _isDisposed = true;
    _isProcessing = false;
    isLoading = false;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SignupProvider>(
      builder: (context, provider, _) {
        if (_isDisposed) return const SizedBox();
        return AuthLayout(
          step: step,
          onBack: back,
          onContinue: () => handleContinue(provider),
          isLoading: isLoading,
          isCurrentStepValid: isCurrentStepValid,
          // Social-auth buttons sit directly under Continue on the phone
          // step only — mirrors the LoginScreen layout. Other signup
          // steps (OTP, gender, name, profile) get no bottomExtra.
          bottomExtra: step == 1 ? _buildSocialAuthButtons(context) : null,
          child: getStep(provider),
        );
      },
    );
  }
}

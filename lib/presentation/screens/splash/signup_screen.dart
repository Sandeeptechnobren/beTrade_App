import 'package:betrade/presentation/screens/splash/signup_steps_pages/Gender_step.dart';
import 'package:betrade/presentation/screens/splash/signup_steps_pages/OTP_step.dart';
import 'package:betrade/presentation/screens/splash/signup_steps_pages/authlayout.dart';
import 'package:betrade/presentation/screens/splash/signup_steps_pages/stepPhone.dart';
import 'package:betrade/presentation/screens/splash/signup_steps_pages/step_name.dart';
import 'package:betrade/presentation/screens/splash/signup_steps_pages/step_profile.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/animations/success_animation.dart';
import '../../../core/theme/app_colors.dart';
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
          onChanged: (val) {
            if (!_isDisposed && mounted) provider.setOtp(val);
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
      case 1: return isPhoneValid;
      case 2: return isOtpValid;
      case 3: return isGenderValid;
      case 4: return isNameValid;
      case 5: return isProfileValid;
      default: return false;
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

  void _showSuccess(String message) {
    if (_isDisposed || !mounted) return;

    CustomSnackBar.showSuccess(
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
              // ❌ OTP is invalid - Stay on OTP page
              _showError("Invalid OTP. Please try again.");

              // Reset OTP valid state
              setState(() {
                isOtpValid = false;
                _isProcessing = false;
              });

              // Clear OTP from provider
              provider.setOtp("");
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
          child: getStep(provider),
        );
      },
    );
  }
}
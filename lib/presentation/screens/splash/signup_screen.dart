import 'package:betrade/presentation/screens/splash/signup_steps_pages/Gender_step.dart';
import 'package:betrade/presentation/screens/splash/signup_steps_pages/OTP_step.dart';
import 'package:betrade/presentation/screens/splash/signup_steps_pages/authlayout.dart';
import 'package:betrade/presentation/screens/splash/signup_steps_pages/stepPhone.dart';
import 'package:betrade/presentation/screens/splash/signup_steps_pages/step_name.dart';
import 'package:betrade/presentation/screens/splash/signup_steps_pages/step_profile.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/animations/success_animation.dart';
import '../../../data/provider/signUp_provider.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  int step = 1;

  void next() {
    if (step < 5) {
      setState(() => step++);
    }
  }

  void back() {
    if (step > 1) {
      setState(() => step--);
    }
  }
  Widget getStep(SignupProvider provider) {
    switch (step) {
      case 1:
        return StepPhone(onChanged: (val) {
          provider.setPhone(val);
        });

      case 2:
        return StepOtp(onChanged: (val) {
          provider.setOtp(val);
        });

      case 3:
        return StepGender(onChanged: (val) {
          provider.setGender(val);
        });

      case 4:
        return StepName(onChanged: (f, l) {
          provider.setName(f, l);
        });

      case 5:
        return StepProfile(
          onImageSelected: (file) {
            provider.setProfileImage(file);
          },
        );

      default:
        return const Center(child: Text("Done"));
    }
  }

  Future<void> handleContinue(SignupProvider provider) async {
    switch (step) {

      case 1:
        if (provider.phone.isEmpty) {
          showError("Enter phone number");
          return;
        }

        bool sent = await provider.sendOtp();

        if (sent) {
          next();
        } else {
          showError("OTP send failed");
        }
        break;

      case 2:
        if (provider.otp.length < 6) {
          showError("Enter full OTP");
          return;
        }

        bool verified = await provider.verifyOtp(provider.otp);

        if (verified) {
          next();
        } else {
          showError("Invalid OTP");
        }
        break;
      case 3:
        if (provider.gender.isEmpty) {
          showError("Select gender");
          return;
        }
        next();
        break;

      case 4:
        if (provider.firstName.isEmpty || provider.lastName.isEmpty) {
          showError("Enter full name");
          return;
        }
        next();
        break;

      case 5:
        if (provider.profileImage == null) {
          showError("Select profile image");
          return;
        }

        bool success = await provider.completeSignup();

        if (success) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => const SuccessScreen(),
            ),
          );
        } else {
          // showError("Signup failed");
        }
        break;
    }
  }

  void showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SignupProvider>(
      builder: (context, provider, _) {
        return AuthLayout(
          step: step,
          onBack: back,
          onContinue: () {
            handleContinue(provider);
          },
          child: getStep(provider),
        );
      },
    );
  }
}
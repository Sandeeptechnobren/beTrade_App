// import 'package:betrade/presentation/screens/splash/signup_steps_pages/Gender_step.dart';
// import 'package:betrade/presentation/screens/splash/signup_steps_pages/OTP_step.dart';
// import 'package:betrade/presentation/screens/splash/signup_steps_pages/authlayout.dart';
// import 'package:betrade/presentation/screens/splash/signup_steps_pages/stepPhone.dart';
// import 'package:betrade/presentation/screens/splash/signup_steps_pages/step_name.dart';
// import 'package:betrade/presentation/screens/splash/signup_steps_pages/step_profile.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../../../core/animations/success_animation.dart';
// import '../../../data/provider/signUp_provider.dart';
//
// class SignupScreen extends StatefulWidget {
//   const SignupScreen({super.key});
//
//   @override
//   State<SignupScreen> createState() => _SignupScreenState();
// }
//
// class _SignupScreenState extends State<SignupScreen> {
//   int step = 1;
//
//   void next() {
//     if (step < 5) {
//       setState(() => step++);
//     }
//   }
//
//   void back() {
//     if (step > 1) {
//       setState(() => step--);
//     }
//   }
//   Widget getStep(SignupProvider provider) {
//     switch (step) {
//       case 1:
//         return StepPhone(onChanged: (val) {
//           provider.setPhone(val);
//         });
//
//       case 2:
//         return StepOtp(onChanged: (val) {
//           provider.setOtp(val);
//         });
//
//       case 3:
//         return StepGender(onChanged: (val) {
//           provider.setGender(val);
//         });
//
//       case 4:
//         return StepName(onChanged: (f, l) {
//           provider.setName(f, l);
//         });
//
//       case 5:
//         return StepProfile(
//           onImageSelected: (file) {
//             provider.setProfileImage(file);
//           },
//         );
//
//       default:
//         return const Center(child: Text("Done"));
//     }
//   }
//
//   Future<void> handleContinue(SignupProvider provider) async {
//     switch (step) {
//
//       case 1:
//         if (provider.phone.isEmpty) {
//           showError("Enter phone number");
//           return;
//         }
//
//         bool sent = await provider.sendOtp();
//
//         if (sent) {
//           next();
//         } else {
//           showError("OTP send failed");
//         }
//         break;
//       case 2:
//         if (provider.otp.length < 6) {
//           showError("Enter full OTP");
//           return;
//         }
//         bool verified = await provider.verifyOtp(provider.otp);
//         if (verified) {
//           next();
//         } else {
//           showError("Invalid OTP");
//         }
//         break;
//       case 3:
//         if (provider.gender.isEmpty) {
//           showError("Select gender");
//           return;
//         }
//         next();
//         break;
//
//       case 4:
//         if (provider.firstName.isEmpty || provider.lastName.isEmpty) {
//           showError("Enter full name");
//           return;
//         }
//         next();
//         break;
//
//       case 5:
//         if (provider.profileImage == null) {
//           showError("Select profile image");
//           return;
//         }
//
//         bool success = await provider.completeSignup();
//
//         if (success) {
//           Navigator.pushReplacement(
//             context,
//             MaterialPageRoute(
//               builder: (_) => const SuccessScreen(),
//             ),
//           );
//         } else {
//           // showError("Signup failed");
//         }
//         break;
//     }
//   }
//
//   void showError(String msg) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text(msg)),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Consumer<SignupProvider>(
//       builder: (context, provider, _) {
//         return AuthLayout(
//           step: step,
//           onBack: back,
//           onContinue: () {
//             handleContinue(provider);
//           },
//           child: getStep(provider),
//         );
//       },
//     );
//   }
// }
//
// import 'package:betrade/presentation/screens/splash/signup_steps_pages/Gender_step.dart';
// import 'package:betrade/presentation/screens/splash/signup_steps_pages/OTP_step.dart';
// import 'package:betrade/presentation/screens/splash/signup_steps_pages/authlayout.dart';
// import 'package:betrade/presentation/screens/splash/signup_steps_pages/stepPhone.dart';
// import 'package:betrade/presentation/screens/splash/signup_steps_pages/step_name.dart';
// import 'package:betrade/presentation/screens/splash/signup_steps_pages/step_profile.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../../../core/animations/success_animation.dart';
// import '../../../data/provider/signUp_provider.dart';
//
// class SignupScreen extends StatefulWidget {
//   const SignupScreen({super.key});
//
//   @override
//   State<SignupScreen> createState() => _SignupScreenState();
// }
//
// class _SignupScreenState extends State<SignupScreen> {
//   int step = 1;
//   bool isLoading = false;
//
//   void next() {
//     if (step < 5) {
//       setState(() => step++);
//     }
//   }
//
//   void back() {
//     if (step > 1 && !isLoading) {
//       setState(() => step--);
//     }
//   }
//
//   Widget getStep(SignupProvider provider) {
//     switch (step) {
//       case 1:
//         return StepPhone(onChanged: (val) {
//           provider.setPhone(val);
//         });
//
//       case 2:
//         return StepOtp(onChanged: (val) {
//           provider.setOtp(val);
//         });
//
//       case 3:
//         return StepGender(onChanged: (val) {
//           provider.setGender(val);
//         });
//
//       case 4:
//         return StepName(onChanged: (f, l) {
//           provider.setName(f, l);
//         });
//
//       case 5:
//         return StepProfile(
//           onImageSelected: (file) {
//             provider.setProfileImage(file);
//           },
//         );
//
//       default:
//         return const Center(child: Text("Done"));
//     }
//   }
//
//   Future<void> handleContinue(SignupProvider provider) async {
//     if (isLoading) return;
//     switch (step) {
//       case 1:
//         if (provider.phone.isEmpty) {
//           showError("Enter phone number");
//           return;
//         }
//         bool sent = await provider.sendOtp();
//         if (sent) {
//           next();
//         } else {
//           showError("OTP send failed");
//         }
//         break;
//       case 2:
//         if (provider.otp.length < 6) {
//           showError("Enter full OTP");
//           return;
//         }
//         bool verified = await provider.verifyOtp(provider.otp);
//         if (verified) {
//           next();
//         } else {
//           showError("Invalid OTP");
//         }
//         break;
//       case 3:
//         if (provider.gender.isEmpty) {
//           showError("Select gender");
//           return;
//         }
//         next();
//         break;
//       case 4:
//         if (provider.firstName.isEmpty || provider.lastName.isEmpty) {
//           showError("Enter full name");
//           return;
//         }
//         next();
//         break;
//       case 5:
//         if (provider.profileImage == null) {
//           showError("Select profile image");
//           return;
//         }
//         setState(() {
//           isLoading = true;
//         });
//
//         try {
//           bool success = await provider.completeSignup();
//           if (success && mounted) {
//             Navigator.pushReplacement(
//               context,
//               MaterialPageRoute(
//                 builder: (_) => const SuccessScreen(),
//               ),
//             );
//           } else {
//             if (mounted) {
//               setState(() {
//                 isLoading = false;
//               });
//               showError("Signup failed");
//             }
//           }
//         } catch (e) {
//           if (mounted) {
//             setState(() {
//               isLoading = false;
//             });
//             showError("An error occurred: ${e.toString()}");
//           }
//         }
//         break;
//     }
//   }
//
//   void showError(String msg) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text(msg)),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Consumer<SignupProvider>(
//       builder: (context, provider, _) {
//         return AuthLayout(
//           step: step,
//           onBack: back,
//           onContinue: () {
//             handleContinue(provider);
//           },
//           isLoading: isLoading,
//           child: getStep(provider),
//         );
//       },
//     );
//   }
// }

//
// import 'package:betrade/presentation/screens/splash/signup_steps_pages/Gender_step.dart';
// import 'package:betrade/presentation/screens/splash/signup_steps_pages/OTP_step.dart';
// import 'package:betrade/presentation/screens/splash/signup_steps_pages/authlayout.dart';
// import 'package:betrade/presentation/screens/splash/signup_steps_pages/stepPhone.dart';
// import 'package:betrade/presentation/screens/splash/signup_steps_pages/step_name.dart';
// import 'package:betrade/presentation/screens/splash/signup_steps_pages/step_profile.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../../../core/animations/success_animation.dart';
// import '../../../data/provider/signUp_provider.dart';
//
// class SignupScreen extends StatefulWidget {
//   const SignupScreen({super.key});
//
//   @override
//   State<SignupScreen> createState() => _SignupScreenState();
// }
//
// class _SignupScreenState extends State<SignupScreen> {
//   int step = 1;
//   bool isLoading = false;
//
//   // Step validation states
//   bool isPhoneValid = false;
//   bool isOtpValid = false;
//   bool isGenderValid = false;
//   bool isNameValid = false;
//   bool isProfileValid = false;
//
//   void next() {
//     if (step < 5) {
//       setState(() => step++);
//     }
//   }
//
//   void back() {
//     if (step > 1 && !isLoading) {
//       setState(() => step--);
//     }
//   }
//
//   Widget getStep(SignupProvider provider) {
//     switch (step) {
//       case 1:
//         return StepPhone(
//           onChanged: (val) {
//             provider.setPhone(val);
//           },
//           onValidationChanged: (isValid) {
//             setState(() {
//               isPhoneValid = isValid;
//             });
//           },
//         );
//
//       case 2:
//         return StepOtp(
//           onChanged: (val) {
//             provider.setOtp(val);
//           },
//           onValidationChanged: (isValid) {
//             setState(() {
//               isOtpValid = isValid;
//             });
//           },
//         );
//
//       case 3:
//         return StepGender(
//           onChanged: (val) {
//             provider.setGender(val);
//           },
//           onValidationChanged: (isValid) {
//             setState(() {
//               isGenderValid = isValid;
//             });
//           },
//         );
//
//       case 4:
//         return StepName(
//           onChanged: (f, l) {
//             provider.setName(f, l);
//           },
//           onValidationChanged: (isValid) {
//             setState(() {
//               isNameValid = isValid;
//             });
//           },
//         );
//
//       case 5:
//         return StepProfile(
//           onImageSelected: (file) {
//             provider.setProfileImage(file);
//           },
//           onValidationChanged: (isValid) {
//             setState(() {
//               isProfileValid = isValid;
//             });
//           },
//         );
//
//       default:
//         return const Center(child: Text("Done"));
//     }
//   }
//
//   bool get isCurrentStepValid {
//     switch (step) {
//       case 1:
//         return isPhoneValid;
//       case 2:
//         return isOtpValid;
//       case 3:
//         return isGenderValid;
//       case 4:
//         return isNameValid;
//       case 5:
//         return isProfileValid;
//       default:
//         return false;
//     }
//   }
//
//   Future<void> handleContinue(SignupProvider provider) async {
//     if (isLoading) return;
//     if (!isCurrentStepValid) return;
//
//     switch (step) {
//       case 1:
//         bool sent = await provider.sendOtp();
//         if (sent) {
//           next();
//         } else {
//           showError("OTP send failed");
//         }
//         break;
//       case 2:
//         bool verified = await provider.verifyOtp(provider.otp);
//         if (verified) {
//           next();
//         } else {
//           showError("Invalid OTP");
//         }
//         break;
//       case 3:
//         next();
//         break;
//       case 4:
//         next();
//         break;
//       case 5:
//         setState(() => isLoading = true);
//         try {
//           bool success = await provider.completeSignup();
//           if (success && mounted) {
//             Navigator.pushReplacement(
//               context,
//               MaterialPageRoute(builder: (_) => const SuccessScreen()),
//             );
//           } else {
//             if (mounted) {
//               setState(() => isLoading = false);
//               showError("Signup failed");
//             }
//           }
//         } catch (e) {
//           if (mounted) {
//             setState(() => isLoading = false);
//             showError("An error occurred: ${e.toString()}");
//           }
//         }
//         break;
//     }
//   }
//
//   void showError(String msg) {
//     ScaffoldMessenger.of(context)
//         .showSnackBar(SnackBar(content: Text(msg)));
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Consumer<SignupProvider>(
//       builder: (context, provider, _) {
//         return AuthLayout(
//           step: step,
//           onBack: back,
//           onContinue: () => handleContinue(provider),
//           isLoading: isLoading,
//           isCurrentStepValid: isCurrentStepValid,
//           child: getStep(provider),
//         );
//       },
//     );
//   }
// }
//
// import 'package:betrade/presentation/screens/splash/signup_steps_pages/Gender_step.dart';
// import 'package:betrade/presentation/screens/splash/signup_steps_pages/OTP_step.dart';
// import 'package:betrade/presentation/screens/splash/signup_steps_pages/authlayout.dart';
// import 'package:betrade/presentation/screens/splash/signup_steps_pages/stepPhone.dart';
// import 'package:betrade/presentation/screens/splash/signup_steps_pages/step_name.dart';
// import 'package:betrade/presentation/screens/splash/signup_steps_pages/step_profile.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../../../core/animations/success_animation.dart';
// import '../../../data/provider/signUp_provider.dart';
//
// class SignupScreen extends StatefulWidget {
//   const SignupScreen({super.key});
//
//   @override
//   State<SignupScreen> createState() => _SignupScreenState();
// }
//
// class _SignupScreenState extends State<SignupScreen> {
//   int step = 1;
//   bool isLoading = false;
//   bool _isProcessing = false; // ✅ Multiple click protection
//
//   // Step validation states
//   bool isPhoneValid = false;
//   bool isOtpValid = false;
//   bool isGenderValid = false;
//   bool isNameValid = false;
//   bool isProfileValid = false;
//
//   void next() {
//     if (step < 5 && mounted) {
//       setState(() {
//         step++;
//         _isProcessing = false; // ✅ Reset processing flag after step change
//       });
//     }
//   }
//
//   void back() {
//     if (step > 1 && !isLoading && !_isProcessing && mounted) {
//       setState(() {
//         step--;
//         _isProcessing = false; // ✅ Reset on back as well
//       });
//     }
//   }
//
//   Widget getStep(SignupProvider provider) {
//     switch (step) {
//       case 1:
//         return StepPhone(
//           onChanged: (val) {
//             provider.setPhone(val);
//           },
//           onValidationChanged: (isValid) {
//             if (mounted) {
//               setState(() {
//                 isPhoneValid = isValid;
//               });
//             }
//           },
//         );
//
//       case 2:
//         return StepOtp(
//           onChanged: (val) {
//             provider.setOtp(val);
//           },
//           onValidationChanged: (isValid) {
//             if (mounted) {
//               setState(() {
//                 isOtpValid = isValid;
//               });
//             }
//           },
//         );
//
//       case 3:
//         return StepGender(
//           onChanged: (val) {
//             provider.setGender(val);
//           },
//           onValidationChanged: (isValid) {
//             if (mounted) {
//               setState(() {
//                 isGenderValid = isValid;
//               });
//             }
//           },
//         );
//
//       case 4:
//         return StepName(
//           onChanged: (f, l) {
//             provider.setName(f, l);
//           },
//           onValidationChanged: (isValid) {
//             if (mounted) {
//               setState(() {
//                 isNameValid = isValid;
//               });
//             }
//           },
//         );
//
//       case 5:
//         return StepProfile(
//           onImageSelected: (file) {
//             provider.setProfileImage(file);
//           },
//           onValidationChanged: (isValid) {
//             if (mounted) {
//               setState(() {
//                 isProfileValid = isValid;
//               });
//             }
//           },
//         );
//
//       default:
//         return const Center(child: Text("Done"));
//     }
//   }
//
//   bool get isCurrentStepValid {
//     switch (step) {
//       case 1:
//         return isPhoneValid;
//       case 2:
//         return isOtpValid;
//       case 3:
//         return isGenderValid;
//       case 4:
//         return isNameValid;
//       case 5:
//         return isProfileValid;
//       default:
//         return false;
//     }
//   }
//
//   Future<void> handleContinue(SignupProvider provider) async {
//     // ✅ Multiple click protection
//     if (isLoading || _isProcessing || !mounted) return;
//     if (!isCurrentStepValid) return;
//
//     setState(() => _isProcessing = true);
//
//     switch (step) {
//       case 1:
//         try {
//           bool sent = await provider.sendOtp();
//           if (sent && mounted) {
//             next();
//           } else if (mounted) {
//             setState(() => _isProcessing = false);
//             showError("OTP send failed");
//           }
//         } catch (e) {
//           if (mounted) {
//             setState(() => _isProcessing = false);
//             showError("Error: ${e.toString()}");
//           }
//         }
//         break;
//
//       case 2:
//         try {
//           bool verified = await provider.verifyOtp(provider.otp);
//           if (verified && mounted) {
//             next();
//           } else if (mounted) {
//             setState(() => _isProcessing = false);
//             showError("Invalid OTP");
//           }
//         } catch (e) {
//           if (mounted) {
//             setState(() => _isProcessing = false);
//             showError("Error: ${e.toString()}");
//           }
//         }
//         break;
//
//       case 3:
//       // Gender step - directly next
//         if (mounted) {
//           next();
//         } else {
//           if (mounted) setState(() => _isProcessing = false);
//         }
//         break;
//
//       case 4:
//       // Name step - directly next
//         if (mounted) {
//           next();
//         } else {
//           if (mounted) setState(() => _isProcessing = false);
//         }
//         break;
//
//       case 5:
//         setState(() => isLoading = true);
//         try {
//           bool success = await provider.completeSignup();
//           if (success && mounted) {
//             Navigator.pushReplacement(
//               context,
//               MaterialPageRoute(builder: (_) => const SuccessScreen()),
//             );
//           } else if (mounted) {
//             setState(() {
//               isLoading = false;
//               _isProcessing = false;
//             });
//             showError("Signup failed");
//           }
//         } catch (e) {
//           if (mounted) {
//             setState(() {
//               isLoading = false;
//               _isProcessing = false;
//             });
//             showError("An error occurred: ${e.toString()}");
//           }
//         }
//         break;
//     }
//   }
//
//   void showError(String msg) {
//     if (!mounted) return;
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text(msg)),
//     );
//   }
//
//   @override
//   void dispose() {
//     _isProcessing = false;
//     isLoading = false;
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Consumer<SignupProvider>(
//       builder: (context, provider, _) {
//         return AuthLayout(
//           step: step,
//           onBack: back,
//           onContinue: () => handleContinue(provider),
//           isLoading: isLoading,
//           isCurrentStepValid: isCurrentStepValid,
//           child: getStep(provider),
//         );
//       },
//     );
//   }
// }

//
// import 'package:betrade/presentation/screens/splash/signup_steps_pages/Gender_step.dart';
// import 'package:betrade/presentation/screens/splash/signup_steps_pages/OTP_step.dart';
// import 'package:betrade/presentation/screens/splash/signup_steps_pages/authlayout.dart';
// import 'package:betrade/presentation/screens/splash/signup_steps_pages/stepPhone.dart';
// import 'package:betrade/presentation/screens/splash/signup_steps_pages/step_name.dart';
// import 'package:betrade/presentation/screens/splash/signup_steps_pages/step_profile.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../../../core/animations/success_animation.dart';
// import '../../../data/provider/signUp_provider.dart';
//
// class SignupScreen extends StatefulWidget {
//   const SignupScreen({super.key});
//
//   @override
//   State<SignupScreen> createState() => _SignupScreenState();
// }
//
// class _SignupScreenState extends State<SignupScreen> {
//   int step = 1;
//   bool isLoading = false;
//   bool _isProcessing = false;
//   bool _isDisposed = false;
//
//   // Step validation states
//   bool isPhoneValid = false;
//   bool isOtpValid = false;
//   bool isGenderValid = false;
//   bool isNameValid = false;
//   bool isProfileValid = false;
//
//   void next() {
//     if (_isDisposed || !mounted) return;
//     if (step < 5) {
//       setState(() {
//         step++;
//         _isProcessing = false;
//       });
//     }
//   }
//
//   void back() {
//     if (_isDisposed || !mounted) return;
//     if (step > 1 && !isLoading && !_isProcessing) {
//       setState(() {
//         step--;
//         _isProcessing = false;
//       });
//     }
//   }
//
//   Widget getStep(SignupProvider provider) {
//     if (_isDisposed) return const SizedBox();
//
//     switch (step) {
//       case 1:
//         return StepPhone(
//           onChanged: (val) {
//             if (!_isDisposed && mounted) provider.setPhone(val);
//           },
//           onValidationChanged: (isValid) {
//             if (!_isDisposed && mounted) {
//               setState(() => isPhoneValid = isValid);
//             }
//           },
//         );
//
//       case 2:
//         return StepOtp(
//           onChanged: (val) {
//             if (!_isDisposed && mounted) provider.setOtp(val);
//           },
//           onValidationChanged: (isValid) {
//             if (!_isDisposed && mounted) {
//               setState(() => isOtpValid = isValid);
//             }
//           },
//         );
//
//       case 3:
//         return StepGender(
//           onChanged: (val) {
//             if (!_isDisposed && mounted) provider.setGender(val);
//           },
//           onValidationChanged: (isValid) {
//             if (!_isDisposed && mounted) {
//               setState(() => isGenderValid = isValid);
//             }
//           },
//         );
//
//       case 4:
//         return StepName(
//           onChanged: (f, l) {
//             if (!_isDisposed && mounted) provider.setName(f, l);
//           },
//           onValidationChanged: (isValid) {
//             if (!_isDisposed && mounted) {
//               setState(() => isNameValid = isValid);
//             }
//           },
//         );
//
//       case 5:
//         return StepProfile(
//           onImageSelected: (file) {
//             if (!_isDisposed && mounted) provider.setProfileImage(file);
//           },
//           onValidationChanged: (isValid) {
//             if (!_isDisposed && mounted) {
//               setState(() => isProfileValid = isValid);
//             }
//           },
//         );
//
//       default:
//         return const Center(child: Text("Done"));
//     }
//   }
//
//   bool get isCurrentStepValid {
//     switch (step) {
//       case 1: return isPhoneValid;
//       case 2: return isOtpValid;
//       case 3: return isGenderValid;
//       case 4: return isNameValid;
//       case 5: return isProfileValid;
//       default: return false;
//     }
//   }
//
//   // ✅ FIX #1: Safe snackbar with mounted check
//   void _showError(String message) {
//     if (_isDisposed || !mounted) return;
//
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(message),
//         backgroundColor: Colors.red.shade700,
//       ),
//     );
//   }
//
//   void _showSuccess(String message) {
//     if (_isDisposed || !mounted) return;
//
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(message),
//         backgroundColor: Colors.green.shade700,
//       ),
//     );
//   }
//
//   // ✅ FIX #2: Safe navigation with post frame callback
//   void _navigateToSuccess() {
//     if (_isDisposed || !mounted) return;
//
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       if (mounted && !_isDisposed) {
//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(builder: (_) => const SuccessScreen()),
//         );
//       }
//     });
//   }
//
//   // ✅ FIX #3: Safe async result parsing
//   bool _isSuccess(dynamic result) {
//     if (result == null) return false;
//     if (result is bool) return result;
//     if (result is Map) return result['success'] == true;
//     return false;
//   }
//
//   // ✅ FIX #4: Handle continue with proper error handling
//   Future<void> handleContinue(SignupProvider provider) async {
//     // Prevent multiple taps and disposed state
//     if (_isDisposed || !mounted) return;
//     if (isLoading || _isProcessing) return;
//     if (!isCurrentStepValid) return;
//
//     setState(() => _isProcessing = true);
//
//     try {
//       switch (step) {
//         case 1: // Phone step
//           {
//             final sent = await provider.sendOtp();
//             if (_isDisposed || !mounted) return;
//
//             if (_isSuccess(sent) && mounted) {
//               next();
//             } else {
//               _showError("OTP send failed");
//               if (mounted) setState(() => _isProcessing = false);
//             }
//           }
//           break;
//
//         case 2: // OTP step
//           {
//             final verified = await provider.verifyOtp(provider.otp);
//             if (_isDisposed || !mounted) return;
//
//             if (_isSuccess(verified) && mounted) {
//               next();
//             } else {
//               _showError("Invalid OTP");
//               if (mounted) setState(() => _isProcessing = false);
//             }
//           }
//           break;
//
//         case 3: // Gender step
//           if (mounted) next();
//           break;
//
//         case 4: // Name step
//           if (mounted) next();
//           break;
//
//         case 5: // Profile step - Final submission
//           if (mounted) {
//             setState(() => isLoading = true);
//           }
//
//           final success = await provider.completeSignup();
//
//           if (_isDisposed || !mounted) return;
//
//           if (_isSuccess(success)) {
//             _navigateToSuccess();
//           } else {
//             _showError("Signup failed. Please try again.");
//             if (mounted) {
//               setState(() {
//                 isLoading = false;
//                 _isProcessing = false;
//               });
//             }
//           }
//           break;
//       }
//     } catch (e, stackTrace) {
//       if (_isDisposed || !mounted) return;
//
//       debugPrint("❌ Signup error: $e");
//       debugPrint("📚 Stack: $stackTrace");
//
//       _showError("An error occurred. Please try again.");
//       if (mounted) {
//         setState(() {
//           isLoading = false;
//           _isProcessing = false;
//         });
//       }
//     }
//   }
//
//   @override
//   void dispose() {
//     _isDisposed = true;
//     _isProcessing = false;
//     isLoading = false;
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Consumer<SignupProvider>(
//       builder: (context, provider, _) {
//         if (_isDisposed) return const SizedBox();
//
//         return AuthLayout(
//           step: step,
//           onBack: back,
//           onContinue: () => handleContinue(provider),
//           isLoading: isLoading,
//           isCurrentStepValid: isCurrentStepValid,
//           child: getStep(provider),
//         );
//       },
//     );
//   }
// }

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
  bool isLoading = false;
  bool _isProcessing = false;
  bool _isDisposed = false;

  // Step validation states
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

  void back() {
    if (_isDisposed || !mounted) return;
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
          onChanged: (f, l) {
            if (!_isDisposed && mounted) provider.setName(f, l);
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

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade700,
      ),
    );
  }

  void _showSuccess(String message) {
    if (_isDisposed || !mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green.shade700,
      ),
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
            final sent = await provider.sendOtp();
            if (_isDisposed || !mounted) return;

            if (_isSuccess(sent) && mounted) {
              next();
            } else {
              _showError("OTP send failed");
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

          final success = await provider.completeSignup();

          if (_isDisposed || !mounted) return;

          if (_isSuccess(success)) {
            _navigateToSuccess();
          } else {
            _showError("Signup failed. Please try again.");
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
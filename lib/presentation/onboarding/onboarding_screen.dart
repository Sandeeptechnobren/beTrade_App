import 'package:betrade/core/theme/app_colors.dart';
import 'package:betrade/core/theme/app_text_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../data/services/local_storage.dart';
import '../auth/auth_bottom_sheet.dart';
import '../auth/auth_screen.dart';
import 'onboarding_page.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int currentIndex = 0;

  final List<Map<String, String>> data = [
    {
      "title": "Trade Real \nMoments",
      "desc":
      "Back your beliefs in politics, sports and more. If outcomes are in your favor, you’ll earn 💰.",
      "image": "assets/images/person3.png",
      "button": "Next",
      "emoji":"assets/images/Emoji3.png",
    },
    {
      "title": "Yes or No.\nThat’s it.",
      "desc":
      "Think 🤔 it’ll happen? Buy Yes. Think it won’t? Buy No. Prices move based on what everyone believes.",
      "image": "assets/images/person2.png",
      "button": "Next",
    "emoji":"assets/images/IconLogo.png",
    },
    {
      "title": "Win Real\nRewards",
      "desc":
      "If your prediction wins, you earn 1 per share. Start small — even 1 is enough 🤑.",
      "image": "assets/images/person1.png",
      "button": "Get Started",
    "emoji":"assets/images/IconLogo.png",
    },
  ];
  void nextPage() async {
    if (currentIndex == data.length - 1) {
      await LocalStorage.setOnboardingDone();
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (_) => const AuthScreen(),
      );
    } else {
      _controller.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.ease,
      );
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset("assets/images/backgroundthread.png", fit: BoxFit.cover,),
          ),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(15),
                  child: Row(
                    children: List.generate(data.length, (index) => Expanded(
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal:2),
                          height: 4,
                          decoration: BoxDecoration(color: currentIndex == index ?AppColors.primary : Colors.grey,
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: PageView.builder(
                    controller: _controller,
                    onPageChanged: (index) {setState(() => currentIndex = index);},
                    itemCount: data.length,
                    itemBuilder: (_, index) {
                      return OnboardingPage(
                        title: data[index]["title"]!,
                        desc: data[index]["desc"]!,
                        image: data[index]["image"]!,
                        emoji: data[index]["emoji"]!,
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        color: const Color(0xFF1A1E3F),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
          child: ElevatedButton(
            onPressed: nextPage,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 55),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: Text(
              data[currentIndex]["button"]!,
              style:AppTextStyle.button,
            ),
          ),
        ),
      ),
    );
  }
}

// import 'package:betrade/core/theme/app_colors.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import '../../data/services/local_storage.dart';
// import '../auth/auth_bottom_sheet.dart';
// import '../auth/auth_screen.dart';
// import 'onboarding_page.dart';
//
// class OnboardingScreen extends StatefulWidget {
//   const OnboardingScreen({super.key});
//
//   @override
//   State<OnboardingScreen> createState() => _OnboardingScreenState();
// }
//
// class _OnboardingScreenState extends State<OnboardingScreen> {
//   late final PageController _controller;
//   int currentIndex = 0;
//   bool _isNavigating = false;
//
//   final List<Map<String, String>> data = [
//     {
//       "title": "Trade Real \nMoments",
//       "desc": "Back your beliefs in politics, sports and more. If outcomes are in your favor, you’ll earn 💰.",
//       "image": "assets/images/person3.png",
//       "button": "Next",
//       "emoji": "assets/images/Emoji3.png",
//     },
//     {
//       "title": "Yes or No.\nThat’s it.",
//       "desc": "Think 🤔 it’ll happen? Buy Yes. Think it won’t? Buy No. Prices move based on what everyone believes.",
//       "image": "assets/images/person2.png",
//       "button": "Next",
//       "emoji": "assets/images/IconLogo.png",
//     },
//     {
//       "title": "Win Real\nRewards",
//       "desc": "If your prediction wins, you earn 1 per share. Start small — even 1 is enough 🤑.",
//       "image": "assets/images/person1.png",
//       "button": "Get Started",
//       "emoji": "assets/images/IconLogo.png",
//     },
//   ];
//
//   @override
//   void initState() {
//     super.initState();
//     _controller = PageController();
//   }
//
//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }
//
//   // ✅ FIX #1: Safe data getter - NO EMPTY STRINGS
//   String _getData(int index, String key, {required String defaultValue}) {
//     try {
//       return data[index][key] ?? defaultValue;
//     } catch (e) {
//       debugPrint("❌ Data missing for index $index, key $key");
//       return defaultValue;
//     }
//   }
//
//   void nextPage() async {
//     if (_isNavigating) return;
//     _isNavigating = true;
//
//     try {
//       if (currentIndex == data.length - 1) {
//         await LocalStorage.setOnboardingDone();
//
//         if (!mounted) return;
//
//         // ✅ FIX #2: Use addPostFrameCallback for safe bottom sheet
//         WidgetsBinding.instance.addPostFrameCallback((_) {
//           if (mounted) {
//             showModalBottomSheet(
//               context: context,
//               isScrollControlled: true,
//               builder: (_) => const AuthScreen(),
//             );
//           }
//         });
//       } else {
//         if (_controller.hasClients) {
//           await _controller.nextPage(
//             duration: const Duration(milliseconds: 300),
//             curve: Curves.ease,
//           );
//         }
//       }
//     } catch (e) {
//       debugPrint("❌ Navigation error: $e");
//     } finally {
//       if (mounted) {
//         _isNavigating = false;
//       }
//     }
//   }
//
//   Widget _safeImage(String path) {
//     // ✅ FIX #3: Don't render if path is empty
//     if (path.isEmpty) {
//       return Container(color: AppColors.primary);
//     }
//
//     return Image.asset(
//       path,
//       fit: BoxFit.cover,
//       errorBuilder: (context, error, stackTrace) {
//         debugPrint("❌ Missing asset: $path");
//         return Container(color: AppColors.primary);
//       },
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Stack(
//         children: [
//           Positioned.fill(
//             child: _safeImage("assets/images/backgroundthread.png"),
//           ),
//           SafeArea(
//             child: Column(
//               children: [
//                 Padding(
//                   padding: const EdgeInsets.all(16),
//                   child: Row(
//                     children: List.generate(data.length, (index) => Expanded(
//                       child: Container(
//                         margin: const EdgeInsets.symmetric(horizontal: 4),
//                         height: 4,
//                         decoration: BoxDecoration(
//                           color: currentIndex == index ? AppColors.primary : Colors.grey,
//                           borderRadius: BorderRadius.circular(10),
//                         ),
//                       ),
//                     )),
//                   ),
//                 ),
//                 Expanded(
//                   child: PageView.builder(
//                     controller: _controller,
//                     onPageChanged: (index) {
//                       if (mounted) {
//                         setState(() => currentIndex = index);
//                       }
//                     },
//                     itemCount: data.length,
//                     itemBuilder: (_, index) {
//                       return OnboardingPage(
//                         title: _getData(index, "title", defaultValue: "Trade"),
//                         desc: _getData(index, "desc", defaultValue: ""),
//                         image: _getData(index, "image", defaultValue: "assets/images/person1.png"),
//                         emoji: _getData(index, "emoji", defaultValue: "assets/images/IconLogo.png"),
//                       );
//                     },
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//       bottomNavigationBar: Container(
//         color: const Color(0xFF1A1E3F),
//         child: Padding(
//           padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
//           child: ElevatedButton(
//             onPressed: _isNavigating ? null : nextPage,
//             style: ElevatedButton.styleFrom(
//               backgroundColor: Colors.white,
//               minimumSize: const Size(double.infinity, 55),
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(30),
//               ),
//             ),
//             child: Text(
//               _getData(currentIndex, "button", defaultValue: "Next"),
//               style: const TextStyle(color: Colors.black),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
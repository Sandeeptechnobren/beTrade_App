import 'package:betrade/core/theme/app_text_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../data/services/local_storage.dart';
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
      "emoji": "assets/images/Emoji3.png",
    },
    {
      "title": "Yes or No.\nThat’s it.",
      "desc":
          "Think 🤔 it’ll happen? Buy Yes. Think it won’t? Buy No. Prices move based on what everyone believes.",
      "image": "assets/images/person2.png",
      "button": "Next",
      "emoji": "assets/images/IconLogo.png",
    },
    {
      "title": "Win Real\nRewards",
      "desc":
          "If your prediction wins, you earn 1 per share. Start small — even 1 is enough 🤑.",
      "image": "assets/images/person1.png",
      "button": "Get Started",
      "emoji": "assets/images/IconLogo.png",
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
            child: Image.asset(
              "assets/images/backgroundthread.png",
              fit: BoxFit.cover,
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal:16.w, vertical: 12.h),
                  child: Row(
                    children: List.generate(
                      data.length,
                      (index) => Expanded(
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 2),
                          height: 6,
                          decoration: BoxDecoration(
                            // Figma: active = #C178FF, inactive = white.
                            color: currentIndex == index
                                ? const Color(0xFFC178FF)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(120),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: PageView.builder(
                    controller: _controller,
                    onPageChanged: (index) {
                      setState(() => currentIndex = index);
                    },
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
              minimumSize: const Size(double.infinity, 60),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(32),
              ),
            ),
            child: Text(
              data[currentIndex]["button"]!,
              // Figma: SF Pro Rounded, weight 700, #09090B.
              style: AppTextStyle.button.copyWith(
                fontWeight: FontWeight.w700,
                color: const Color(0xFF09090B),
              ),
            ),
          ),
        ),
      ),
    );
  }
}


import 'package:betrade/core/theme/app_text_style.dart';
import 'package:betrade/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class PollModel {
  final String category;
  final String time;
  final String question;
  final String? image;
  final int yesPercent;
  final int noPercent;
  final int trades;

  PollModel({
    required this.category,
    required this.time,
    required this.question,
    this.image,
    required this.yesPercent,
    required this.noPercent,
    required this.trades,
  });
}

final List<PollModel> polls = [
  PollModel(
    category: "Crypto",
    time: "7m",
    question: "Will bitcoin exceed \$200k before the end of 2026?",
    yesPercent: 33,
    noPercent: 67,
    trades: 3975,
  ),
  PollModel(
    category: "Entertainment",
    time: "2d",
    question: "Will Black Sherif win artiste of the year 2026?",
    image: "assets/images/person4.png",
    yesPercent: 33,
    noPercent: 67,
    trades: 3975,
  ),
  PollModel(
    category: "Politics",
    time: "7m",
    question:
        "Will Iran retaliate with large-scale attacks on U.S. bases in the Middle East?",
    // image: "assets/images/person4.png",
    yesPercent: 0,
    noPercent: 0,
    trades: 3975,
  ),
  PollModel(
    category: "Sports",
    time: "7m",
    question: "Will Arsenal top the premiere league table this season?",
    image: "assets/images/post4.jpg",
    yesPercent: 0,
    noPercent: 0,
    trades: 3975,
  ),
];

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int selectedIndex = 0;
  final PageController _pageController = PageController();
  final List<String> tabs = [
    "All",
    "Trending",
    "Politics",
    "Sports",
    "Crypto",
    "Entertainment",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF6F6F6),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
              child: Row(
                children: [
                  Image.asset("assets/images/IconLogo.png", height: 32.h),
                  SizedBox(width: 5.w),
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: "BeTrade",
                          style: TextStyle(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        WidgetSpan(
                          alignment: PlaceholderAlignment.top,
                          child: Transform.translate(
                            offset: Offset(1.w, -6.h),
                            child: Text(
                              "TM",
                              style: TextStyle(
                                fontSize: 7.sp,
                                fontWeight: FontWeight.w600,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  Icon(Icons.notifications_none, size: 24.sp),
                ],
              ),
            ),

            SizedBox(
              height: 50.h,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                itemCount: tabs.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      setState(() => selectedIndex = index);
                      _pageController.animateToPage(
                        index,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
                    child: _TabItem(
                      title: tabs[index],
                      isSelected: selectedIndex == index,
                    ),
                  );
                },
              ),
            ),
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() => selectedIndex = index);
                },
                children: [
                  _buildPollList(),
                  _buildFilteredPollList("Trending"),
                  _buildFilteredPollList("Politics"),
                  _buildFilteredPollList("Sports"),
                  _buildFilteredPollList("Crypto"),
                  _buildFilteredPollList("Entertainment"),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  Widget _buildPollList() {
    return ListView.builder(
      padding: EdgeInsets.all(16.w),
      itemCount: polls.length,
      itemBuilder: (context, index) {
        return PollCard(poll: polls[index]);
      },
    );
  }
  Widget _buildFilteredPollList(String category) {
    final filteredPolls =
    polls.where((poll) => poll.category == category).toList();

    return ListView.builder(
      padding: EdgeInsets.all(16.w),
      itemCount: filteredPolls.length,
      itemBuilder: (context, index) {
        return PollCard(poll: filteredPolls[index]);
      },
    );
  }
}

class _TabItem extends StatelessWidget {
  final String title;
  final bool isSelected;

  const _TabItem({required this.title, this.isSelected = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(right: 20.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              color: isSelected ? Colors.black : Colors.grey,
            ),
          ),
          SizedBox(height: 6.h),
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            height: 3.h,
            width: isSelected ? 22.w : 0,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(10.r),
            ),
          ),
        ],
      ),
    );
  }
}

class PollCard extends StatelessWidget {
  final PollModel poll;

  const PollCard({super.key, required this.poll});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey, width: 1),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "${poll.category} • ${poll.time}",
                style: AppTextStyle.small,
              ),
              Icon(Icons.bookmark_border, size: 20.sp),
            ],
          ),
          SizedBox(height: 6.h),
          Text(poll.question, style: AppTextStyle.body),
          SizedBox(height: 10.h),
          Container(
            padding: EdgeInsets.all(14.w),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.grey, width: 1),
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Column(
              children: [
                if (poll.image != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12.r),
                    child: Image.asset(
                      poll.image!,
                      height: 161.h,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                SizedBox(height: 10.h),
                _voteBar("Yes", poll.yesPercent, Colors.green.shade200),
                SizedBox(height: 8.h),
                _voteBar("No", poll.noPercent, Colors.red.shade200),
              ],
            ),
          ),
          SizedBox(height: 10.h),
          Row(
            children: [
              Text(
                "${poll.trades} trades",
                style: TextStyle(color: Colors.grey, fontSize: 12.sp),
              ),
              const Spacer(),
              Icon(Icons.share, size: 18.sp),
              SizedBox(width: 5.w),
              Text(
                "Share",
                style: TextStyle(color: Colors.grey, fontSize: 12.sp),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _voteBar(String label, int percent, Color color) {
    return Stack(
      children: [
        Container(
          height: 36.h,
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(10.r),
          ),
        ),
        FractionallySizedBox(
          widthFactor: percent / 100,
          child: Container(
            height: 36.h,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(10.r),
            ),
          ),
        ),
        Positioned.fill(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 10.w),
            child: Row(
              children: [
                Text(label, style: TextStyle(fontSize: 12.sp)),
                const Spacer(),
                Text("$percent%", style: TextStyle(fontSize: 12.sp)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

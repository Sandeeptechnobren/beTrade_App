import 'package:betrade/presentation/widget/common_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/theme/app_colors.dart';

class AchievementsSheet extends StatefulWidget {
  final ScrollController scrollController;

  const AchievementsSheet({super.key, required this.scrollController});

  @override
  State<AchievementsSheet> createState() => _AchievementsSheetState();
}

class _AchievementsSheetState extends State<AchievementsSheet> {
  List<Map<String, String>> achievements = [
    {"image": "assets/images/Archivement (1).png", "title": "First\nDeposit"},
    {"image": "assets/images/Archivement (2).png", "title": "First\nTrade"},
    {"image": "assets/images/Archivement (3).png", "title": "First\nWin"},
    {"image": "assets/images/Archivement (2).png", "title": "First\nDeposit"},
    {"image": "assets/images/Archivement (1).png", "title": "Second\nDeposit"},
    {"image": "assets/images/Archivement (3).png", "title": "Second\nTrade"},
    {"image": "assets/images/Archivement (1).png", "title": "Second\nWin"},
    {"image": "assets/images/Archivement (2).png", "title": "Second\nDeposit"},
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.inputFieldBgDynamic(context),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      child: SingleChildScrollView(
        controller: widget.scrollController,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CommonHeader(title: "Achievements"),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: achievements.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  crossAxisSpacing: 6.w,
                  mainAxisSpacing: 20.h,
                  childAspectRatio: 0.65,
                ),
                itemBuilder: (context, index) {
                  final item = achievements[index];
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: EdgeInsets.all(6.w),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                        ),
                        child: CircleAvatar(
                          radius: 30.r,
                          backgroundImage: AssetImage(item["image"]!),
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        item["title"]!,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            SizedBox(height: 12.h),
          ],
        ),
      ),
    );
  }
}

import 'package:betrade/core/theme/app_text_style.dart';
import 'package:betrade/presentation/widget/common_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AchievementsSheet extends StatefulWidget {
  final ScrollController scrollController;

  const AchievementsSheet({super.key, required this.scrollController});

  @override
  State<AchievementsSheet> createState() => _AchievementsSheetState();
}

class _AchievementsSheetState extends State<AchievementsSheet> {
  // Figma tokens (Frame 2609813 — achievements sheet)
  static const Color _hairline = Color(0xFFF4F4F5);
  static const Color _titleColor = Color(0xFF52525B);

  final List<Map<String, String>> achievements = [
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(32.r),
      ),
      child: SingleChildScrollView(
        controller: widget.scrollController,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CommonHeader(title: "Achievements"),
            Padding(
              padding: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 24.h),
              child: Column(
                children: [
                  // Two rows of 4 — avoids GridView's aspectRatio overflow
                  // (cell-height was clipping the 2-line title by ~1px on
                  // narrower devices).
                  _badgeRow(achievements.sublist(0, 4)),
                  SizedBox(height: 24.h),
                  _badgeRow(achievements.sublist(4, 8)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _badgeRow(List<Map<String, String>> items) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (int i = 0; i < items.length; i++) ...[
          Expanded(child: _badgeCell(items[i])),
          if (i != items.length - 1) SizedBox(width: 8.w),
        ],
      ],
    );
  }

  Widget _badgeCell(Map<String, String> item) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 64.w,
          height: 64.w,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: _hairline, width: 1),
            image: DecorationImage(
              image: AssetImage(item["image"]!),
              fit: BoxFit.cover,
            ),
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          item["title"]!,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 16.sp,
            height: 1.2,
            fontWeight: FontWeight.w500,
            color: _titleColor,
            fontFamily: AppTextStyle.fontFamily,
          ),
        ),
      ],
    );
  }
}

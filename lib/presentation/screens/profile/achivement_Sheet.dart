import 'package:betrade/core/theme/app_colors.dart';
import 'package:betrade/core/theme/app_text_style.dart';
import 'package:betrade/presentation/widget/common_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../../data/model/achievement_model.dart';
import '../../../data/provider/profile_provider.dart';

class AchievementsSheet extends StatelessWidget {
  final ScrollController scrollController;

  const AchievementsSheet({super.key, required this.scrollController});

  static const Color _gold = Color(0xFFF59E0B);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackgroundDynamic(context),
        borderRadius: BorderRadius.circular(32.r),
      ),
      child: Column(
        children: [
          const CommonHeader(title: "Achievements"),
          Expanded(
            child: Consumer<ProfileProvider>(
              builder: (context, provider, _) {
                final items = provider.achievements;

                if (items.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: EdgeInsets.all(24.w),
                      child: Text(
                        provider.isLoading
                            ? "Loading achievements…"
                            : "No achievements yet.",
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: AppColors.textSecondaryDynamic(context),
                          fontFamily: AppTextStyle.fontFamily,
                        ),
                      ),
                    ),
                  );
                }

                final unlocked = items.where((a) => a.earned).length;
                return ListView(
                  controller: scrollController,
                  padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 24.h),
                  children: [
                    Padding(
                      padding: EdgeInsets.only(bottom: 12.h),
                      child: Text(
                        "$unlocked of ${items.length} unlocked",
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondaryDynamic(context),
                          fontFamily: AppTextStyle.fontFamily,
                        ),
                      ),
                    ),
                    ...items.map((a) => _row(context, a)),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _row(BuildContext context, AchievementModel a) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: AppColors.whiteDynamic(context),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: AppColors.borderDynamic(context)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 52.w,
            height: 52.w,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: a.earned
                  ? _gold.withValues(alpha: 0.12)
                  : AppColors.inputFieldBgDynamic(context),
              border: Border.all(
                color: a.earned ? _gold : AppColors.borderDynamic(context),
                width: 1.5,
              ),
            ),
            child: Icon(
              a.earned ? Icons.emoji_events : Icons.lock_outline,
              size: 24.sp,
              color: a.earned ? _gold : AppColors.textSecondaryDynamic(context),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  a.name,
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimaryDynamic(context),
                    fontFamily: AppTextStyle.fontFamily,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  a.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: AppColors.textSecondaryDynamic(context),
                    fontFamily: AppTextStyle.fontFamily,
                  ),
                ),
                SizedBox(height: 8.h),
                if (a.earned)
                  Text(
                    "Unlocked",
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: _gold,
                      fontFamily: AppTextStyle.fontFamily,
                    ),
                  )
                else ...[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4.r),
                    child: LinearProgressIndicator(
                      value: (a.progressPct.clamp(0, 100)) / 100.0,
                      minHeight: 5.h,
                      backgroundColor: AppColors.inputFieldBgDynamic(context),
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    a.progressLabel,
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: AppColors.textSecondaryDynamic(context),
                      fontFamily: AppTextStyle.fontFamily,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

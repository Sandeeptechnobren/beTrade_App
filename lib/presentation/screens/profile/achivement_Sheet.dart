import 'dart:ui' as ui;

import 'package:betrade/core/theme/app_colors.dart';
import 'package:betrade/core/theme/app_text_style.dart';
import 'package:betrade/presentation/widget/common_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../../../data/model/achievement_model.dart';
import '../../../data/provider/profile_provider.dart';

/// "Achievements" sheet — a 4-per-row grid of badges (Figma layout): each badge
/// is the client's SVG art with a short label underneath. Earned badges render
/// crisp; locked ones are blurred (frosted) to signal they're not unlocked yet.
/// Driven by live data from [ProfileProvider.achievements].
class AchievementsSheet extends StatelessWidget {
  final ScrollController scrollController;

  const AchievementsSheet({super.key, required this.scrollController});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackgroundDynamic(context),
        borderRadius: BorderRadius.circular(32.r),
      ),
      // Content-hugging (mainAxisSize.min) so the sheet is exactly as tall as
      // the header + badge grid — matches the Figma sheet, no empty band.
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CommonHeader(title: "Achievements"),
          Consumer<ProfileProvider>(
            builder: (context, provider, _) {
              final items = provider.achievements;

              if (items.isEmpty) {
                return Padding(
                  padding: EdgeInsets.all(28.w),
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
                );
              }

              return Padding(
                padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 24.h),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (final row in _chunk(items, 4)) _badgeRow(context, row),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  /// Splits [items] into consecutive groups of [size] (last group may be smaller).
  List<List<AchievementModel>> _chunk(List<AchievementModel> items, int size) {
    final out = <List<AchievementModel>>[];
    for (var i = 0; i < items.length; i += size) {
      final end = (i + size > items.length) ? items.length : i + size;
      out.add(items.sublist(i, end));
    }
    return out;
  }

  Widget _badgeRow(BuildContext context, List<AchievementModel> row) {
    // Always 4 equal columns so badges align to a clean grid; trailing gaps in
    // the last (partial) row stay empty.
    final cells = <Widget>[];
    for (var i = 0; i < 4; i++) {
      if (i > 0) cells.add(SizedBox(width: 12.w));
      cells.add(
        Expanded(
          child: i < row.length
              ? _badgeCell(context, row[i])
              : const SizedBox.shrink(),
        ),
      );
    }
    return Padding(
      padding: EdgeInsets.only(bottom: 20.h),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: cells),
    );
  }

  Widget _badgeCell(BuildContext context, AchievementModel a) {
    Widget art = SvgPicture.asset(
      _badgeAsset(a),
      width: 60.w,
      height: 60.w,
      fit: BoxFit.cover,
    );
    // Locked → blurred (frosted). Earned → crisp.
    if (!a.earned) {
      art = ImageFiltered(
        imageFilter: ui.ImageFilter.blur(sigmaX:3, sigmaY:3),
        child: art,
      );
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 60.w,
          height: 60.w,
          child: ClipOval(child: art),
        ),
        SizedBox(height: 8.h),
        Text(
          a.name,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 11.sp,
            fontWeight: FontWeight.w500,
            height: 1.2,
            color: AppColors.textPrimaryDynamic(context),
            fontFamily: AppTextStyle.fontFamily,
          ),
        ),
      ],
    );
  }

  /// Maps an achievement to one of the bundled SVG badge arts by its key/name
  /// (deposit / trade / win), falling back to the deposit art.
  static String _badgeAsset(AchievementModel a) {
    final k = '${a.key} ${a.name}'.toLowerCase();
    if (k.contains('win')) return 'assets/svgs/firstwin.svg';
    if (k.contains('trade')) return 'assets/svgs/firsttrade.svg';
    return 'assets/svgs/firstdeposite.svg';
  }
}

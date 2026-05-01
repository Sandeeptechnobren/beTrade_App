import 'package:betrade/core/theme/app_colors.dart';
import 'package:betrade/core/theme/app_text_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../widget/common_header.dart';

class NotificationPreferencesPage extends StatefulWidget {
  const NotificationPreferencesPage({
    super.key,
    required ScrollController scrollController,
  });

  @override
  State<NotificationPreferencesPage> createState() =>
      _NotificationPreferencesPageState();
}

class _NotificationPreferencesPageState
    extends State<NotificationPreferencesPage> {
  bool trendingMarkets = true;
  bool newMarkets = true;
  bool positionUpdates = true;
  bool payouts = true;
  bool tradeConfirmations = true;
  bool deposits = true;
  bool withdrawals = true;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Sheet body — top-rounded 19.5 per Figma is handled by CommonBottomSheet's
      // ClipRRect; this Container just enforces the white inner surface and
      // the 8px padding from the spec.
      body: SafeArea(
        child: Column(
          children: [
            const CommonHeader(title: "Notification Preferences"),
            Expanded(
              child: Padding(
                // padding: 8px (Figma)
                padding: EdgeInsets.all(8.w),
                child: Column(
                  children: [
                    SizedBox(height: 12.h),
                    Expanded(
                      child: ListView(
                        children: [
                          buildSection(
                            title: "Discover & Trends",
                            items: [
                              buildItem(
                                "Trending Markets",
                                "What everyone is trading right now",
                                trendingMarkets,
                                (val) => setState(() => trendingMarkets = val),
                              ),
                              buildItem(
                                "New Markets",
                                "Be the first to explore new opportunities",
                                newMarkets,
                                (val) => setState(() => newMarkets = val),
                              ),
                            ],
                          ),

                          buildSection(
                            title: "Your Trades",
                            items: [
                              buildItem(
                                "Position Updates",
                                "Changes to your active trades",
                                positionUpdates,
                                (val) => setState(() => positionUpdates = val),
                              ),
                              buildItem(
                                "Payouts & Winnings",
                                "When you earn from a winning trade",
                                payouts,
                                (val) => setState(() => payouts = val),
                              ),
                              buildItem(
                                "Trade Confirmations",
                                "When a trade is successfully placed",
                                tradeConfirmations,
                                (val) =>
                                    setState(() => tradeConfirmations = val),
                              ),
                            ],
                          ),

                          buildSection(
                            title: "Wallet Activity",
                            items: [
                              buildItem(
                                "Deposits",
                                "When money is added to your wallet",
                                deposits,
                                (val) => setState(() => deposits = val),
                              ),
                              buildItem(
                                "Withdrawals",
                                "Status updates on your withdrawals",
                                withdrawals,
                                (val) => setState(() => withdrawals = val),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildSection({required String title, required List<Widget> items}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      // gap: 9.75px (Figma)
      margin: EdgeInsets.only(bottom: 9.75.h),
      padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 16.h),
      decoration: BoxDecoration(
        // Figma section card — soft neutral grey on white sheet
        color: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF5F5F7),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            // Same SFProRounded family as the sheet header; size tuned to fit a section heading.
            style: AppTextStyle.heading.copyWith(
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimaryDynamic(context),
            ),
          ),
          SizedBox(height: 10.h),
          Column(children: items),
        ],
      ),
    );
  }

  Widget buildItem(
    String title,
    String subtitle,
    bool value,
    Function(bool) onChanged,
  ) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyle.body.copyWith(
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimaryDynamic(context),
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 11.sp, color: Colors.grey),
                ),
              ],
            ),
          ),

          Transform.scale(
            scale: 0.9,
            child: Switch(
              value: value,
              onChanged: onChanged,
              activeColor: Colors.white,
              activeTrackColor: const Color(0xFF7B2FF7),
              inactiveTrackColor: Colors.grey.shade300,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
        ],
      ),
    );
  }
}

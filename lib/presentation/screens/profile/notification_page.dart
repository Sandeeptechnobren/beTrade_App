import 'package:betrade/core/theme/app_colors.dart';
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
      body: SafeArea(
        child: Column(
          children: [
            const CommonHeader(title: "Notification Preferences"),
            Expanded(
              child: Padding(
                padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.w),
                child: Column(
                  children: [
                    SizedBox(height: 20.h),
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
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: AppColors.inputFieldBg,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
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
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
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
            scale: 0.8,
            child: Switch(
              value: value,
              onChanged: onChanged,
              activeColor: Colors.white,
              activeTrackColor: Colors.deepPurple,
              inactiveTrackColor: Colors.grey.shade300,
            ),
          ),
        ],
      ),
    );
  }
}

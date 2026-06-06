import 'dart:async';
import 'dart:math';
import 'package:betrade/core/theme/app_text_style.dart';
import 'package:betrade/presentation/widget/common_share_button.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/cupertino.dart';
import '../../../core/theme/app_colors.dart';
import '../../widget/common_header.dart';

class InfoChartScreen extends StatefulWidget {
  @override
  State<InfoChartScreen> createState() => _InfoChartScreenState();
}

class _InfoChartScreenState extends State<InfoChartScreen> {
  int selectedIndex = 1;
  String selectedTab = "1D";

  late Timer timer;
  double xValue = 19;

  List<FlSpot> spots = [
    FlSpot(0, 45),
    FlSpot(1, 35),
    FlSpot(2, 40),
    FlSpot(3, 25),
    FlSpot(4, 30),
    FlSpot(5, 35),
    FlSpot(6, 34),
    FlSpot(7, 42),
    FlSpot(8, 38),
    FlSpot(9, 52),
    FlSpot(10, 55),
    FlSpot(11, 53),
    FlSpot(12, 45),
    FlSpot(13, 40),
    FlSpot(14, 38),
    FlSpot(15, 42),
    FlSpot(16, 48),
    FlSpot(17, 50),
    FlSpot(18, 30),
  ];

  @override
  void initState() {
    super.initState();
    startLiveGraph();
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  void startLiveGraph() {
    timer = Timer.periodic(Duration(milliseconds: 700), (timer) {
      setState(() {
        xValue += 1;
        double newY = 30 + Random().nextInt(25).toDouble();
        spots.removeAt(0);
        spots.add(FlSpot(xValue, newY));
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(0, 0, 16.w, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CommonHeader(title: "", showDivider: false),
                  CommonShareButton(onTap: () {}),
                ],
              ),
            ),
            Row(children: [tabItem("Info", 0), tabItem("Chart", 1)]),
            Expanded(child: selectedIndex == 0 ? infoUI() : chartUI()),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.btnGreen,
                        shape: StadiumBorder(),
                        padding: EdgeInsets.symmetric(vertical: 14.w),
                      ),
                      onPressed: () => _showNoMarketSnack(context),
                      child: Text(
                        "Buy Yes",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.btnRed,
                        shape: StadiumBorder(),
                        padding: EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: () => _showNoMarketSnack(context),
                      child: Text(
                        "Buy No",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Buy Yes / Buy No used to be empty stubs on this screen (QA #12).
  /// InfoChartScreen has no market context — it's the standalone 3rd
  /// nav tab — so there's nothing to "buy". Direct the user to the
  /// Explore tab where they can pick a market first; the buy modal
  /// lives on the trade detail page reached from there.
  void _showNoMarketSnack(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
        margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        content: const Text(
          "Pick a market from the Explore tab to place a trade.",
        ),
      ),
    );
  }

  Widget tabItem(String title, int index) {
    bool isSelected = selectedIndex == index;
    return GestureDetector(
      onTap: () => setState(() => selectedIndex = index),
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 16),
        padding: EdgeInsets.only(bottom: 6),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isSelected ? AppColors.primary : Colors.transparent,
              width: 3.w,
            ),
          ),
        ),
        child: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isSelected
                ? AppColors.textPrimaryDynamic(context)
                : AppColors.textSecondaryDynamic(context),
          ),
        ),
      ),
    );
  }

  Widget chartUI() {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
          child: Row(
            children: [
              Text(
                "28% Chance",
                style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.bold),
              ),
              Spacer(),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: AppColors.inputFieldBgDynamic(context),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text("20%", style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        ),
        SizedBox(height: 10.h),
        Expanded(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 5.w),
            child: LineChart(
              LineChartData(
                minY: 0,
                maxY: 70,
                gridData: FlGridData(show: true),
                titlesData: FlTitlesData(show: false),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    curveSmoothness: 0.4,
                    color: AppColors.primary,
                    barWidth: 3,
                    belowBarData: BarAreaData(
                      show: true,
                      color: Colors.purple.withOpacity(0.2),
                    ),
                    dotData: FlDotData(show: false),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget infoUI() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Will bitcoin exceed \$200k before the end of \n 2026?",
            style: AppTextStyle.body,
          ),
          SizedBox(height: 10.h),
          card(
            "Will the price of Bitcoin (BTC) exceed \$200,000 USD on any major exchange at any point before December 31, 2025 at 11:59 PM ET?",
          ),
          SizedBox(height: 16.h),
          Text("Market Activity", style: AppTextStyle.body),
          SizedBox(height: 10.h),
          Container(
            padding: EdgeInsets.all(14.w),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: AppColors.borderDynamic(context)),
            ),
            child: Column(
              children: [
                activityRow("Current Price", "12.40 GHS per share"),
                divider(),
                activityRow(
                  "Market Status",
                  "Open",
                  valueColor: AppColors.btnGreen,
                ),
                divider(),
                activityRow("Total Volume", "410,250 GHS"),
                divider(),
                activityRow("Liquidity", "92,000 GHS"),
                divider(),
                activityRow("Closes On", "31/12/2026"),
              ],
            ),
          ),
          SizedBox(height: 16.h),
          resolutionCard(
            title: "Resolution Source",
            points: [
              "The final market outcome will be determined using verified public information from the following sources:",
              "Official company announcements",
              "Regulatory filings",
              "Major financial news publications",
              "Platform-approved data providers",
              "If multiple sources are available, the platform will prioritize official company disclosures and regulatory filings.",
            ],
          ),
          SizedBox(height: 8.h),
          resolutionCard(
            title: "Resolution Source",
            points: [
              "The market will resolve when a verified funding event, acquisition, or predefined milestone occurs.",
              "Resolution will occur within 72 hours after confirmation from an approved resolution source.",
              "If conflicting information exists, the platform administrators may review additional sources before finalizing the result.",
              "Once a market is resolved:",
              "Trading will be permanently closed",
              "Final prices will be locked",
              "Payouts or ownership allocations will be executed according to the outcome",
            ],
          ),
        ],
      ),
    );
  }

  Widget resolutionCard({required String title, required List<String> points}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTextStyle.body),
        SizedBox(height: 10.h),
        Container(
          padding: EdgeInsets.all(14.w),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: AppColors.borderDynamic(context)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ...points.map((e) {
                bool isHeading = e.contains(":");
                return Padding(
                  padding: EdgeInsets.symmetric(vertical: 3.h),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (!isHeading)
                        Text("• ", style: TextStyle(fontSize: 14.sp)),
                      Expanded(child: Text(e, style: AppTextStyle.bodyBig)),
                    ],
                  ),
                );
              }).toList(),
            ],
          ),
        ),
      ],
    );
  }

  Widget activityRow(String title, String value, {Color? valueColor}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10.h),
      child: Row(
        children: [
          Text(title, style: AppTextStyle.bodyBig),
          Text(value, style: AppTextStyle.bodyBig),
        ],
      ),
    );
  }

  Widget divider() {
    return Divider(height: 1.h, color: AppColors.borderDynamic(context));
  }

  Widget card(String text) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(width: 1.w, color: AppColors.borderDynamic(context)),
      ),
      child: Text(text, style: AppTextStyle.bodyBig),
    );
  }
}

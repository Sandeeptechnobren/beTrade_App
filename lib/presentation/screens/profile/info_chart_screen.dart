import 'package:betrade/core/theme/app_text_style.dart';
import 'package:betrade/presentation/widget/common_share_button.dart';
import 'package:betrade/utils/app_colors.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/cupertino.dart';
import '../../widget/common_header.dart';

class InfoChartScreen extends StatefulWidget {
  @override
  State<InfoChartScreen> createState() => _InfoChartScreenState();
}

class _InfoChartScreenState extends State<InfoChartScreen> {
  int selectedIndex = 1;
  String selectedTab = "1D";
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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CommonHeader(title: ""),
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
                        backgroundColor: Colors.green,
                        shape: StadiumBorder(),
                        padding: EdgeInsets.symmetric(vertical: 14.w),
                      ),
                      onPressed: () {},
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
                        backgroundColor: Colors.red,
                        shape: StadiumBorder(),
                        padding: EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: () {},
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
              color: isSelected ? AppColors.primary: Colors.transparent,
              width: 3,
            ),
          ),
        ),
        child: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isSelected ? Colors.black : Colors.grey,
          ),
        ),
      ),
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
          SizedBox(height: 10),
          card(
            "Will the price of Bitcoin (BTC) exceed \$200,000 USD on any major exchange at any point before December 31, 2025 at 11:59 PM ET?",
          ),
          SizedBox(height: 16),
          Text("Market Activity", style: AppTextStyle.body),
          SizedBox(height: 10),
          Container(
            padding: EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Column(
              children: [
                activityRow("Current Price", "12.40 GHS per share"),
                divider(),
                activityRow("Market Status", "Open", valueColor: Colors.green),
                divider(),
                activityRow("Total Volume", "410,250 GHS"),
                divider(),
                activityRow("Liquidity", "92,000 GHS"),
                divider(),
                activityRow("Closes On", "31/12/2026"),
              ],
            ),
          ),
          SizedBox(height: 16),
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
          SizedBox(height: 8),
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
  Widget activityRow(String title, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Text(title, style: AppTextStyle.bodyBig),
          Text(value, style: AppTextStyle.bodyBig),
        ],
      ),
    );
  }

  Widget divider() {
    return Divider(height: 1, color: Colors.grey.shade200);
  }
  Widget resolutionCard({required String title, required List<String> points}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTextStyle.body),
        SizedBox(height: 10),
        Container(
          padding: EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ...points.map((e) {
                bool isHeading = e.contains(":");
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 3),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (!isHeading)
                        Text("• ", style: TextStyle(fontSize: 14)),
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

  Widget chartUI() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              Text(
                "28% Chance",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              Spacer(),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.red.shade100,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text("20%", style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 6.h),
          decoration: BoxDecoration(
            color: AppColors.iconContainer,
            borderRadius: BorderRadius.circular(25.r),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: ["1D", "1W", "1M", "1Y", "MAX"].map((e) {
              final isSelected = selectedTab == e;
              return GestureDetector(
                onTap: () => setState(() => selectedTab = e),
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 4.w),
                  padding: EdgeInsets.symmetric(
                    horizontal: 14.w,
                    vertical: 6.h,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.white : Colors.transparent,
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Text(
                    e,
                    style: AppTextStyle.body.copyWith(
                      fontSize: 16.sp,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.w400,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        SizedBox(height: 10),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5),
            child: LineChart(
              LineChartData(
                minY: 0,
                maxY: 100,
                gridData: FlGridData(show: true),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 10,
                      getTitlesWidget: (value, meta) {
                        return FittedBox(
                          alignment: Alignment.centerRight,
                          child: Text(
                            "${value.toInt()}%",
                            style: TextStyle(fontSize: 16.sp),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color:AppColors.primary,
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

  Widget card(String text) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(width: 1, color: Colors.grey),
      ),
      child: Text(text, style: AppTextStyle.bodyBig),
    );
  }

  Widget infoRow(String title, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Text(title),
          Spacer(),
          Text(value, style: TextStyle(color: color ?? Colors.black)),
        ],
      ),
    );
  }
}

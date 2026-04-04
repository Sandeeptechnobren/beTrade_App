import 'package:betrade/presentation/screens/portfolio/wallet_history.dart';
import 'package:betrade/presentation/screens/portfolio/withdraw/withdrawal.dart'
    hide DepositPage;
import 'package:flutter/material.dart';
import 'package:betrade/presentation/widget/icon_container.dart';
import 'package:betrade/presentation/widget/rounded_tab_indicator.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax/iconsax.dart';
import '../../../core/theme/app_colors.dart';
import '../../widget/Common_header_withlogo.dart';
import '../../widget/common_bottom_sheet.dart';
import 'deposit/newDeposit.dart';

class PortfolioPage extends StatefulWidget {
  const PortfolioPage({super.key});

  @override
  State<PortfolioPage> createState() => _PortfolioPageState();
}

class _PortfolioPageState extends State<PortfolioPage> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: GlobalAppBar(),
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 10.h),

                        SizedBox(height: 20.h),
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(16.w),
                          decoration: BoxDecoration(
                            image: const DecorationImage(
                              image: AssetImage("assets/images/splash.png"),
                              fit: BoxFit.cover,
                            ),
                            borderRadius: BorderRadius.circular(22.r),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        "Available to trade",
                                        style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                          color: Colors.white,
                                          fontSize: 16.sp,
                                        ),
                                      ),
                                      SizedBox(width: 5.w),
                                      const Icon(
                                        Iconsax.eye,
                                        color: Colors.white,
                                      ),
                                    ],
                                  ),
                                  Material(
                                    color: AppColors.iconContainer1,
                                    borderRadius: BorderRadius.circular(50.r),
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(50.r),
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => const WalletHistoryPage(),
                                          ),
                                        );
                                      },
                                      child: SizedBox(
                                        height: 40.w,
                                        width: 40.w,
                                        child: Center(
                                          child: Icon(
                                            Icons.more_horiz,
                                            color: Colors.white,
                                            size: 22.sp,
                                          ),
                                        ),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                              SizedBox(height: 5.h),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    "0.00",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 30.sp,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(width: 4.w),
                                  Text(
                                    "GHS",
                                    style:TextStyle(fontFamily: "SFProRounded",fontSize: 14.sp,color: Colors.white,fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              SizedBox(height: 20.h),
                              Row(
                                children: [
                                  Expanded(
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(30.r),
                                      onTap: () {
                                        CommonBottomSheet.open(
                                          context: context,
                                          builder: (controller) => DepositPage(
                                            scrollController: controller,
                                          ),
                                        );
                                      },
                                      child: _gradientButton("Deposit"),
                                    ),
                                  ),
                                  SizedBox(width: 10.w),
                                  Expanded(
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(30.r),
                                      onTap: () {
                                        CommonBottomSheet.open(
                                          context: context,
                                          builder: (controller) => WithdrawPage(
                                            scrollController: controller,
                                          ),
                                        );
                                      },
                                      child: _outlineButton("Withdraw"),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 20.h),
                        TabBar(
                          labelColor: Colors.black,
                          unselectedLabelColor: Colors.grey,
                          indicator: RoundedTabIndicator(
                            color: AppColors.primary,
                            radius: 10,
                            height: 3,
                          ),
                          tabs: const [
                            Tab(text: "Open Positions"),
                            Tab(text: "Closed Positions"),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: TabBarView(
                    children: [_openPositions(), _closedPositions()],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _openPositions() {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: 40.h),
          Image.asset("assets/images/no_open_position.png"),
          SizedBox(height: 12.h),
          Text(
            "No Open Positions",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp),
          ),
          SizedBox(height: 6.h),
          Text(
            "When you trade on a market, your\nactive positions will appear here.",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey, fontSize: 12.sp),
          ),
        ],
      ),
    );
  }

  Widget _closedPositions() {
    return Center(
      child: Text("No Closed Positions", style: TextStyle(fontSize: 14.sp)),
    );
  }

  Widget _gradientButton(String text) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 12.h),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30.r),
        color: AppColors.primary,
      ),
      child: Text(
        text,
        style: TextStyle(
          color: Colors.white,
          fontSize: 16.sp,
          fontWeight: FontWeight.bold,
          fontFamily: 'SFProRounded',
        ),
      ),
    );
  }

  Widget _outlineButton(String text) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 12.h),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30.r),
        color: Colors.white,
      ),
      child: Text(
        text,
        style: TextStyle(
          color: Colors.black,
          fontSize: 16.sp,
          fontWeight: FontWeight.bold,
          fontFamily: 'SFProRounded',
        ),
      ),
    );
  }
}

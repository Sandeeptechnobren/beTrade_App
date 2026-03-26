import 'package:betrade/presentation/screens/portfolio/withdraw/withdrawal.dart'
    hide DepositPage;
import 'package:flutter/material.dart';
import 'package:betrade/presentation/widget/icon_container.dart';
import 'package:betrade/presentation/widget/rounded_tab_indicator.dart';
import 'package:betrade/utils/app_colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax/iconsax.dart';

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
        backgroundColor: Colors.white,
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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Image.asset(
                                  "assets/logo/IconLogo.png",
                                  height: 28,
                                  width: 28,
                                ),
                                SizedBox(width: 5.w),
                                Image.asset("assets/logo/logo_name.png"),
                              ],
                            ),
                            IconContainer(
                              icon: Iconsax.notification,
                              color: AppColors.iconContainer,
                              iconColor: Colors.black,
                            ),
                          ],
                        ),

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
                                  IconContainer(
                                    icon: Icons.more_horiz,
                                    color: AppColors.iconContainer1,
                                    iconColor: Colors.white,
                                  ),
                                ],
                              ),
                              SizedBox(height: 10.h),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
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
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.w600,
                                    ),
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
                                        showModalBottomSheet(
                                          context: context,
                                          isScrollControlled: true,
                                          backgroundColor: Colors.transparent,
                                          // important
                                          builder: (context) {
                                            return Padding(
                                              padding: EdgeInsets.only(
                                                left: 10.w,
                                                right: 10.w,
                                                top: 20.h,
                                                bottom: 20.h,
                                              ),
                                              child: ClipRRect(
                                                borderRadius: BorderRadius.only(
                                                  topLeft: Radius.circular(
                                                    20.r,
                                                  ),
                                                  topRight: Radius.circular(
                                                    20.r,
                                                  ),
                                                  bottomLeft: Radius.circular(
                                                    15.r,
                                                  ),
                                                  bottomRight: Radius.circular(
                                                    15.r,
                                                  ),
                                                ),
                                                child: Container(
                                                  color: Colors.white,
                                                  child: DraggableScrollableSheet(
                                                    initialChildSize: 0.9,
                                                    minChildSize: 0.7,
                                                    maxChildSize: 0.95,
                                                    expand: false,
                                                    builder:
                                                        (
                                                          context,
                                                          scrollController,
                                                        ) {
                                                          return DepositPage(
                                                            scrollController:
                                                                scrollController,
                                                          );
                                                        },
                                                  ),
                                                ),
                                              ),
                                            );
                                          },
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
                                        showModalBottomSheet(
                                          context: context,
                                          isScrollControlled: true,
                                          builder: (context) {
                                            return Padding(
                                              padding: EdgeInsets.only(
                                                left: 10.w,
                                                right: 10.w,
                                                top: 20.h,
                                                bottom: 20.h,
                                              ),
                                              child: ClipRRect(
                                                borderRadius: BorderRadius.only(
                                                  topLeft: Radius.circular(
                                                    20.r,
                                                  ),
                                                  topRight: Radius.circular(
                                                    20.r,
                                                  ),
                                                  bottomLeft: Radius.circular(
                                                    15.r,
                                                  ),
                                                  bottomRight: Radius.circular(
                                                    15.r,
                                                  ),
                                                ),
                                                child: Container(
                                                  color: Colors.white,
                                                  child: DraggableScrollableSheet(
                                                    initialChildSize: 0.9,
                                                    minChildSize: 0.7,
                                                    maxChildSize: 0.95,
                                                    expand: false,
                                                    builder:
                                                        (
                                                        context,
                                                        scrollController,
                                                        ) {
                                                      return WithdrawPage(
                                                        scrollController:
                                                        scrollController,
                                                      );
                                                    },
                                                  ),
                                                ),
                                              ),
                                            );
                                          },
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

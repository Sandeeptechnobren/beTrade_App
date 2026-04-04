import 'package:betrade/presentation/screens/profile/achivement_Sheet.dart';
import 'package:betrade/presentation/screens/profile/edit_profile.dart';
import 'package:betrade/presentation/screens/profile/term_of_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../../data/provider/profile_provider.dart';
import '../../../core/theme/app_text_style.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/provider/theam_provider.dart';
import '../../../data/services/auth_service.dart';
import '../../../data/services/local_storage.dart';
import '../../auth/auth_screen.dart';
import '../../widget/Common_header_withlogo.dart';
import '../../widget/common_bottom_sheet.dart';
import 'Payment_method.dart';
import 'help_support_page.dart';
import 'notification_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool isDark = false;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      Provider.of<ProfileProvider>(context, listen: false).fetchProfile();
    });
  }

  void logoutUser() async {
    String? token = LocalStorage.getToken();
    if (token == null || token.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Token not found")));
      return;
    }

    setState(() => isLoading = true);
    bool success = await AuthService.logout(token);
    setState(() => isLoading = false);
    if (success) {
      await LocalStorage.clearToken();
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const AuthScreen()),
        (route) => false,
      );
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Logout Failed")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GlobalAppBar(),
      body: Consumer<ProfileProvider>(
        builder: (context, provider, child) {
          final profile = provider.profile;
          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                SizedBox(height: 20.h),
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 16.w),
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey, width: 0.5),
                    color: AppColors.inputFieldBgDynamic(context),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 42.r,
                        backgroundImage: profile?.avatar.isNotEmpty == true
                            ? NetworkImage(profile!.avatar)
                            : null,
                        child: profile?.avatar.isEmpty ?? true
                            ? Icon(Icons.person, size: 30.sp)
                            : null,
                      ),
                      SizedBox(height: 10.h),

                      Text(
                        provider.isLoading
                            ? "Loading..."
                            : profile != null
                            ? "${profile.firstName} ${profile.lastName}"
                            : "No Name",
                        style: AppTextStyle.heading,
                      ),

                      SizedBox(height: 16.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          buildStat("62%", "Win Rate"),
                          buildStat("€2.3k", "Total Earned"),
                          buildStat("324", "Total Trades"),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20.h),
                GestureDetector(
                  onTap: () {
                    CommonBottomSheet.open(
                      context: context,
                      builder: (controller) =>
                          AchievementsSheet(scrollController: controller),
                    );
                  },
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 16.w),
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey, width: 0.5),
                      color: AppColors.inputFieldBgDynamic(context),
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Achievements", style: AppTextStyle.body),
                            Icon(Icons.arrow_forward_ios, size: 14.sp),
                          ],
                        ),
                        SizedBox(height: 10.h),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            buildBadge("assets/images/Archivement (1).png"),
                            buildBadge("assets/images/Archivement (3).png"),
                            buildBadge("assets/images/Archivement (2).png"),
                            buildBadge("assets/images/Archivement (2).png"),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 20.h),
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 16.w),
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey, width: 0.5),
                    color: AppColors.inputFieldBgDynamic(context),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Column(
                    children: [
                      buildSwitchTile(),
                      GestureDetector(
                        onTap: () {
                          CommonBottomSheet.open(
                            context: context,
                            builder: (controller) =>
                                EditProfile(scrollController: controller),
                          );
                        },
                        child: buildListTile(
                          Icons.person_outline,
                          "Personal Info",
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          CommonBottomSheet.open(
                            context: context,
                            builder: (controller) => PaymentMethodsPage(
                              scrollController: controller,
                            ),
                          );
                        },
                        child: buildListTile(
                          Icons.account_balance_wallet_outlined,
                          "Payment Methods",
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          CommonBottomSheet.open(
                            context: context,
                            builder: (controller) =>
                                NotificationPreferencesPage(
                                  scrollController: controller,
                                ),
                          );
                        },
                        child: buildListTile(
                          Icons.notifications_none,
                          "Notification Preferences",
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          CommonBottomSheet.open(
                            context: context,
                            builder: (controller) =>
                                PrivacyPolicyPage(scrollController: controller),
                          );
                        },
                        child: buildListTile(
                          Icons.lock_outline,
                          "Privacy Policy",
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          CommonBottomSheet.open(
                            context: context,
                            builder: (controller) => TermsOfServicePage(
                              scrollController: controller,
                            ),
                          );
                        },
                        child: buildListTile(
                          Icons.description_outlined,
                          "Terms of Service",
                        ),
                      ),
                      GestureDetector(
                        onTap: showLogoutDialog,
                        child: buildListTile(Icons.logout, "Log Out"),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20.h),
              ],
            ),
          );
        },
      ),
    );
  }
  Widget buildStat(String value, String label) {
    return Container(
      width: 90.w,
      padding: EdgeInsets.symmetric(vertical: 10.h),
      decoration: BoxDecoration(
        color: AppColors.whiteDynamic(context),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        children: [
          Text(value, style: AppTextStyle.body),
          SizedBox(height: 4.h),
          Text(label, style: AppTextStyle.small),
        ],
      ),
    );
  }
  Widget buildBadge(String imagePath) {
    return CircleAvatar(
      radius: 34.r,
      backgroundColor: Colors.purple.withOpacity(0.2),
      backgroundImage: AssetImage(imagePath),
    );
  }
  Widget buildSwitchTile() {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                height: 40.h,
                width: 40.w,
                decoration: BoxDecoration(
                  color: AppColors.whiteDynamic(context),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(
                  Icons.dark_mode_outlined,
                  size: 24.sp,
                  color: AppColors.textSecondaryDynamic(context),
                ),
              ),
              SizedBox(width: 12.w),
              Text("Dark Mode", style: AppTextStyle.bodyBigDynamic(context)),
            ],
          ),
          Transform.scale(
            scale: 0.8,
            child: Switch(
              value: themeProvider.isDark,
              onChanged: (v) {
                themeProvider.toggleTheme(v);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget buildListTile(IconData icon, String title) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 12.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                height: 40.h,
                width: 40.w,
                decoration: BoxDecoration(
                  color: AppColors.whiteDynamic(context),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(
                  icon,
                  size: 24.sp,
                  color: AppColors.textSecondaryDynamic(context),
                ),
              ),
              SizedBox(width: 12.w),
              Text(title, style: AppTextStyle.bodyBig),
            ],
          ),
          Icon(Icons.arrow_forward_ios, size: 14.sp, color: Colors.grey),
        ],
      ),
    );
  }

  void showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Logout", style: AppTextStyle.heading),
          content: Text(
            "Are you sure you want to logout?",
            style: AppTextStyle.bodyBig,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("No"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                logoutUser();
              },
              child: const Text("Yes"),
            ),
          ],
        );
      },
    );
  }
}

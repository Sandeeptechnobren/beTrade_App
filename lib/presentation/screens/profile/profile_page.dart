import 'package:betrade/presentation/screens/profile/achivement_Sheet.dart';
import 'package:betrade/presentation/screens/profile/edit_profile.dart';
import 'package:betrade/presentation/screens/profile/term_of_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../../../core/network/dio_client.dart';
import '../../../data/provider/profile_provider.dart';
import '../../../core/theme/app_text_style.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/provider/theme_provider.dart';
import '../../../data/services/auth_service.dart';
import '../../../data/services/local_storage.dart';
import '../../auth/auth_screen.dart';
import '../../widget/Common_header_withlogo.dart';
import '../../widget/common_bottom_sheet.dart';
import 'Payment_method.dart';
import 'default_settings_page.dart';
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
    setState(() => isLoading = true);

    final token = LocalStorage.getToken();
    try {
      if (token != null && token.isNotEmpty) {
        await AuthService.logout(token);
      }
    } catch (e) {
      // Server-side logout can fail (token already revoked, network down). We
      // still need to clean up locally so the user actually gets logged out.
      debugPrint("Logout server call failed (continuing local cleanup): $e");
    } finally {
      // ALWAYS clear local state, regardless of whether the server call
      // succeeded. Otherwise the user is stuck signed in locally with a
      // server-dead token, and the stale Authorization header would leak into
      // the next user's multipart uploads via DioClient.multipartInstance.
      await LocalStorage.clearToken();
      DioClient.removeToken();
      if (mounted) {
        setState(() => isLoading = false);
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const AuthScreen()),
          (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Matches Figma: BeTrade™ + bell only, no hairline below.
      // Consistent with Explore / Rankings / Portfolio.
      appBar: GlobalAppBar(showBottomDivider: false),
      body: Consumer<ProfileProvider>(
        builder: (context, provider, child) {
          final profile = provider.profile;
          // print("EMAIL: ${profile?.email}");
          return RefreshIndicator(
            color: AppColors.primary,
            backgroundColor: AppColors.whiteDynamic(context),
            onRefresh: () async {
              await provider.fetchProfile();
            },
            child: SingleChildScrollView(
              // AlwaysScrollable required for RefreshIndicator to fire
              // even when content fits on one screen. Replaces the
              // previous BouncingScrollPhysics (which doesn't support
              // overscroll-triggered refresh).
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              child: Column(
              children: [
                SizedBox(height: 20.h),
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 16.w),
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300, width: 0.5),
                    color: AppColors.inputFieldBgDynamic(context),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Column(
                    children: [
                      // Profile avatar — uses the server-rendered 200×200
                      // thumbnail when present (cheaper to fetch on every
                      // tab open) and falls back to the full-resolution
                      // upload otherwise. Wrapped in ClipOval + Image.network
                      // so we get a proper errorBuilder fallback when the
                      // image fails to load (previously a bare NetworkImage
                      // would silently render an empty circle).
                      _ProfileCircle(
                        url: profile?.displayAvatar ?? '',
                        diameter: 84.r,
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
                      if (profile?.email != null &&
                          profile!.email!.isNotEmpty) ...[
                        SizedBox(height: 4.h),
                        Text(
                          profile.email!,
                          style: TextStyle(
                            fontSize: 13.sp,
                            color: Colors.grey,
                            fontFamily: 'SFProRounded',
                          ),
                        ),
                      ],
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
                // 16.h matches the cards' horizontal margin (16.w), so
                // the gaps between cards now form a consistent square
                // grid instead of feeling top-heavy (QA #9).
                SizedBox(height: 16.h),
                GestureDetector(
                  onTap: () {
                    CommonBottomSheet.open(
                      context: context,
                      initialChildSize: 0.55,
                      minChildSize: 0.45,
                      maxChildSize: 0.6,
                      builder: (controller) =>
                          AchievementsSheet(scrollController: controller),
                    );
                  },
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 16.w),
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      border:
                          Border.all(color: Colors.grey.shade300, width: 0.5),
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
                SizedBox(height: 16.h),
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 16.w),
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300, width: 0.5),
                    color: AppColors.inputFieldBgDynamic(context),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Column(
                    children: [
                      // Dark Mode Switch (not clickable like others)
                      buildSwitchTile(),
                      buildListTile(
                        LucideIcons.user,
                        "Personal Info",
                        () {
                          CommonBottomSheet.open(
                            context: context,
                            builder: (controller) =>
                                EditProfile(scrollController: controller),
                          );
                        },
                      ),
                      buildListTile(
                        LucideIcons.wallet,
                        "Payment Methods",
                        () {
                          CommonBottomSheet.open(
                            context: context,
                            builder: (controller) => PaymentMethodsPage(
                              scrollController: controller,
                            ),
                          );
                        },
                      ),
                      buildListTile(
                        LucideIcons.settings,
                        "Default Settings",
                        () {
                          CommonBottomSheet.open(
                            context: context,
                            builder: (controller) => DefaultSettingsPage(
                              scrollController: controller,
                            ),
                          );
                        },
                      ),
                      buildListTile(
                        LucideIcons.bell,
                        "Notification Preferences",
                        () {
                          CommonBottomSheet.open(
                            context: context,
                            // Figma scrim — #00000052
                            barrierColor: const Color(0x52000000),
                            builder: (controller) =>
                                NotificationPreferencesPage(
                              scrollController: controller,
                            ),
                          );
                        },
                      ),

                      buildListTile(
                        LucideIcons.shieldCheck,
                        "Privacy Policy",
                        () {
                          CommonBottomSheet.open(
                            context: context,
                            builder: (controller) =>
                                PrivacyPolicyPage(scrollController: controller),
                          );
                        },
                      ),

                      buildListTile(
                        LucideIcons.fileText,
                        "Terms of Service",
                        () {
                          CommonBottomSheet.open(
                            context: context,
                            builder: (controller) => TermsOfServicePage(
                              scrollController: controller,
                            ),
                          );
                        },
                      ),
                      buildListTile(
                        LucideIcons.logOut,
                        "Log Out",
                        showLogoutDialog,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20.h),
              ],
            ),
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
                  LucideIcons.moon,
                  size: 22.sp,
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

  Widget buildListTile(IconData icon, String title, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
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
                    size: 22.sp,
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

/// Reusable circular avatar with a graceful fallback.
///
/// CircleAvatar+NetworkImage silently shows an empty circle when the URL
/// fails to load. This wrapper uses Image.network's loadingBuilder +
/// errorBuilder so the user always sees either a progress indicator
/// (while loading) or a person glyph (on failure / missing URL), never an
/// invisible avatar.
class _ProfileCircle extends StatelessWidget {
  final String url;
  final double diameter;
  const _ProfileCircle({required this.url, required this.diameter});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: diameter,
      height: diameter,
      child: ClipOval(
        child: url.isEmpty
            ? _fallback()
            : Image.network(
                url,
                width: diameter,
                height: diameter,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, progress) {
                  if (progress == null) return child;
                  return Container(
                    color: Colors.grey.shade200,
                    alignment: Alignment.center,
                    child: const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  );
                },
                errorBuilder: (_, __, ___) => _fallback(),
              ),
      ),
    );
  }

  Widget _fallback() {
    return Container(
      color: Colors.grey.shade300,
      alignment: Alignment.center,
      child: Icon(Icons.person, size: diameter * 0.55, color: Colors.white),
    );
  }
}

import 'dart:ui' as ui;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:betrade/presentation/screens/profile/achivement_Sheet.dart';
import 'package:betrade/presentation/screens/profile/edit_profile.dart';
import 'package:betrade/presentation/screens/profile/term_of_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../../../core/network/dio_client.dart';
import '../../../data/provider/profile_provider.dart';
import '../../../data/model/achievement_model.dart';
import '../../../core/theme/app_text_style.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/avatar_cache.dart';
import '../../../data/services/auth_service.dart';
import '../../../data/services/local_storage.dart';
import '../../auth/auth_screen.dart';
import '../../widget/Common_header_withlogo.dart';
import '../../widget/common_bottom_sheet.dart';
import 'Payment_method.dart';
import 'default_settings_page.dart';
import 'edit_profile_photo_sheet.dart';
import 'help_support_page.dart';
import 'notification_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool isLoading = false;

  // Figma tokens (light); dark equivalents resolved below.
  static const Color _cardBgLight = Color(0xFFFAFAFA);
  static const Color _hairlineLight = Color(0xFFF4F4F5);
  static const Color _innerBgLight = Color(0xFFFFFFFF);
  static const Color _textPrimaryLight = Color(0xFF09090B);
  static const Color _textBodyLight = Color(0xFF3F3F46);
  static const Color _textMutedLight = Color(0xFF52525B);
  static const Color _avatarRing = Color(0xFFD9ADFF);

  Color _cardBg(BuildContext c) => Theme.of(c).brightness == Brightness.dark
      ? const Color(0xFF1C1C1E)
      : _cardBgLight;

  Color _hairline(BuildContext c) => Theme.of(c).brightness == Brightness.dark
      ? Colors.grey.shade800
      : _hairlineLight;

  Color _innerBg(BuildContext c) => Theme.of(c).brightness == Brightness.dark
      ? const Color(0xFF2A2A2A)
      : _innerBgLight;

  Color _textPrimary(BuildContext c) =>
      Theme.of(c).brightness == Brightness.dark
          ? Colors.white
          : _textPrimaryLight;

  Color _textBody(BuildContext c) => Theme.of(c).brightness == Brightness.dark
      ? Colors.grey.shade300
      : _textBodyLight;

  Color _textMuted(BuildContext c) => Theme.of(c).brightness == Brightness.dark
      ? Colors.grey.shade400
      : _textMutedLight;

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
      debugPrint("Logout server call failed (continuing local cleanup): $e");
    } finally {
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
      appBar: GlobalAppBar(),
      body: Consumer<ProfileProvider>(
        builder: (context, provider, child) {
          final profile = provider.profile;
          return RefreshIndicator(
            color: AppColors.primary,
            backgroundColor: AppColors.whiteDynamic(context),
            onRefresh: () async {
              await provider.fetchProfile();
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: ClampingScrollPhysics(),
              ),
              child: Padding(
                padding: EdgeInsets.fromLTRB(16.w, 20.h, 16.w, 20.h),
                child: Column(
                  children: [
                    _buildProfileCard(context, profile, provider.isLoading),
                    SizedBox(height: 16.h),
                    _buildAchievementsCard(context, provider.achievements),
                    SizedBox(height: 16.h),
                    _buildSettingsCard(context),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _openEditPhoto() {
    CommonBottomSheet.open(
      context: context,
      fixed: true,
      builder: (controller) =>
          EditProfilePhotoSheet(scrollController: controller),
    );
  }

  Widget _buildProfileCard(
    BuildContext context,
    dynamic profile,
    bool loading,
  ) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: _cardBg(context),
        border: Border.all(color: _hairline(context), width: 1),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: _openEditPhoto,
            behavior: HitTestBehavior.opaque,
            child: Container(
              width: 84.w,
              height: 84.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: _avatarRing, width: 4),
              ),
              child: Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CircleAvatar(
                      radius: 38.r,
                      backgroundColor: AppColors.iconContainerDynamic(context),
                      backgroundImage: profile?.avatar.isNotEmpty == true
                          ? CachedNetworkImageProvider(AvatarCache.bust(profile.avatar)!)
                          : null,
                      child: profile?.avatar.isEmpty ?? true
                          ? Icon(Icons.person,
                              size: 30.sp,
                              color: AppColors.textSecondaryDynamic(context))
                          : null,
                    ),
                    Container(
                      width: 76.w,
                      height: 76.w,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.black.withValues(alpha: 0.30),
                      ),
                      child: Icon(
                        LucideIcons.pencil,
                        size: 20.sp,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            loading
                ? "Loading..."
                : profile != null
                    ? "${profile.firstName} ${profile.lastName}"
                    : "No Name",
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.w600,
              color: _textPrimary(context),
              fontFamily: AppTextStyle.fontFamily,
            ),
          ),
          if (profile?.email != null && profile.email!.isNotEmpty) ...[
            SizedBox(height: 4.h),
          ],
          SizedBox(height: 12.h),
          Row(
            children: [
              Expanded(
                child: _buildStat(
                    context, "${profile?.winRate ?? 0}%", "Win Rate")),
              SizedBox(width: 4.w),
              Expanded(
                child: _buildStat(
                    context,
                    _formatGhs(_statDouble(profile?.totalEarnedGhs)),
                    "Total Earned")),
              SizedBox(width: 4.w),
              Expanded(
                child: _buildStat(
                    context, "${profile?.totalTrades ?? 0}", "Total Trades")),
            ],
          ),
        ],
      ),
    );
  }

  double _statDouble(dynamic v) => v is num ? v.toDouble() : 0.0;
  String _formatGhs(double v) {
    final neg = v < 0;
    final a = v.abs();
    String body;
    if (a >= 1000000) {
      final m = a / 1000000;
      body = '${m == m.roundToDouble() ? m.toStringAsFixed(0) : m.toStringAsFixed(1)}M';
    } else if (a >= 1000) {
      final k = a / 1000;
      body = '${k == k.roundToDouble() ? k.toStringAsFixed(0) : k.toStringAsFixed(1)}K';
    } else {
      body = a == a.roundToDouble() ? a.toStringAsFixed(0) : a.toStringAsFixed(2);
    }
    return '${neg ? '-' : ''}₵$body';
  }

  Widget _buildStat(BuildContext context, String value, String label) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 16.h),
      decoration: BoxDecoration(
        color: _innerBg(context),
        border: Border.all(color: _hairline(context), width: 1),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: _textPrimary(context),
              fontFamily: AppTextStyle.fontFamily,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            label,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w400,
              color: _textBody(context),
              fontFamily: AppTextStyle.fontFamily,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementsCard(BuildContext context, List<AchievementModel> achievements) {
    return GestureDetector(
      onTap: () {
        CommonBottomSheet.open(
          context: context,
          fixed: true,
          builder: (controller) =>
              AchievementsSheet(scrollController: controller),
        );
      },
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: _cardBg(context),
          border: Border.all(color: _hairline(context), width: 1),
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Achievements",
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: _textMuted(context),
                    fontFamily: AppTextStyle.fontFamily,
                  ),
                ),
                Icon(Icons.arrow_forward_ios,
                    size: 14.sp, color: _textMuted(context)),
              ],
            ),
            SizedBox(height: 16.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                for (final a in achievements.take(4)) _buildBadge(context, a),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBadge(BuildContext context, AchievementModel a) {
    const gold = Color(0xFFF59E0B);
    return Container(
      width: 64.w,
      height: 64.w,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: a.earned ? gold.withValues(alpha: 0.12) : _innerBg(context),
        border: Border.all(
          color: a.earned ? gold : _hairline(context),
          width: 1.5,
        ),
      ),
      child: ClipOval(child: _badgeArt(a)),
    );
  }

  Widget _badgeArt(AchievementModel a) {
    final Widget art = SvgPicture.asset(
      _badgeAsset(a),
      width: 64.w,
      height: 64.w,
      fit: BoxFit.cover,
    );
    if (a.earned) return art;
    return ImageFiltered(
      imageFilter: ui.ImageFilter.blur(sigmaX:0, sigmaY:0),
      child: art,
    );
  }
  static String _badgeAsset(AchievementModel a) {
    final k = '${a.key} ${a.name}'.toLowerCase();
    if (k.contains('win')) return 'assets/svgs/firstwin.svg';
    if (k.contains('trade')) return 'assets/svgs/firsttrade.svg';
    return 'assets/svgs/firstdeposite.svg';
  }

  Widget _buildSettingsCard(BuildContext context) {
    final rows = <Widget>[
      _buildSettingsRowSvg(
        context,
        "assets/svgs/User.svg",
        "Personal Info",
        () => CommonBottomSheet.open(
          context: context,
          builder: (c) => EditProfile(scrollController: c),
        ),
      ),
      _buildSettingsRowSvg(
        context,
        "assets/svgs/Wallet.svg",
        "Payment Methods",
        () => CommonBottomSheet.open(
          context: context,
          builder: (c) => PaymentMethodsPage(scrollController: c),
        ),
      ),
      _buildSettingsRow(
        context,
        LucideIcons.settings,
        "Default Settings",
        () => CommonBottomSheet.open(
          context: context,
          builder: (c) => DefaultSettingsPage(scrollController: c),
        ),
      ),
      _buildSettingsRowSvg(
        context,
        "assets/svgs/Bell.svg",
        "Notification Preferences",
        () => CommonBottomSheet.open(
          context: context,
          // Figma scrim — #00000052
          barrierColor: const Color(0x52000000),
          builder: (c) => NotificationPreferencesPage(scrollController: c),
        ),
      ),
      _buildSettingsRow(
        context,
        LucideIcons.shieldCheck,
        "Privacy Policy",
        () => CommonBottomSheet.open(
          context: context,
          builder: (c) => PrivacyPolicyPage(scrollController: c),
        ),
      ),
      _buildSettingsRowSvg(
        context,
        "assets/svgs/Document.svg",
        "Terms of Service",
        () => CommonBottomSheet.open(
          context: context,
          builder: (c) => TermsOfServicePage(scrollController: c),
        ),
      ),
      _buildSettingsRow(
        context,
        LucideIcons.logOut,
        "Log Out",
        showLogoutDialog,
      ),
    ];

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: _cardBg(context),
        border: Border.all(color: _hairline(context), width: 1),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Column(
        children: [
          for (int i = 0; i < rows.length; i++) ...[
            rows[i],
            if (i != rows.length - 1) SizedBox(height: 20.h),
          ],
        ],
      ),
    );
  }

  Widget _buildSettingsRow(
    BuildContext context,
    IconData icon,
    String title,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Row(
        children: [
          _iconBox(context, icon),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w400,
                color: _textBody(context),
                fontFamily: AppTextStyle.fontFamily,
              ),
            ),
          ),
          Icon(
            Icons.arrow_forward_ios,
            size: 14.sp,
            color: _textMuted(context),
          ),
        ],
      ),
    );
  }

  Widget _iconBox(BuildContext context, IconData icon) {
    return Container(
      height: 40.h,
      width: 40.w,
      decoration: BoxDecoration(
        color: _innerBg(context),
        border: Border.all(color: _hairline(context), width: 1),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Icon(
        icon,
        size: 22.sp,
        color: _textMuted(context),
      ),
    );
  }

  Widget _iconBoxSvg(BuildContext context, String asset) {
    return Container(
      height: 40.h,
      width: 40.w,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: _innerBg(context),
        border: Border.all(color: _hairline(context), width: 1),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: SvgPicture.asset(
        asset,
        width: 22.sp,
        height: 22.sp,
        colorFilter: ColorFilter.mode(_textMuted(context), BlendMode.srcIn),
      ),
    );
  }

  Widget _buildSettingsRowSvg(
    BuildContext context,
    String svgAsset,
    String title,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Row(
        children: [
          _iconBoxSvg(context, svgAsset),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w400,
                color: _textBody(context),
                fontFamily: AppTextStyle.fontFamily,
              ),
            ),
          ),
          Icon(
            Icons.arrow_forward_ios,
            size: 14.sp,
            color: _textMuted(context),
          ),
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

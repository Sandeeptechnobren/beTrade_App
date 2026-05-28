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
  bool isLoading = false;

  // Figma tokens (light); dark equivalents resolved below.
  static const Color _cardBgLight = Color(0xFFFAFAFA);
  static const Color _hairlineLight = Color(0xFFF4F4F5);
  static const Color _innerBgLight = Color(0xFFFFFFFF);
  static const Color _textPrimaryLight = Color(0xFF09090B);
  static const Color _textBodyLight = Color(0xFF3F3F46);
  static const Color _textMutedLight = Color(0xFF52525B);
  static const Color _avatarRing = Color(0xFFD9ADFF);
  static const Color _switchTrackOff = Color(0xFFE4E4E7);

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
                parent: BouncingScrollPhysics(),
              ),
              child: Padding(
                padding: EdgeInsets.fromLTRB(16.w, 20.h, 16.w, 20.h),
                child: Column(
                  children: [
                    _buildProfileCard(context, profile, provider.isLoading),
                    SizedBox(height: 16.h),
                    _buildAchievementsCard(context),
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
          Container(
            width: 84.w,
            height: 84.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: _avatarRing, width: 4),
            ),
            child: Center(
              child: CircleAvatar(
                radius: 38.r,
                backgroundColor: Colors.grey.shade200,
                backgroundImage: profile?.avatar.isNotEmpty == true
                    ? NetworkImage(profile.avatar)
                    : null,
                child: profile?.avatar.isEmpty ?? true
                    ? Icon(Icons.person, size: 30.sp, color: Colors.grey)
                    : null,
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
              Expanded(child: _buildStat(context, "62%", "Win Rate")),
              SizedBox(width: 4.w),
              Expanded(child: _buildStat(context, "€2.3k", "Total Earned")),
              SizedBox(width: 4.w),
              Expanded(child: _buildStat(context, "324", "Total Trades")),
            ],
          ),
        ],
      ),
    );
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

  Widget _buildAchievementsCard(BuildContext context) {
    return GestureDetector(
      onTap: () {
        CommonBottomSheet.open(
          context: context,
          // Sized to Figma sheet (376px) — content is header + 2 badge
          // rows, so a 0.5 fraction keeps the sheet tight to the content
          // instead of leaving a large empty band underneath.
          initialChildSize: 0.5,
          minChildSize: 0.45,
          maxChildSize: 0.55,
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
                _buildBadge(context, "assets/images/Archivement (1).png"),
                _buildBadge(context, "assets/images/Archivement (3).png"),
                _buildBadge(context, "assets/images/Archivement (2).png"),
                _buildBadge(context, "assets/images/Archivement (2).png"),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBadge(BuildContext context, String imagePath) {
    return Container(
      width: 64.w,
      height: 64.w,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: _hairline(context), width: 1),
        image: DecorationImage(
          image: AssetImage(imagePath),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildSettingsCard(BuildContext context) {
    final rows = <Widget>[
      _buildDarkModeRow(context),
      _buildSettingsRow(
        context,
        LucideIcons.user,
        "Personal Info",
        () => CommonBottomSheet.open(
          context: context,
          builder: (c) => EditProfile(scrollController: c),
        ),
      ),
      _buildSettingsRow(
        context,
        LucideIcons.wallet,
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
      _buildSettingsRow(
        context,
        LucideIcons.bell,
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
      _buildSettingsRow(
        context,
        LucideIcons.fileText,
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

  Widget _buildDarkModeRow(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Row(
      children: [
        _iconBox(context, LucideIcons.moon),
        SizedBox(width: 8.w),
        Expanded(
          child: Text(
            "Dark Mode",
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w400,
              color: _textBody(context),
              fontFamily: AppTextStyle.fontFamily,
            ),
          ),
        ),
        _FigmaSwitch(
          value: themeProvider.isDark,
          trackOff: _switchTrackOff,
          trackOn: AppColors.primary,
          onChanged: (v) => themeProvider.toggleTheme(v),
        ),
      ],
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

// Figma switch — 57x32 track, 24x24 white thumb. Mirrors Frame 1171276422.
class _FigmaSwitch extends StatelessWidget {
  const _FigmaSwitch({
    required this.value,
    required this.onChanged,
    required this.trackOff,
    required this.trackOn,
  });

  final bool value;
  final ValueChanged<bool> onChanged;
  final Color trackOff;
  final Color trackOn;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        width: 57.w,
        height: 32.h,
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
          color: value ? trackOn : trackOff,
          borderRadius: BorderRadius.circular(9999),
        ),
        child: Row(
          mainAxisAlignment:
              value ? MainAxisAlignment.end : MainAxisAlignment.start,
          children: [
            Container(
              width: 24.w,
              height: 24.h,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

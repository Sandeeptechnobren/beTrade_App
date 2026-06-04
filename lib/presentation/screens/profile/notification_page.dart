import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/model/profile_notification_preferences_model.dart';
import '../../../data/services/profile_notification_service.dart';
import '../../widget/common_header.dart';
import '../../widget/customSnackBar.dart';

/// Notification Preferences sheet — Figma `Profile - 04`.
///
/// Three cards (Discover & Trends / Your Trades / Wallet Activity),
/// each carrying labelled toggle rows that talk to
/// `NotificationService.updatePreference`. Toggles are optimistic:
/// the UI flips immediately, the PUT fires in the background, and we
/// roll back + snackbar on failure.
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
  // Figma tokens
  static const Color _switchOn = Color(0xFF6D14B5);

  bool _isLoading = true;
  List<NotificationSection> _sections = const [];

  @override
  void initState() {
    super.initState();
    _fetchPreferences();
  }

  Future<void> _fetchPreferences() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    final fetched = await NotificationService.getPreferences();
    if (!mounted) return;
    setState(() {
      _sections = fetched;
      _isLoading = false;
    });
  }

  Future<void> _toggleItem(
    int sectionIdx,
    int itemIdx,
    bool value,
  ) async {
    if (!mounted) return;

    final item = _sections[sectionIdx].items[itemIdx];
    final previousValue = item.isActive;

    // 1. Optimistic UI update — flip the switch immediately.
    _applyToggle(sectionIdx, itemIdx, value);

    // 2. PUT /notificationPreferences with {title, status}.
    final ok = await NotificationService.updatePreference(
      title: item.title,
      isActive: value,
    );

    if (!mounted) return;

    if (!ok) {
      // Backend rejected → revert + warn.
      _applyToggle(sectionIdx, itemIdx, previousValue);
      CustomSnackBar.showError(
        context,
        message: "Failed to update notification setting",
        duration: const Duration(seconds: 3),
      );
      return;
    }

    // PUT succeeded — trust the backend. Deliberately no refetch here;
    // the optimistic update IS the persisted state. Cross-session
    // persistence relies on backend actually saving the change.
  }

  void _applyToggle(int sectionIdx, int itemIdx, bool value) {
    if (!mounted) return;
    setState(() {
      final section = _sections[sectionIdx];
      final newItems = List<NotificationItem>.from(section.items);
      newItems[itemIdx] = newItems[itemIdx].copyWith(isActive: value);
      _sections = List<NotificationSection>.from(_sections)
        ..[sectionIdx] = NotificationSection(
          section: section.section,
          items: newItems,
        );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cardBackgroundDynamic(context),
      body: SafeArea(
        child: Column(
          children: [
            const CommonHeader(title: "Notification Preferences"),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : RefreshIndicator(
                      onRefresh: _fetchPreferences,
                      child: ListView.separated(
                        padding: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 24.h),
                        itemCount: _sections.length,
                        separatorBuilder: (_, __) => SizedBox(height: 16.h),
                        itemBuilder: (_, sectionIdx) {
                          return _buildSection(
                            _sections[sectionIdx],
                            sectionIdx,
                          );
                        },
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  /// Figma section card — `#FAFAFA` bg, 1px `#F4F4F5` border, 20 radius,
  /// 16 padding, gap 16 between section title and items.
  Widget _buildSection(NotificationSection section, int sectionIdx) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.cardBackgroundDynamic(context),
        border: Border.all(color: AppColors.borderDynamic(context), width: 1),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            section.section,
            style: TextStyle(
              fontFamily: 'SFProRounded',
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondaryDynamic(context),
            ),
          ),
          SizedBox(height: 16.h),
          for (int i = 0; i < section.items.length; i++) ...[
            _buildItem(section.items[i], sectionIdx, i),
            if (i < section.items.length - 1) SizedBox(height: 20.h),
          ],
        ],
      ),
    );
  }

  /// One toggle row — title 16/400/`#3F3F46` + subtitle 14/400/`#71717A`
  /// on the left, custom `_FigmaSwitch` on the right (57×32, `#6D14B5`
  /// track when on).
  Widget _buildItem(NotificationItem item, int sectionIdx, int itemIdx) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.title,
                style: TextStyle(
                  fontFamily: 'SFProRounded',
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textPrimaryDynamic(context),
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                item.description,
                style: TextStyle(
                  fontFamily: 'SFProRounded',
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textSecondaryDynamic(context),
                ),
              ),
            ],
          ),
        ),
        SizedBox(width: 12.w),
        _FigmaSwitch(
          value: item.isActive,
          onChanged: (v) => _toggleItem(sectionIdx, itemIdx, v),
          trackOn: _switchOn,
          trackOff: AppColors.borderDynamic(context),
        ),
      ],
    );
  }
}

/// Figma switch — 57×32 track, 24×24 white thumb, radius 9999.
/// Mirrors the Frame 1171276422 spec used across the Figma.
class _FigmaSwitch extends StatelessWidget {
  const _FigmaSwitch({
    required this.value,
    required this.onChanged,
    required this.trackOn,
    required this.trackOff,
  });

  final bool value;
  final ValueChanged<bool> onChanged;
  final Color trackOn;
  final Color trackOff;

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

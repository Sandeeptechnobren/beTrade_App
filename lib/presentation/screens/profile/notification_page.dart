import 'package:betrade/core/theme/app_colors.dart';
import 'package:betrade/core/theme/app_text_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../data/model/notification_preferences_model.dart';
import '../../../data/services/notification_service.dart';
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

  /// Refetch silently — does NOT toggle the spinner. Used after a successful
  /// PUT to confirm the backend actually persisted the change without
  /// flashing a loading overlay over the whole list.
  Future<void> _silentRefetch() async {
    if (!mounted) return;
    final fetched = await NotificationService.getPreferences();
    if (!mounted) return;
    setState(() {
      _sections = fetched;
    });
  }

  Future<void> _toggleItem(
    int sectionIdx,
    int itemIdx,
    bool value,
  ) async {
    if (!mounted) return;

    final section = _sections[sectionIdx];
    final item = section.items[itemIdx];
    final previousValue = item.isActive;

    // 1. Optimistic UI update — flip the switch immediately so the user
    //    sees instant feedback.
    _applyToggle(sectionIdx, itemIdx, value);

    // 2. PUT /notificationPreferences with {title, status}.
    final ok = await NotificationService.updatePreference(
      title: item.title,
      isActive: value,
    );

    if (!mounted) return;

    if (!ok) {
      // Backend rejected or the request failed → revert + warn.
      _applyToggle(sectionIdx, itemIdx, previousValue);
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Failed to update notification setting"),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.all(12.w),
        ),
      );
      return;
    }

    // PUT succeeded — trust the backend. The optimistic UI update is now
    // the persisted state. We deliberately do NOT refetch here so the
    // toggle stays flipped within this screen session.
    //
    // NOTE: cross-session persistence (close + reopen the sheet) still
    // depends on the backend actually saving the change. If GET on the
    // next open returns the old status, that's a backend persistence bug
    // (PUT returns success but doesn't store the new state).
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
      // Sheet body — top-rounded 19.5 per Figma is handled by CommonBottomSheet's
      // ClipRRect; this Container just enforces the white inner surface and
      // the 8px padding from the spec.
      body: SafeArea(
        child: Column(
          children: [
            const CommonHeader(title: "Notification Preferences"),
            Expanded(
              child: Padding(
                // padding: 8px (Figma)
                padding: EdgeInsets.all(8.w),
                child: Column(
                  children: [
                    SizedBox(height: 12.h),
                    Expanded(
                      child: _isLoading
                          ? const Center(
                              child: CircularProgressIndicator(),
                            )
                          : RefreshIndicator(
                              onRefresh: _fetchPreferences,
                              child: ListView(
                                children: _sections
                                    .asMap()
                                    .entries
                                    .map((entry) {
                                  final sectionIdx = entry.key;
                                  final section = entry.value;
                                  return buildSection(
                                    title: section.section,
                                    items: section.items
                                        .asMap()
                                        .entries
                                        .map(
                                          (e) => buildItem(
                                            e.value.title,
                                            e.value.description,
                                            e.value.isActive,
                                            (val) => _toggleItem(
                                              sectionIdx,
                                              e.key,
                                              val,
                                            ),
                                          ),
                                        )
                                        .toList(),
                                  );
                                }).toList(),
                              ),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      // gap: 9.75px (Figma)
      margin: EdgeInsets.only(bottom: 9.75.h),
      padding: EdgeInsets.fromLTRB(12.w, 16.h, 12.w, 16.h),
      decoration: BoxDecoration(
        // Figma section card — soft neutral grey on white sheet
        color: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF5F5F7),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            // Same SFProRounded family as the sheet header; size tuned to fit a section heading.
            style: AppTextStyle.heading.copyWith(
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimaryDynamic(context),
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
                  style: AppTextStyle.body.copyWith(
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimaryDynamic(context),
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
            scale: 0.9,
            child: Switch(
              value: value,
              onChanged: onChanged,
              activeColor: Colors.white,
              activeTrackColor: const Color(0xFF7B2FF7),
              inactiveTrackColor: Colors.grey.shade300,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
        ],
      ),
    );
  }
}

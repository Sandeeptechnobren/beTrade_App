import 'package:betrade/core/theme/app_colors.dart';
import 'package:betrade/core/theme/app_text_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../widget/common_header.dart';

class DefaultSettingsPage extends StatefulWidget {
  const DefaultSettingsPage({
    super.key,
    required ScrollController scrollController,
  });

  @override
  State<DefaultSettingsPage> createState() => _DefaultSettingsPageState();
}

class _DefaultSettingsPageState extends State<DefaultSettingsPage> {
  // Hardcoded for now; wire to backend API later.
  late final TextEditingController _maxDefaultAmountController;
  late final TextEditingController _defaultAmountController;

  bool _exceedSnackbarShown = false;

  @override
  void initState() {
    super.initState();
    _maxDefaultAmountController = TextEditingController(text: "1000");
    _defaultAmountController = TextEditingController(text: "100");
    _defaultAmountController.addListener(_onDefaultAmountChanged);
  }

  @override
  void dispose() {
    _defaultAmountController.removeListener(_onDefaultAmountChanged);
    _maxDefaultAmountController.dispose();
    _defaultAmountController.dispose();
    super.dispose();
  }

  void _onDefaultAmountChanged() {
    if (!mounted) return;
    final defaultVal =
        int.tryParse(_defaultAmountController.text.trim()) ?? 0;
    final maxVal =
        int.tryParse(_maxDefaultAmountController.text.trim()) ?? 0;

    if (defaultVal > maxVal && maxVal > 0) {
      if (_exceedSnackbarShown) return;
      _exceedSnackbarShown = true;
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            "Cannot set default amount greater than max value",
          ),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.all(12.w),
        ),
      );
    } else {
      _exceedSnackbarShown = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const CommonHeader(title: "Default Settings"),
            Expanded(
              child: Padding(
                padding: EdgeInsets.fromLTRB(8.w, 0, 8.w, 8.w),
                child: Column(
                  children: [
                    SizedBox(height: 20.h),
                    Expanded(
                      child: ListView(
                        children: [
                          buildSection(
                            title: "Trade Amounts",
                            items: [
                              buildItem(
                                title: "Max Default Amount",
                                subtitle:
                                    "Upper limit applied by default to new trades",
                                controller: _maxDefaultAmountController,
                                enabled: false,
                              ),
                              buildItem(
                                title: "Default Amount",
                                subtitle:
                                    "Pre-filled amount when starting a new trade",
                                controller: _defaultAmountController,
                                enabled: true,
                              ),
                            ],
                          ),
                        ],
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
    return Container(
      margin: EdgeInsets.only(bottom: 9.75.h),
      padding: EdgeInsets.fromLTRB(14.w, 14.h, 14.w, 14.h),
      decoration: BoxDecoration(
        color: AppColors.inputFieldBgDynamic(context),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            // Same SFProRounded family as the sheet header.
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

  Widget buildItem({
    required String title,
    required String subtitle,
    required TextEditingController controller,
    required bool enabled,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyle.body.copyWith(
                    fontWeight: FontWeight.w500,
                    color: enabled
                        ? AppColors.textPrimaryDynamic(context)
                        : Colors.grey,
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
          SizedBox(width: 12.w),
          SizedBox(
            width: 80.w,
            child: TextField(
              controller: controller,
              enabled: enabled,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: enabled ? Colors.deepPurple : Colors.grey.shade400,
              ),
              decoration: InputDecoration(
                isDense: true,
                contentPadding: EdgeInsets.symmetric(
                  vertical: 8.h,
                  horizontal: 8.w,
                ),
                filled: true,
                fillColor: enabled
                    ? AppColors.inputFieldBgDynamic(context)
                    : Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.r),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.r),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                disabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.r),
                  borderSide: BorderSide(color: Colors.grey.shade200),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.r),
                  borderSide: BorderSide(color: Colors.deepPurple, width: 1.5),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

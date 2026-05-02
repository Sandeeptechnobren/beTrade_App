import 'package:betrade/core/theme/app_colors.dart';
import 'package:betrade/core/theme/app_text_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../../data/model/default_settings_model.dart';
import '../../../data/provider/default_amount_provider.dart';
import '../../../data/services/default_settings_service.dart';
import '../../widget/common_header.dart';
import '../../widget/purple_button.dart';

class DefaultSettingsPage extends StatefulWidget {
  const DefaultSettingsPage({
    super.key,
    required ScrollController scrollController,
  });
  @override
  State<DefaultSettingsPage> createState() => _DefaultSettingsPageState();
}

class _DefaultSettingsPageState extends State<DefaultSettingsPage> {
  late final TextEditingController _maxDefaultAmountController;
  late final TextEditingController _defaultAmountController;

  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _maxDefaultAmountController = TextEditingController();
    _defaultAmountController = TextEditingController();
    _fetchSettings();
  }

  @override
  void dispose() {
    _maxDefaultAmountController.dispose();
    _defaultAmountController.dispose();
    super.dispose();
  }

  Future<void> _fetchSettings() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    final settings = await DefaultSettingsService.getSettings();
    if (!mounted) return;
    _populateFromSettings(settings);
    setState(() => _isLoading = false);
  }

  void _populateFromSettings(DefaultSettingsModel? settings) {
    if (settings == null) return;
    _maxDefaultAmountController.text = settings.maxDefaultAmount.toString();
    _defaultAmountController.text = settings.minDefaultAmount.toString();
    context
        .read<DefaultAmountProvider>()
        .setDefaultAmount(settings.minDefaultAmount);
  }

  Future<void> _onSavePressed() async {
    if (_isSaving) return;
    FocusScope.of(context).unfocus();

    final defaultVal =
        int.tryParse(_defaultAmountController.text.trim()) ?? 0;
    final maxVal = int.tryParse(_maxDefaultAmountController.text.trim()) ?? 0;

    if (defaultVal <= 0) {
      _showSnack("Please enter a valid default amount");
      return;
    }
    if (maxVal > 0 && defaultVal > maxVal) {
      _showSnack("Cannot set default amount greater than max value");
      return;
    }

    setState(() => _isSaving = true);
    final ok = await DefaultSettingsService.updateDefaultAmount(defaultVal);
    if (!mounted) return;
    setState(() => _isSaving = false);

    if (ok) {
      context.read<DefaultAmountProvider>().setDefaultAmount(defaultVal);
      _showSnack("Default amount updated");
    } else {
      _showSnack("Failed to save default amount");
    }
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.all(12.w),
      ),
    );
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
                padding: EdgeInsets.fromLTRB(12.w, 0, 12.w, 8.w),
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : Column(
                        children: [
                          SizedBox(height: 20.h),
                          Expanded(
                            child: RefreshIndicator(
                              onRefresh: _fetchSettings,
                              child: ListView(
                                children: [
                                  buildSection(
                                    title: "Trade Amounts",
                                    items: [
                                      buildItem(
                                        title: "Max Default Amount",
                                        subtitle:
                                            "Upper limit applied by default to new trades",
                                        controller:
                                            _maxDefaultAmountController,
                                        enabled: false,
                                      ),
                                      buildItem(
                                        title: "Default Amount",
                                        subtitle:
                                            "Pre-filled amount when starting a new trade",
                                        controller:
                                            _defaultAmountController,
                                        enabled: true,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: 12.h),
                          Button(
                            title: "Save",
                            isLoading: _isSaving,
                            onPressed: _onSavePressed,
                          ),
                          SizedBox(height: 8.h),
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
      padding: EdgeInsets.fromLTRB(12.w, 14.h, 12.w, 14.h),
      decoration: BoxDecoration(
        color: AppColors.inputFieldBgDynamic(context),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
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

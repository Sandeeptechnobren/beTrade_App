import 'dart:async';

import 'package:betrade/core/theme/app_colors.dart';
import 'package:betrade/core/theme/app_text_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart';
import 'package:provider/provider.dart';

import '../../../data/model/default_settings_model.dart';
import '../../../data/provider/default_amount_provider.dart';
import '../../../data/services/default_settings_service.dart';
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
  late final TextEditingController _maxDefaultAmountController;
  late final TextEditingController _defaultAmountController;

  bool _exceedSnackbarShown = false;
  bool _isLoading = true;

  /// Last value successfully persisted via the PUT API. Used to skip
  /// redundant PUTs when the value hasn't actually changed.
  int? _lastSavedAmount;

  /// Debounce so we don't PUT on every keystroke.
  Timer? _amountDebounce;

  @override
  void initState() {
    super.initState();
    // Start blank — values populate from `/userDefaultSettings/list`.
    _maxDefaultAmountController = TextEditingController();
    _defaultAmountController = TextEditingController();
    _defaultAmountController.addListener(_onDefaultAmountChanged);
    _fetchSettings();
  }

  @override
  void dispose() {
    _amountDebounce?.cancel();
    _defaultAmountController.removeListener(_onDefaultAmountChanged);
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

  /// Refetch silently after a successful PUT — does NOT toggle the spinner.
  /// Confirms the backend's persisted state without disrupting the user's
  /// view of the form.
  Future<void> _silentRefetch() async {
    if (!mounted) return;
    final settings = await DefaultSettingsService.getSettings();
    if (!mounted) return;
    _populateFromSettings(settings);
  }

  /// Push the fetched settings into the controllers without triggering the
  /// `_onDefaultAmountChanged` listener (which would otherwise schedule a
  /// redundant PUT on a backend-side text update).
  void _populateFromSettings(DefaultSettingsModel? settings) {
    if (settings == null) return;
    _defaultAmountController.removeListener(_onDefaultAmountChanged);

    final newMax = settings.maxDefaultAmount.toString();
    if (_maxDefaultAmountController.text != newMax) {
      _maxDefaultAmountController.text = newMax;
    }
    final newMin = settings.minDefaultAmount.toString();
    if (_defaultAmountController.text != newMin) {
      _defaultAmountController.text = newMin;
    }
    _lastSavedAmount = settings.minDefaultAmount;

    // Sync the global provider so HomeScreen's swipe uses this value.
    final provider = context.read<DefaultAmountProvider>();
    provider.setDefaultAmount(settings.minDefaultAmount);

    _defaultAmountController.addListener(_onDefaultAmountChanged);
  }

  void _onDefaultAmountChanged() {
    if (!mounted) return;
    final defaultVal =
        int.tryParse(_defaultAmountController.text.trim()) ?? 0;
    final maxVal =
        int.tryParse(_maxDefaultAmountController.text.trim()) ?? 0;

    // 1. Validate: default must not exceed max (max is admin-controlled).
    if (defaultVal > maxVal && maxVal > 0) {
      _amountDebounce?.cancel();
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
      return;
    }
    _exceedSnackbarShown = false;

    // 2. Skip PUT for clearly-invalid input (empty / zero).
    if (defaultVal <= 0) {
      _amountDebounce?.cancel();
      return;
    }

    // 3. Skip PUT if value hasn't actually changed since last save.
    if (defaultVal == _lastSavedAmount) {
      _amountDebounce?.cancel();
      return;
    }

    // 4. Debounce 800ms then save → refetch.
    _amountDebounce?.cancel();
    _amountDebounce = Timer(
      const Duration(milliseconds: 800),
      () => _saveDefaultAmount(defaultVal),
    );
  }

  Future<void> _saveDefaultAmount(int amount) async {
    if (!mounted) return;
    final ok = await DefaultSettingsService.updateDefaultAmount(amount);
    if (!mounted) return;
    if (ok) {
      _lastSavedAmount = amount;
      // Refetch silently to confirm the backend's persisted state.
      final provider = context.read<DefaultAmountProvider>();
      provider.setDefaultAmount(amount);
      debugPrint("✅ Provider updated to: $amount");

      // await _silentRefetch();
    } else {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Failed to save default amount"),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.all(12.w),
        ),
      );
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
                padding: EdgeInsets.fromLTRB(12.w, 0, 12.w, 8.w),
                child: Column(
                  children: [
                    SizedBox(height: 20.h),
                    Expanded(
                      child: _isLoading
                          ? const Center(
                              child: CircularProgressIndicator(),
                            )
                          : RefreshIndicator(
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
                                        controller: _defaultAmountController,
                                        enabled: true,
                                      ),
                                    ],
                                  ),
                                ],
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

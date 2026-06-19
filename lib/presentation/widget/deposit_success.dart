import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../core/theme/app_colors.dart';
import '../screens/portfolio/deposit/saved_payment_methods.dart';
import 'common_bottom_sheet.dart';

const Color _primaryBg = Color(0xFF8E10FC);
void showSuccessDialog(BuildContext context) {
  showDialog<void>(
    context: context,
    barrierDismissible: false,
    barrierColor: Colors.black.withOpacity(0.32),
    builder: (dialogCtx) {
      return _FigmaSuccessDialog(
        title: 'Deposit Successful',
        body:
            'Your deposit has been completed successfully. You can save this '
            'payment method for faster transactions next time.',
        primaryLabel: 'Save Payment Method',
        onPrimary: () {
          final navContext =
              Navigator.of(dialogCtx, rootNavigator: true).context;
          Navigator.pop(dialogCtx);
          CommonBottomSheet.open(
            context: navContext,
            initialChildSize: 0.7,
            minChildSize: 0.5,
            maxChildSize: 0.85,
            builder: (controller) =>
                SavedPaymentMethodsSheet(scrollController: controller),
          );
        },
        secondaryLabel: 'Done',
        onSecondary: () => Navigator.pop(dialogCtx),
      );
    },
  );
}
void withdrawalSuccessDialog(BuildContext context) {
  showDialog<void>(
    context: context,
    barrierDismissible: false,
    barrierColor: Colors.black.withOpacity(0.32),
    builder: (dialogCtx) {
      return _FigmaSuccessDialog(
        title: 'Withdrawal Successful',
        body:
            'Your withdrawal was completed successfully. Please allow a few '
            'moments for the funds to appear in your account.',
        primaryLabel: 'Okay',
        onPrimary: () => Navigator.pop(dialogCtx),
      );
    },
  );
}

class _FigmaSuccessDialog extends StatelessWidget {
  const _FigmaSuccessDialog({
    required this.title,
    required this.body,
    required this.primaryLabel,
    required this.onPrimary,
    this.secondaryLabel,
    this.onSecondary,
  });

  final String title;
  final String body;
  final String primaryLabel;
  final VoidCallback onPrimary;
  final String? secondaryLabel;
  final VoidCallback? onSecondary;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(horizontal: 28.w),
      child: Container(
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: AppColors.cardBackgroundDynamic(context),
          borderRadius: BorderRadius.circular(32.r),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'SFProRounded',
                fontSize: 20.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimaryDynamic(context),
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              body,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'SFProRounded',
                fontSize: 16.sp,
                fontWeight: FontWeight.w400,
                color: AppColors.textSecondaryDynamic(context),
                height: 1.2,
              ),
            ),
            SizedBox(height: 20.h),
            _PrimaryPill(label: primaryLabel, onTap: onPrimary),
            if (secondaryLabel != null && onSecondary != null) ...[
              SizedBox(height: 12.h),
              _OutlinedPill(label: secondaryLabel!, onTap: onSecondary!),
            ],
          ],
        ),
      ),
    );
  }
}

class _PrimaryPill extends StatelessWidget {
  const _PrimaryPill({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 60.h,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: _primaryBg,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(32.r),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'SFProRounded',
            fontSize: 15.6.sp,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

class _OutlinedPill extends StatelessWidget {
  const _OutlinedPill({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 60.h,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          backgroundColor: AppColors.cardBackgroundDynamic(context),
          side: BorderSide(color: AppColors.borderDynamic(context), width: 1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(32.r),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'SFProRounded',
            fontSize: 15.6.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimaryDynamic(context),
          ),
        ),
      ),
    );
  }
}

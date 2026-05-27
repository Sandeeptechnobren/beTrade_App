import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../screens/portfolio/deposit/saved_payment_methods.dart';
import 'common_bottom_sheet.dart';

/// Figma success-dialog tokens (deposit + withdrawal share the look).
const Color _dialogBg = Color(0xFFFFFFFF);
const Color _titleColor = Color(0xFF09090B);
const Color _bodyColor = Color(0xFFA1A1AA);
const Color _primaryBg = Color(0xFF8E10FC);
const Color _outlineBorder = Color(0xFFE4E4E7);
const Color _outlineText = Color(0xFF18181B);

/// Deposit success → asks "Save Payment Method" (primary) or "Done".
///
/// Tapping **Save Payment Method** closes this dialog and opens the
/// `SavedPaymentMethodsSheet` (radio list + Add New + Confirm). Confirm
/// on that sheet drops the user back onto the portfolio.
///
/// Tapping **Done** just closes the dialog — the user is already on the
/// portfolio because `_submitDeposit` pops the deposit sheet first.
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
          // The original `context` from the caller (the deposit-page
          // State) is already detached by the time the user taps Save —
          // the deposit sheet was popped before showSuccessDialog ran.
          // Grab the dialog's root navigator instead; that one is
          // guaranteed alive while this dialog is on screen, and
          // survives the upcoming Navigator.pop(dialogCtx).
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

/// Withdrawal success — single "Okay" button (no save-method follow-up).
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
        // No secondary — withdrawal flow has only one CTA.
      );
    },
  );
}

/// Centered white-card success dialog matching Figma's
/// `Withdrawal Successful` / `Deposit Successful` frames.
///   - 32 radius, 20 padding, gap 20 between text block & buttons
///   - Title 20/600/#09090B, body 16/400/#A1A1AA centered
///   - Primary: 60-tall pill #8E10FC, text 15.6/700 white
///   - Secondary (optional): same pill but white bg + 1px #E4E4E7 border,
///     text 15.6/700 #18181B
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
          color: _dialogBg,
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
                color: _titleColor,
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
                color: _bodyColor,
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
          backgroundColor: Colors.white,
          side: const BorderSide(color: _outlineBorder, width: 1),
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
            color: _outlineText,
          ),
        ),
      ),
    );
  }
}

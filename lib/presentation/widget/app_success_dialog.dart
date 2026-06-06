import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../core/theme/app_colors.dart';

/// Standard full-screen success ceremony. Use for **important** wins:
///   - Deposit successful (with "Save Payment Method" secondary).
///   - Withdrawal submitted (single CTA).
///   - First trade / position closed for a profit.
///   - KYC submitted / approved.
///
/// Open via `AppNotify.successDialog(...)`. Small wins (profile saved,
/// avatar updated, notification toggled) should use `AppNotify.success`
/// instead — keep the dialog for moments worth celebrating.
///
/// Visual contract:
///   - Card: theme card bg, 32 r radius, 20 padding.
///   - Hero: 64 px circle with success-bg + 2 px success-border + check
///     icon (success-fg), centered.
///   - Title 20/600 / body 15/400 secondary, centered.
///   - Primary pill — 60 h, brand violet, white label 15.6/700.
///   - Optional secondary pill — same chrome, theme outline + text.
class AppSuccessDialog extends StatelessWidget {
  const AppSuccessDialog({
    super.key,
    required this.title,
    required this.body,
    required this.primaryText,
    required this.onPrimary,
    this.secondaryText,
    this.onSecondary,
  });

  final String title;
  final String body;
  final String primaryText;
  final VoidCallback onPrimary;
  final String? secondaryText;
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
            Container(
              width: 64.w,
              height: 64.w,
              decoration: BoxDecoration(
                color: AppColors.successBgDynamic(context),
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.successBorderDynamic(context),
                  width: 2,
                ),
              ),
              child: Icon(
                LucideIcons.check,
                color: AppColors.successFgDynamic(context),
                size: 32.sp,
              ),
            ),
            SizedBox(height: 16.h),
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
                fontSize: 15.sp,
                fontWeight: FontWeight.w400,
                color: AppColors.textSecondaryDynamic(context),
                height: 1.4,
              ),
            ),
            SizedBox(height: 20.h),
            SizedBox(
              width: double.infinity,
              height: 60.h,
              child: ElevatedButton(
                onPressed: onPrimary,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.electricViolet900,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(32.r),
                  ),
                ),
                child: Text(
                  primaryText,
                  style: TextStyle(
                    fontFamily: 'SFProRounded',
                    fontSize: 15.6.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            if (secondaryText != null && onSecondary != null) ...[
              SizedBox(height: 12.h),
              SizedBox(
                width: double.infinity,
                height: 60.h,
                child: OutlinedButton(
                  onPressed: onSecondary,
                  style: OutlinedButton.styleFrom(
                    backgroundColor:
                        AppColors.cardBackgroundDynamic(context),
                    side: BorderSide(
                        color: AppColors.borderDynamic(context), width: 1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(32.r),
                    ),
                  ),
                  child: Text(
                    secondaryText!,
                    style: TextStyle(
                      fontFamily: 'SFProRounded',
                      fontSize: 15.6.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimaryDynamic(context),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

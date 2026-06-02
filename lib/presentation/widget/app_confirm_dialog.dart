import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../core/theme/app_colors.dart';

/// Standard confirm dialog used app-wide for destructive + important
/// actions (logout, delete payment method, cancel deposit, etc.). Open
/// it via `AppNotify.confirm(...)`; that wrapper returns a `Future<bool>`
/// and feeds the result through `Navigator.pop`.
///
/// Visual contract:
///   - Card: theme card background, 28 r radius, 20 padding.
///   - Title 20/600 — body 15/400 secondary text, centered.
///   - Two equal-width pills, 52 h, 28 r:
///       • Cancel — outlined (border + theme text colour) on the LEFT.
///       • Confirm — filled, brand violet (or `btnRed` when destructive)
///         on the RIGHT. White label always.
///   - Button order matches iOS/Material convention (cancel left).
class AppConfirmDialog extends StatelessWidget {
  const AppConfirmDialog({
    super.key,
    required this.title,
    required this.body,
    this.confirmText = 'Confirm',
    this.cancelText = 'Cancel',
    this.destructive = false,
  });

  final String title;
  final String body;
  final String confirmText;
  final String cancelText;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    final confirmColor =
        destructive ? AppColors.btnRed : AppColors.electricViolet900;
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(horizontal: 28.w),
      child: Container(
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: AppColors.cardBackgroundDynamic(context),
          borderRadius: BorderRadius.circular(28.r),
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
            SizedBox(height: 10.h),
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
            SizedBox(height: 24.h),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 52.h,
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context, false),
                      style: OutlinedButton.styleFrom(
                        backgroundColor:
                            AppColors.cardBackgroundDynamic(context),
                        side: BorderSide(
                            color: AppColors.borderDynamic(context),
                            width: 1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28.r),
                        ),
                      ),
                      child: Text(
                        cancelText,
                        style: TextStyle(
                          fontFamily: 'SFProRounded',
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimaryDynamic(context),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: SizedBox(
                    height: 52.h,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: confirmColor,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28.r),
                        ),
                      ),
                      child: Text(
                        confirmText,
                        style: TextStyle(
                          fontFamily: 'SFProRounded',
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

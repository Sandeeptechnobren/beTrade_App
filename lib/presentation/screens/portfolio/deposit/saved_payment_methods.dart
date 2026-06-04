import 'package:betrade/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Bottom sheet shown after the user taps "Save Payment Method" in the
/// deposit success dialog. Lists previously-saved cards / mobile-money
/// numbers with a radio-selected primary one, plus an "Add New" CTA.
///
/// Confirm → closes the sheet → user is back on the portfolio.
/// Add New → closes the sheet (TODO: open the add-method flow when
///   the backend endpoint lands).
///
/// Mock data is used for now — the saved-methods backend isn't wired
/// in this branch. Swap `_mockMethods` for a provider read when ready.
class SavedPaymentMethodsSheet extends StatefulWidget {
  final ScrollController scrollController;
  const SavedPaymentMethodsSheet({super.key, required this.scrollController});

  @override
  State<SavedPaymentMethodsSheet> createState() =>
      _SavedPaymentMethodsSheetState();
}

class _SavedPaymentMethodsSheetState extends State<SavedPaymentMethodsSheet> {
  // Figma tokens (shared with New Deposit sheet)
  // Brand-purple tokens (kept hardcoded — same in light & dark).
  static const Color _stepProgress = Color(0xFF8E10FC);
  static const Color _btnPrimary = Color(0xFF8E10FC);

  // Mock saved methods — swap with provider data when backend lands.
  static const List<_SavedMethod> _mockMethods = [
    _SavedMethod(
      id: 'visa',
      brand: 'VISA',
      mask: '••••••856',
      kind: _MethodKind.visa,
    ),
    _SavedMethod(
      id: 'mastercard',
      brand: 'MasterCard',
      mask: '••••••856',
      kind: _MethodKind.mastercard,
    ),
    _SavedMethod(
      id: 'mtn',
      brand: 'MTN Mobile Money',
      mask: '••••••061',
      kind: _MethodKind.mtn,
    ),
  ];

  String _selectedId = 'visa';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cardBackgroundDynamic(context),
      body: Column(
        children: [
          _figmaHeader(),
          Expanded(
            child: SingleChildScrollView(
              controller: widget.scrollController,
              padding: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 24.h),
              child: Column(
                children: [
                  // Saved-methods panel
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.iconContainerDynamic(context),
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                    child: Column(
                      children: [
                        for (int i = 0; i < _mockMethods.length; i++) ...[
                          _methodRow(_mockMethods[i]),
                          if (i != _mockMethods.length - 1)
                            Divider(
                              height: 1,
                              thickness: 1,
                              color: AppColors.cardBackgroundDynamic(context),
                            ),
                        ],
                      ],
                    ),
                  ),
                  SizedBox(height: 12.h),
                  _addNewButton(),
                ],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 20.h),
            child: _confirmButton(),
          ),
        ],
      ),
    );
  }

  // ─── Header ───────────────────────────────────────────────────────

  Widget _figmaHeader() {
    return Container(
      padding: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 12.h),
      decoration: BoxDecoration(
        color: AppColors.cardBackgroundDynamic(context),
        border: Border(
          bottom: BorderSide(color: AppColors.borderDynamic(context), width: 1),
        ),
        borderRadius: BorderRadius.vertical(top: Radius.circular(31.r)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    height: 36.w,
                    width: 36.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.iconContainerDynamic(context),
                    ),
                    child: Icon(
                      Icons.arrow_back_ios_new,
                      size: 16.sp,
                      color: AppColors.textPrimaryDynamic(context),
                    ),
                  ),
                ),
                SizedBox(width: 16.w),
                Flexible(
                  child: Text(
                    'New Deposit',
                    style: TextStyle(
                      fontFamily: 'SFProRounded',
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimaryDynamic(context),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          // Step indicator shows "2" with a full ring — this view is
          // logically the payment-method step of the deposit flow.
          SizedBox(
            height: 36.w,
            width: 36.w,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.iconContainerDynamic(context),
                  ),
                ),
                SizedBox(
                  height: 36.w,
                  width: 36.w,
                  child: const CircularProgressIndicator(
                    value: 1.0,
                    strokeWidth: 3,
                    backgroundColor: Colors.transparent,
                    valueColor: AlwaysStoppedAnimation(_stepProgress),
                  ),
                ),
                Text(
                  '2',
                  style: TextStyle(
                    fontFamily: 'SFProRounded',
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimaryDynamic(context),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── Method row ───────────────────────────────────────────────────

  Widget _methodRow(_SavedMethod method) {
    final selected = _selectedId == method.id;
    return GestureDetector(
      onTap: () => setState(() => _selectedId = method.id),
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        child: Row(
          children: [
            _BrandBadge(kind: method.kind),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    method.brand,
                    style: TextStyle(
                      fontFamily: 'SFProRounded',
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimaryDynamic(context),
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    method.mask,
                    style: TextStyle(
                      fontFamily: 'SFProRounded',
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w400,
                      color: AppColors.textSecondaryDynamic(context),
                    ),
                  ),
                ],
              ),
            ),
            _radio(selected: selected),
          ],
        ),
      ),
    );
  }

  Widget _radio({required bool selected}) {
    return Container(
      width: 20.w,
      height: 20.w,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: selected ? _btnPrimary : AppColors.cardBackgroundDynamic(context),
        border: Border.all(
          color: selected ? _btnPrimary : AppColors.borderDynamic(context),
          width: 2,
        ),
      ),
      child: selected
          ? Icon(Icons.check, size: 12.sp, color: Colors.white)
          : null,
    );
  }

  // ─── Add New + Confirm ────────────────────────────────────────────

  Widget _addNewButton() {
    return GestureDetector(
      onTap: () {
        // TODO: open the add-method flow (re-uses step 2 of the deposit
        // page). For now close so the user isn't trapped.
        Navigator.pop(context);
      },
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 16.h),
        decoration: BoxDecoration(
          color: AppColors.iconContainerDynamic(context),
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_circle_outline,
                size: 18.sp, color: AppColors.textSecondaryDynamic(context)),
            SizedBox(width: 8.w),
            Text(
              'Add New',
              style: TextStyle(
                fontFamily: 'SFProRounded',
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondaryDynamic(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _confirmButton() {
    return GestureDetector(
      onTap: () {
        // TODO(backend): mark the selected method as default for next deposit.
        Navigator.pop(context); // back to portfolio
      },
      child: Container(
        height: 60.h,
        decoration: BoxDecoration(
          color: _btnPrimary,
          borderRadius: BorderRadius.circular(32.r),
        ),
        alignment: Alignment.center,
        child: Text(
          'Confirm',
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

// ─── Models + brand badge ───────────────────────────────────────────

enum _MethodKind { visa, mastercard, mtn }

class _SavedMethod {
  final String id;
  final String brand;
  final String mask;
  final _MethodKind kind;

  const _SavedMethod({
    required this.id,
    required this.brand,
    required this.mask,
    required this.kind,
  });
}

/// Placeholder brand badge — until real brand assets land, we paint a
/// small coloured pill carrying the brand initials. Matches the
/// Figma's visual rhythm without depending on logo files.
class _BrandBadge extends StatelessWidget {
  const _BrandBadge({required this.kind});
  final _MethodKind kind;

  @override
  Widget build(BuildContext context) {
    late final Color bg;
    late final Color fg;
    late final String label;
    switch (kind) {
      case _MethodKind.visa:
        bg = const Color(0xFF1A1F71); // VISA blue
        fg = Colors.white;
        label = 'VISA';
        break;
      case _MethodKind.mastercard:
        bg = const Color(0xFFEB001B); // MC red
        fg = Colors.white;
        label = 'MC';
        break;
      case _MethodKind.mtn:
        bg = const Color(0xFFFFCC00); // MTN yellow
        fg = const Color(0xFF09090B);
        label = 'MTN';
        break;
    }
    return Container(
      width: 44.w,
      height: 30.h,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(4.r),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: 'SFProRounded',
          fontSize: 10.sp,
          fontWeight: FontWeight.w800,
          color: fg,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

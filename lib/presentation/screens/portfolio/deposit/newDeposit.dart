import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../../../data/provider/wallet_provider.dart';
import '../../../widget/deposit_success.dart';
import '../../../widget/figma_inline_dropdown.dart';

class DepositPage extends StatefulWidget {
  final ScrollController scrollController;
  const DepositPage({super.key, required this.scrollController});

  @override
  State<DepositPage> createState() => _DepositPageState();
}

class _DepositPageState extends State<DepositPage> {
  static const Color _sheetBg = Color(0xFFFFFFFF);
  static const Color _hairline = Color(0xFFE4E4E7);
  static const Color _labelColor = Color(0xFF09090B);
  static const Color _inputBg = Color(0xFFF4F4F5);
  static const Color _inputText = Color(0xFF09090B);
  static const Color _hintColor = Color(0xFFA1A1AA);
  static const Color _stepChipBg = Color(0xFFF4F4F5);
  static const Color _stepProgress = Color(0xFF8E10FC);
  static const Color _btnPrimary = Color(0xFF8E10FC);
  static const Color _chevron = Color(0xFF1C274C);
  // Amount-chip tokens — light-purple fill + purple border when picked,
  // white + thin grey border otherwise. Text stays purple either way.
  static const Color _chipSelectedBg = Color(0xFFF3E6FF);
  static const Color _chipSelectedBorder = Color(0xFF8E10FC);
  static const Color _chipBorder = Color(0xFFE4E4E7);
  static const Color _chipText = Color(0xFF8E10FC);

  // Preset deposit amounts that mirror the Figma chip row.
  static const List<int> _amountPresets = [10, 20, 50, 100];

  // MoMo providers shown in the Payment Provider dropdown. Each entry
  // carries the brand label + asset path; the dropdown renders the
  // label + brand logo per Figma image 5. Save the brand PNGs at the
  // paths below to make the logos appear (the errorBuilder falls back
  // to a generic icon until then).
  static const List<_MomoProvider> _momoProviders = [
    _MomoProvider(
      id: 'mtn',
      name: 'MTN Mobile Money',
      asset: 'assets/images/mnt.png',
    ),
    _MomoProvider(
      id: 'telecel',
      name: 'Telecel Cash',
      asset: 'assets/images/telecel.png',
    ),
    _MomoProvider(
      id: 'airteltigo',
      name: 'AirtelTigo Money',
      asset: 'assets/images/airteltigo.png',
    ),
  ];

  int step = 1;

  final TextEditingController amountController = TextEditingController();
  String paymentMethod = "card";
  final TextEditingController cardNumber = TextEditingController();
  final TextEditingController expiry = TextEditingController();
  final TextEditingController cvc = TextEditingController();
  final TextEditingController phone = TextEditingController();
  String provider = "";

  @override
  void initState() {
    super.initState();
    // Listener flips the Continue button between disabled/enabled state
    // as the user types — matches Figma's #8E10FC opacity 0.5 → 1 swap.
    amountController.addListener(_rebuildOnInput);
    cardNumber.addListener(_rebuildOnInput);
    expiry.addListener(_rebuildOnInput);
    cvc.addListener(_rebuildOnInput);
    phone.addListener(_rebuildOnInput);
  }

  @override
  void dispose() {
    amountController.dispose();
    cardNumber.dispose();
    expiry.dispose();
    cvc.dispose();
    phone.dispose();
    super.dispose();
  }

  void _rebuildOnInput() {
    if (mounted) setState(() {});
  }

  bool get _step1Valid {
    final amount = double.tryParse(amountController.text.trim()) ?? 0;
    return amount > 0;
  }

  bool get _step2Valid {
    if (paymentMethod == 'card') {
      return cardNumber.text.trim().isNotEmpty &&
          expiry.text.trim().isNotEmpty &&
          cvc.text.trim().isNotEmpty;
    }
    if (paymentMethod == 'momo') {
      return provider.isNotEmpty && phone.text.trim().isNotEmpty;
    }
    // Bank Account flow isn't wired yet — keep Confirm disabled so
    // tapping it doesn't fire a half-built request.
    return false;
  }

  void _handleBack() {
    if (step == 2) {
      setState(() => step = 1);
    } else {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _sheetBg,
      body: Column(
        children: [
          _figmaHeader(),
          Expanded(
            child: SingleChildScrollView(
              controller: widget.scrollController,
              padding: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 24.h),
              child: step == 1 ? _step1Body() : _step2Body(),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 20.h),
            child: step == 1
                ? _figmaButton(
                    'Continue',
                    enabled: _step1Valid,
                    onTap: () => setState(() => step = 2),
                  )
                : Consumer<WalletProvider>(
                    builder: (context, wallet, _) {
                      return _figmaButton(
                        'Confirm',
                        enabled: _step2Valid && !wallet.isSubmittingDeposit,
                        loading: wallet.isSubmittingDeposit,
                        onTap: _submitDeposit,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  // ─── Header (Figma Frame 2609862) ─────────────────────────────────

  Widget _figmaHeader() {
    return Container(
      padding: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 12.h),
      decoration: BoxDecoration(
        color: _sheetBg,
        border: const Border(
          bottom: BorderSide(color: _hairline, width: 1),
        ),
        borderRadius: BorderRadius.vertical(top: Radius.circular(31.r)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Row(
              children: [
                GestureDetector(
                  onTap: _handleBack,
                  child: Container(
                    height: 36.w,
                    width: 36.w,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: _stepChipBg,
                    ),
                    child: Icon(
                      Icons.arrow_back_ios_new,
                      size: 16.sp,
                      color: _chevron,
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
                      color: _labelColor,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          _stepIndicator(),
        ],
      ),
    );
  }

  /// 36×36 chip with a circular progress arc (#8E10FC) overlaying a
  /// grey base (#F4F4F5) plus the current step number in the middle —
  /// mirrors the Figma "Progress" frame.
  Widget _stepIndicator() {
    return SizedBox(
      height: 36.w,
      width: 36.w,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: _stepChipBg,
            ),
          ),
          SizedBox(
            height: 36.w,
            width: 36.w,
            child: CircularProgressIndicator(
              value: step / 2,
              strokeWidth: 3,
              backgroundColor: Colors.transparent,
              valueColor: const AlwaysStoppedAnimation(_stepProgress),
            ),
          ),
          Text(
            '$step',
            style: TextStyle(
              fontFamily: 'SFProRounded',
              fontSize: 15.sp,
              fontWeight: FontWeight.w500,
              color: _labelColor,
            ),
          ),
        ],
      ),
    );
  }

  // ─── Step 1 — Amount ──────────────────────────────────────────────

  Widget _step1Body() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label('Amount'),
        SizedBox(height: 12.h),
        _figmaInput(
          amountController,
          '0.00',
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
        ),
        SizedBox(height: 16.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: _amountPresets
              .map((amt) => _amountChip(amt))
              .toList(growable: false),
        ),
      ],
    );
  }

  /// Outlined pill that fills with light purple + purple border when its
  /// value matches the current amount input. Tapping pushes the value
  /// into the input (the listener then re-renders the chip selected).
  Widget _amountChip(int amount) {
    final selected = amountController.text.trim() == amount.toString();
    return GestureDetector(
      onTap: () {
        amountController.text = amount.toString();
        amountController.selection = TextSelection.collapsed(
          offset: amountController.text.length,
        );
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: selected ? _chipSelectedBg : Colors.white,
          border: Border.all(
            color: selected ? _chipSelectedBorder : _chipBorder,
            width: 1,
          ),
          borderRadius: BorderRadius.circular(9999),
        ),
        child: Text(
          '$amount GHS',
          style: TextStyle(
            fontFamily: 'SFProRounded',
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: _chipText,
          ),
        ),
      ),
    );
  }

  // ─── Step 2 — Payment ─────────────────────────────────────────────

  Widget _step2Body() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label('Payment Method'),
        SizedBox(height: 12.h),
        FigmaInlineDropdown<String>(
          value: paymentMethod,
          items: const [
            FigmaInlineDropdownItem(
                value: 'card', label: 'Debit/Credit Card'),
            FigmaInlineDropdownItem(value: 'momo', label: 'Mobile Money'),
            FigmaInlineDropdownItem(value: 'bank', label: 'Bank Account'),
          ],
          onChanged: (v) => setState(() => paymentMethod = v),
        ),
        SizedBox(height: 23.h),
        if (paymentMethod == 'card')
          ..._cardFields()
        else if (paymentMethod == 'momo')
          ..._momoFields()
        else
          ..._bankPlaceholder(),
      ],
    );
  }

  /// Stub UI for Bank Account — the form fields aren't in the Figma
  /// yet. Confirm stays disabled (see `_step2Valid`).
  List<Widget> _bankPlaceholder() {
    return [
      Container(
        width: double.infinity,
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: _inputBg,
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Text(
          'Bank Account deposits coming soon.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'SFProRounded',
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: _hintColor,
          ),
        ),
      ),
    ];
  }

  List<Widget> _cardFields() {
    return [
      _label('Card Number'),
      SizedBox(height: 12.h),
      _figmaInput(cardNumber, '0000 0000 0000 0000'),
      SizedBox(height: 23.h),
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _label('Expiry Date'),
                SizedBox(height: 12.h),
                _figmaInput(expiry, 'MM/YY'),
              ],
            ),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _label('CVC'),
                SizedBox(height: 12.h),
                _figmaInput(cvc, '000', keyboardType: TextInputType.number),
              ],
            ),
          ),
        ],
      ),
    ];
  }

  List<Widget> _momoFields() {
    return [
      _label('Payment Provider'),
      SizedBox(height: 12.h),
      FigmaInlineDropdown<String>(
        value: provider.isEmpty ? null : provider,
        hint: 'Select an option',
        items: _momoProviders.map((p) {
          return FigmaInlineDropdownItem<String>(
            value: p.id,
            label: p.name,
            // Brand logo (42×28) on the right of each item, with a
            // generic-phone fallback if the asset isn't on disk yet.
            trailing: Image.asset(
              p.asset,
              width: 42.w,
              height: 28.h,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => Icon(
                Icons.phone_android,
                size: 18.sp,
                color: _hintColor,
              ),
            ),
          );
        }).toList(),
        onChanged: (v) => setState(() => provider = v),
      ),
      SizedBox(height: 23.h),
      _label('Phone Number'),
      SizedBox(height: 12.h),
      _figmaInput(phone, '000 000 0000', keyboardType: TextInputType.phone),
    ];
  }

  // ─── Shared atoms ─────────────────────────────────────────────────

  Widget _label(String text) => Text(
        text,
        style: TextStyle(
          fontFamily: 'SFProRounded',
          fontSize: 16.sp,
          fontWeight: FontWeight.w600,
          color: _labelColor,
        ),
      );

  /// Figma input box — 62 height, padding 20/24, #F4F4F5 bg, 16 radius.
  Widget _figmaInput(
    TextEditingController controller,
    String hint, {
    TextInputType? keyboardType,
  }) {
    return Container(
      height: 62.h,
      decoration: BoxDecoration(
        color: _inputBg,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: TextStyle(
          fontFamily: 'SFProRounded',
          fontSize: 16.sp,
          fontWeight: FontWeight.w500,
          color: _inputText,
        ),
        decoration: InputDecoration(
          border: InputBorder.none,
          isCollapsed: true,
          hintText: hint,
          hintStyle: TextStyle(
            fontFamily: 'SFProRounded',
            fontSize: 16.sp,
            fontWeight: FontWeight.w500,
            color: _hintColor,
          ),
          contentPadding:
              EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
        ),
      ),
    );
  }

  /// Figma primary button — 60 tall, 32 radius, #8E10FC; the disabled
  /// variant drops to opacity 0.5 (matches the Continue button in Figma
  /// step 1 when amount is empty). [loading] swaps the label for a
  /// small white spinner (matches Confirm in the "Submitting" Figma
  /// frame).
  Widget _figmaButton(
    String text, {
    required bool enabled,
    required VoidCallback onTap,
    bool loading = false,
  }) {
    return GestureDetector(
      onTap: enabled && !loading ? onTap : null,
      child: Container(
        height: 60.h,
        decoration: BoxDecoration(
          color: enabled ? _btnPrimary : _btnPrimary.withOpacity(0.5),
          borderRadius: BorderRadius.circular(32.r),
        ),
        alignment: Alignment.center,
        child: loading
            ? SizedBox(
                height: 22.h,
                width: 22.h,
                child: const CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Colors.white,
                ),
              )
            : Text(
                text,
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

  // ─── Submit ───────────────────────────────────────────────────────

  /// Submit the deposit intent via WalletProvider.
  /// Shows success dialog on success, snackbar with backend message
  /// on failure (e.g. BELOW_MIN_AMOUNT, ABOVE_MAX_AMOUNT).
  Future<void> _submitDeposit() async {
    final wallet = context.read<WalletProvider>();
    final messenger = ScaffoldMessenger.of(context);

    final amount = double.tryParse(amountController.text.trim()) ?? 0;
    if (amount <= 0) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Please enter an amount.')),
      );
      return;
    }

    final method = paymentMethod == 'card' ? 'card' : 'mobile_money';
    final msisdn = paymentMethod == 'momo' ? phone.text.trim() : null;

    final ok = await wallet.submitDeposit(
      amountGhs: amount,
      method: method,
      msisdn: msisdn,
    );

    if (!mounted) return;

    if (ok) {
      Navigator.pop(context);
      await Future.delayed(const Duration(milliseconds: 200));
      if (!mounted) return;
      showSuccessDialog(context);
    } else {
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            wallet.lastSubmitMessage ?? 'Could not submit deposit.',
          ),
        ),
      );
    }
  }
}

/// One MoMo provider option for the Payment Provider dropdown.
class _MomoProvider {
  final String id;
  final String name;
  final String asset;

  const _MomoProvider({
    required this.id,
    required this.name,
    required this.asset,
  });
}

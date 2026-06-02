import 'package:betrade/core/utils/app_notify.dart';
import 'package:betrade/core/utils/idempotency.dart';
import 'package:betrade/core/utils/money.dart';
import 'package:betrade/presentation/widget/customSnackBar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../../../data/provider/wallet_provider.dart';
import '../../../widget/deposit_success.dart';
import '../../../widget/figma_inline_dropdown.dart';

class WithdrawPage extends StatefulWidget {
  final ScrollController scrollController;

  const WithdrawPage({super.key, required this.scrollController});

  @override
  State<WithdrawPage> createState() => _WithdrawPageState();
}

class _WithdrawPageState extends State<WithdrawPage> {
  // Figma tokens (New Withdrawal sheet — shared with New Deposit)
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

  // MoMo providers shown in the Payment Provider dropdown. Each entry
  // carries the brand label + asset path; the dropdown renders the
  // label + brand logo per Figma. Save the brand PNGs at the paths
  // below to make the logos appear (errorBuilder falls back to a
  // generic icon until then). Paths kept identical to the deposit
  // page so both flows share the same brand assets.
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

  /// Withdraw defaults to Bank Account per the Figma — flips between
  /// 'bank' / 'momo' / 'card'.
  String paymentMethod = "bank";

  final TextEditingController amountController = TextEditingController();
  final TextEditingController accountNumberController = TextEditingController();
  final TextEditingController accountNameController = TextEditingController();
  final TextEditingController cardNumber = TextEditingController();
  final TextEditingController expiry = TextEditingController();
  final TextEditingController cvc = TextEditingController();
  final TextEditingController phone = TextEditingController();

  String provider = "";
  String selectedBank = "";

  /// One idempotency key per confirmed withdrawal. Reset whenever an input
  /// changes (= a new logical order) so that retries of the *same* withdrawal
  /// reuse the key and the backend cannot debit the wallet twice.
  String? _idempotencyKey;

  @override
  void initState() {
    super.initState();
    // Toggle the Confirm/Continue button enabled state live as the user
    // types — matches Figma's #8E10FC opacity 0.5 → 1 swap.
    amountController.addListener(_rebuildOnInput);
    accountNumberController.addListener(_rebuildOnInput);
    accountNameController.addListener(_rebuildOnInput);
    cardNumber.addListener(_rebuildOnInput);
    expiry.addListener(_rebuildOnInput);
    cvc.addListener(_rebuildOnInput);
    phone.addListener(_rebuildOnInput);

    // Load the balance so we can validate the amount against available funds.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<WalletProvider>().fetchBalance();
    });
  }

  @override
  void dispose() {
    amountController.dispose();
    accountNumberController.dispose();
    accountNameController.dispose();
    cardNumber.dispose();
    expiry.dispose();
    cvc.dispose();
    phone.dispose();
    super.dispose();
  }

  void _rebuildOnInput() {
    // Any input change starts a new logical order, so drop the cached key.
    _idempotencyKey = null;
    if (mounted) setState(() {});
  }

  /// Cap withdrawals at the loaded wallet balance. Null when the balance has
  /// not been fetched yet, so we don't block the user on a stale 0.
  double? get _balanceCap {
    final w = context.read<WalletProvider>();
    return w.lastUpdated != null ? w.balance : null;
  }

  String? get _amountError =>
      Money.validateAmount(amountController.text, balance: _balanceCap);

  bool get _step1Valid => _amountError == null;

  bool get _step2Valid {
    if (paymentMethod == 'bank') {
      return accountNumberController.text.trim().isNotEmpty &&
          accountNameController.text.trim().isNotEmpty &&
          selectedBank.isNotEmpty;
    }
    if (paymentMethod == 'momo') {
      return provider.isNotEmpty && phone.text.trim().isNotEmpty;
    }
    if (paymentMethod == 'card') {
      return cardNumber.text.trim().isNotEmpty &&
          expiry.text.trim().isNotEmpty &&
          cvc.text.trim().isNotEmpty;
    }
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
                        enabled: _step2Valid && !wallet.isSubmittingWithdraw,
                        loading: wallet.isSubmittingWithdraw,
                        onTap: _submitWithdraw,
                      );
                    },
                  ),
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
        color: _sheetBg,
        border: const Border(
          bottom: BorderSide(color: _hairline, width: 1),
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
                    'New Withdrawal',
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
        SizedBox(height: 10.h),
        Consumer<WalletProvider>(
          builder: (context, wallet, _) {
            final showError = amountController.text.trim().isNotEmpty &&
                _amountError != null;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (wallet.lastUpdated != null)
                  Text(
                    'Available: ${Money.ghs(wallet.balance)}',
                    style: TextStyle(
                      fontFamily: 'SFProRounded',
                      fontSize: 13.sp,
                      color: _hintColor,
                    ),
                  ),
                if (showError) ...[
                  SizedBox(height: 6.h),
                  Text(
                    _amountError!,
                    style: TextStyle(
                      fontFamily: 'SFProRounded',
                      fontSize: 13.sp,
                      color: const Color(0xFFD32F2F),
                    ),
                  ),
                ],
              ],
            );
          },
        ),
      ],
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
        if (paymentMethod == 'bank')
          ..._bankFields()
        else if (paymentMethod == 'momo')
          ..._momoFields()
        else
          ..._cardFields(),
      ],
    );
  }

  List<Widget> _bankFields() {
    return [
      _label('Account Number'),
      SizedBox(height: 12.h),
      _figmaInput(
        accountNumberController,
        '0000 0000 0000 0000',
        keyboardType: TextInputType.number,
      ),
      SizedBox(height: 23.h),
      _label('Account Name'),
      SizedBox(height: 12.h),
      _figmaInput(accountNameController, 'Enter account name'),
      SizedBox(height: 23.h),
      _label('Bank Name'),
      SizedBox(height: 12.h),
      FigmaInlineDropdown<String>(
        value: selectedBank.isEmpty ? null : selectedBank,
        hint: 'Select an option',
        items: const [
          FigmaInlineDropdownItem(value: 'gcb', label: 'GCB Bank'),
          FigmaInlineDropdownItem(value: 'ecobank', label: 'Ecobank Ghana'),
          FigmaInlineDropdownItem(
              value: 'stanchart', label: 'Standard Chartered Bank'),
          FigmaInlineDropdownItem(
              value: 'stanbic', label: 'Stanbic Bank Ghana'),
          FigmaInlineDropdownItem(value: 'absa', label: 'Absa Bank Ghana'),
        ],
        onChanged: (v) => setState(() => selectedBank = v),
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

  List<Widget> _cardFields() {
    return [
      _label('Card Number'),
      SizedBox(height: 12.h),
      _figmaInput(cardNumber, '0000 0000 0000 0000',
          keyboardType: TextInputType.number),
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

  /// Submit the withdrawal intent via WalletProvider.
  /// Backend locks the wallet, validates balance, debits immediately
  /// (so no double-spend), creates a pending Transaction. We surface
  /// INSUFFICIENT_FUNDS specifically since it's the most common error.
  Future<void> _submitWithdraw() async {
    final wallet = context.read<WalletProvider>();

    final amountError = _amountError;
    if (amountError != null) {
      AppNotify.error(amountError);
      return;
    }
    final amount = Money.parse(amountController.text);

    // Build a destination string from the form fields.
    //   - Bank: bankId:accountNumber
    //   - MoMo: provider:phone
    //   - Card: card:cardNumber (masked downstream)
    String destination;
    String? msisdn;
    if (paymentMethod == 'bank') {
      final acct = accountNumberController.text.trim();
      destination = selectedBank.isEmpty ? acct : '$selectedBank:$acct';
    } else if (paymentMethod == 'momo') {
      msisdn = phone.text.trim();
      final providerLabel = provider.isEmpty ? 'momo' : provider;
      destination = msisdn.isEmpty
          ? providerLabel
          : '$providerLabel:$msisdn';
    } else {
      final card = cardNumber.text.trim();
      destination = card.isEmpty ? 'card' : 'card:$card';
    }

    _idempotencyKey ??= Idempotency.newKey();
    final ok = await wallet.submitWithdraw(
      amountGhs: amount,
      destination: destination,
      msisdn: msisdn,
      idempotencyKey: _idempotencyKey,
    );

    if (!mounted) return;

    if (ok) {
      Navigator.pop(context);
      await Future.delayed(const Duration(milliseconds: 200));
      if (!mounted) return;
      // Single-button "Okay" dialog — tapping Okay returns the user to
      // the portfolio (the sheet was already popped above).
      withdrawalSuccessDialog(context);
    } else {
      // WalletProvider doesn't yet expose a typed code for the withdraw
      // path (only the raw backend `lastSubmitMessage`). Surface a friendly
      // generic message instead of leaking the raw string. Follow-up:
      // add `lastSubmitCode` to WalletProvider so we can route through
      // AppNotify.fromCode like the deposit path.
      AppNotify.error('Could not submit withdrawal. Please try again.');
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

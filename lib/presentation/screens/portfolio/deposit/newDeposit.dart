import 'package:betrade/core/theme/app_colors.dart';
import 'package:betrade/core/utils/app_notify.dart';
import 'package:betrade/core/utils/idempotency.dart';
import 'package:betrade/core/utils/money.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../../../data/provider/wallet_provider.dart';
import 'deposit_waiting_screen.dart';
import '../../../widget/deposit_success.dart';
import '../../../widget/figma_inline_dropdown.dart';

class DepositPage extends StatefulWidget {
  final ScrollController scrollController;
  const DepositPage({super.key, required this.scrollController});

  @override
  State<DepositPage> createState() => _DepositPageState();
}

class _DepositPageState extends State<DepositPage> {
  // Brand-purple tokens (kept hardcoded — same in light & dark).
  static const Color _stepProgress = Color(0xFF8E10FC);
  static const Color _btnPrimary = Color(0xFF8E10FC);
  // Amount-chip tokens — light-purple fill + purple border when picked,
  // white + thin grey border otherwise. Text stays purple either way.
  static const Color _chipSelectedBg = Color(0xFFF3E6FF);
  static const Color _chipSelectedBorder = Color(0xFF8E10FC);
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

  /// Ghana licensed commercial banks. Hardcoded here until P1-F lands
  /// the `GET /api/banks` endpoint with the canonical Bank-of-Ghana
  /// list — swap this constant for a server fetch when that's wired.
  /// `code` is the value sent to the backend's `bank_account.bank_code`
  /// field; `name` is the dropdown label.
  static const List<_BankOption> _banks = [
    _BankOption(code: 'GCB', name: 'GCB Bank'),
    _BankOption(code: 'ECOBANK', name: 'Ecobank Ghana'),
    _BankOption(code: 'ABSA', name: 'Absa Bank Ghana'),
    _BankOption(code: 'STANBIC', name: 'Stanbic Bank Ghana'),
    _BankOption(code: 'ZENITH', name: 'Zenith Bank Ghana'),
    _BankOption(code: 'FBN', name: 'FBNBank Ghana'),
    _BankOption(code: 'SCB', name: 'Standard Chartered Ghana'),
    _BankOption(code: 'FIDELITY', name: 'Fidelity Bank Ghana'),
    _BankOption(code: 'CBG', name: 'Consolidated Bank Ghana'),
    _BankOption(code: 'ADB', name: 'Agricultural Development Bank'),
    _BankOption(code: 'NIB', name: 'National Investment Bank'),
    _BankOption(code: 'UBA', name: 'United Bank for Africa'),
    _BankOption(code: 'CALBANK', name: 'CalBank'),
    _BankOption(code: 'REPUBLIC', name: 'Republic Bank'),
    _BankOption(code: 'ACCESS', name: 'Access Bank'),
    _BankOption(code: 'GTBANK', name: 'GTBank'),
    _BankOption(code: 'BOA', name: 'Bank of Africa'),
    _BankOption(code: 'FNB', name: 'FNB Ghana'),
    _BankOption(code: 'OMNIBSIC', name: 'OmniBSIC Bank'),
    _BankOption(code: 'PRUDENTIAL', name: 'Prudential Bank'),
    _BankOption(code: 'FAB', name: 'First Atlantic Bank'),
    _BankOption(code: 'GHL', name: 'GHL Bank'),
    _BankOption(code: 'UMB', name: 'Universal Merchant Bank'),
    _BankOption(code: 'SGGH', name: 'Societe Generale Ghana'),
  ];

  int step = 1;

  /// One idempotency key per confirmed deposit. Reset on any input change so
  /// retries of the *same* deposit reuse it (no duplicate pending charge).
  String? _idempotencyKey;

  final TextEditingController amountController = TextEditingController();
  String paymentMethod = "card";
  final TextEditingController cardNumber = TextEditingController();
  final TextEditingController expiry = TextEditingController();
  final TextEditingController cvc = TextEditingController();
  final TextEditingController phone = TextEditingController();
  String provider = "";

  // Bank Account form
  String bankCode = "";
  final TextEditingController accountNumber = TextEditingController();
  final TextEditingController accountName = TextEditingController();

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
    accountNumber.addListener(_rebuildOnInput);
    accountName.addListener(_rebuildOnInput);
  }

  @override
  void dispose() {
    amountController.dispose();
    cardNumber.dispose();
    expiry.dispose();
    cvc.dispose();
    phone.dispose();
    accountNumber.dispose();
    accountName.dispose();
    super.dispose();
  }

  void _rebuildOnInput() {
    // Any input change starts a new logical order, so drop the cached key.
    _idempotencyKey = null;
    if (mounted) setState(() {});
  }

  String? get _amountError => Money.validateAmount(amountController.text);

  bool get _step1Valid => _amountError == null;

  bool get _step2Valid {
    if (paymentMethod == 'card') {
      return cardNumber.text.trim().isNotEmpty &&
          expiry.text.trim().isNotEmpty &&
          cvc.text.trim().isNotEmpty;
    }
    if (paymentMethod == 'momo') {
      return provider.isNotEmpty && phone.text.trim().isNotEmpty;
    }
    if (paymentMethod == 'bank') {
      // bank_code (from dropdown) + account_number required by the
      // backend's `bank_account` validation. account_name is optional
      // for verify-payee step.
      return bankCode.isNotEmpty &&
          accountNumber.text.trim().length >= 6;
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
      backgroundColor: AppColors.cardBackgroundDynamic(context),
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
                      // P0-A: button is "busy" while the initiate call
                      // is in flight (was: isSubmittingDeposit).
                      final busy = wallet.isInitiatingDeposit;
                      return _figmaButton(
                        'Confirm',
                        enabled: _step2Valid && !busy,
                        loading: busy,
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
        color: AppColors.cardBackgroundDynamic(context),
        border: Border(
          bottom: BorderSide(color: AppColors.borderDynamic(context), width: 1),
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
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.iconContainerDynamic(context),
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
              color: AppColors.textPrimaryDynamic(context),
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
        if (amountController.text.trim().isNotEmpty && _amountError != null) ...[
          SizedBox(height: 12.h),
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
          color: selected
              ? _chipSelectedBg
              : AppColors.cardBackgroundDynamic(context),
          border: Border.all(
            color: selected
                ? _chipSelectedBorder
                : AppColors.borderDynamic(context),
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
          ..._bankFields(),
      ],
    );
  }

  /// Bank Account form — picks one of the licensed Ghanaian banks
  /// (hardcoded in `_banks` until P1-F lands the `GET /api/banks`
  /// endpoint), takes an account number + optional account name,
  /// and POSTs them as the `bank_account` sub-block to
  /// `/api/wallet/deposit/initiate`. The backend (via Flutterwave)
  /// then issues a one-time virtual account that the
  /// `DepositWaitingScreen` displays for the user to transfer into.
  List<Widget> _bankFields() {
    return [
      _label('Bank'),
      SizedBox(height: 12.h),
      FigmaInlineDropdown<String>(
        value: bankCode.isEmpty ? null : bankCode,
        hint: 'Select your bank',
        items: _banks.map((b) {
          return FigmaInlineDropdownItem<String>(
            value: b.code,
            label: b.name,
          );
        }).toList(),
        onChanged: (v) => setState(() => bankCode = v),
      ),
      SizedBox(height: 23.h),
      _label('Account Number'),
      SizedBox(height: 12.h),
      _figmaInput(
        accountNumber,
        '0000 0000 0000 0000',
        keyboardType: TextInputType.number,
      ),
      SizedBox(height: 23.h),
      _label('Account Name (optional)'),
      SizedBox(height: 12.h),
      _figmaInput(accountName, 'John Doe'),
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
                color: AppColors.textSecondaryDynamic(context),
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
          color: AppColors.textPrimaryDynamic(context),
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
        color: AppColors.iconContainerDynamic(context),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: TextStyle(
          fontFamily: 'SFProRounded',
          fontSize: 16.sp,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimaryDynamic(context),
        ),
        decoration: InputDecoration(
          border: InputBorder.none,
          isCollapsed: true,
          hintText: hint,
          hintStyle: TextStyle(
            fontFamily: 'SFProRounded',
            fontSize: 16.sp,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondaryDynamic(context),
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

  /// P0-A — submit the deposit through the new gateway-initiate
  /// endpoint. Builds the method-specific payload, calls
  /// `WalletProvider.submitDepositInitiate`, and routes the user to
  /// `DepositWaitingScreen` which polls the wallet for the
  /// webhook-driven credit.
  ///
  /// Shows the existing success dialog when the waiting screen returns
  /// `true` (balance went up); shows a snackbar with the typed backend
  /// error code message on failure.
  Future<void> _submitDeposit() async {
    final wallet = context.read<WalletProvider>();
    final navigator = Navigator.of(context);

    final amountError = _amountError;
    if (amountError != null) {
      AppNotify.error(amountError);
      return;
    }
    final amount = Money.parse(amountController.text);

    // Build the method-specific payload that the backend expects.
    // Card data is intentionally tokenized client-side in a real
    // production build via the Flutterwave SDK; we ship a placeholder
    // token for the stub gateway so the API contract can be tested
    // end-to-end on staging without merchant credentials.
    final String backendMethod;
    final Map<String, dynamic> methodPayload;
    if (paymentMethod == 'card') {
      backendMethod = 'card';
      final card = cardNumber.text.trim().replaceAll(' ', '');
      final last4 = card.length >= 4 ? card.substring(card.length - 4) : '';
      methodPayload = {
        // TODO(real-gateway): replace this placeholder with the
        // one-time token returned by Flutterwave's mobile SDK once
        // the SDK is integrated. For now this lets the stub gateway
        // accept the call.
        'token': 'CLIENT_TOKENIZED_PLACEHOLDER',
        if (last4.isNotEmpty) 'last4': last4,
        'country': 'GH',
      };
    } else if (paymentMethod == 'momo') {
      backendMethod = 'mobile_money';
      methodPayload = {
        'provider': provider,
        'msisdn': _normalisedMsisdn(phone.text.trim()),
      };
    } else if (paymentMethod == 'bank') {
      backendMethod = 'bank_account';
      final acctNo = accountNumber.text.trim().replaceAll(' ', '');
      final acctName = accountName.text.trim();
      methodPayload = {
        'bank_code': bankCode,
        'account_number': acctNo,
        if (acctName.isNotEmpty) 'account_name': acctName,
      };
    } else {
      // Should be unreachable — _step2Valid keeps Confirm disabled
      // for any unknown method. Defensive fallback.
      AppNotify.error('Unknown payment method.');
      return;
    }

    _idempotencyKey ??= Idempotency.newKey();
    final initiated = await wallet.submitDepositInitiate(
      amountGhs: amount,
      method: backendMethod,
      methodPayload: methodPayload,
      idempotencyKey: _idempotencyKey,
    );

    if (!mounted) return;

    if (initiated == null) {
      // Map the typed backend code (BELOW_MIN_AMOUNT, GATEWAY_UNAVAILABLE,
      // INVALID_METHOD, …) to a friendly message via BackendErrors instead
      // of surfacing the raw `lastInitiateMessage` string.
      AppNotify.fromCode(
        code: wallet.lastInitiateCode,
        fallback: 'Could not initiate deposit. Please try again.',
      );
      return;
    }

    // Push the waiting screen — it polls `/api/wallet` and pops `true`
    // when the webhook credits the wallet.
    final credited = await navigator.push<bool>(
      MaterialPageRoute(
        builder: (_) => DepositWaitingScreen(response: initiated),
      ),
    );

    if (!mounted) return;

    if (credited == true) {
      // Close the deposit form sheet itself, then show success modal.
      Navigator.pop(context);
      await wallet.fetchBalance();
      await wallet.fetchTransactions(type: wallet.currentTypeFilter);
      await Future.delayed(const Duration(milliseconds: 200));
      if (!mounted) return;
      showSuccessDialog(context);
    }
    // If `credited` is false / null, the user cancelled — stay on the
    // form so they can retry without re-entering all the fields.
  }

  /// Convert the Figma "054 376 2061" format → E.164 "+233543762061"
  /// that the backend's `mobile_money.msisdn` regex (`^\+\d{8,15}$`)
  /// will accept.
  String _normalisedMsisdn(String raw) {
    final digits = raw.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.startsWith('+')) return digits;
    if (digits.startsWith('00')) return '+${digits.substring(2)}';
    if (digits.startsWith('233')) return '+$digits';
    // Local Ghana number (e.g. 054...) → prepend +233 + drop leading 0.
    if (digits.startsWith('0')) return '+233${digits.substring(1)}';
    return '+$digits';
  }
}

/// One bank option for the Bank Account dropdown. `code` is the
/// canonical short-code (e.g. 'GCB', 'ECOBANK') that the backend's
/// `bank_account.bank_code` validation accepts; `name` is the
/// display label.
class _BankOption {
  final String code;
  final String name;

  const _BankOption({required this.code, required this.name});
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

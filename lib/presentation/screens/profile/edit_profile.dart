import 'package:betrade/core/theme/app_text_style.dart';
import 'package:betrade/presentation/widget/common_header.dart';
import 'package:betrade/presentation/widget/customSnackBar.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../../core/config/api_endpoint.dart';
import '../../../core/network/dio_client.dart';
import '../../../data/provider/profile_provider.dart';
import '../../../data/model/country_model.dart';
import '../../../data/services/local_storage.dart';
import '../verification/country_services_step_one.dart';

class EditProfile extends StatefulWidget {
  const EditProfile({super.key, required ScrollController scrollController});

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  // Figma tokens (Frame 2609813)
  static const Color _sheetBg = Color(0xFFFFFFFF);
  static const Color _labelColor = Color(0xFF09090B);
  static const Color _inputBg = Color(0xFFF4F4F5);
  static const Color _inputText = Color(0xFF09090B);
  static const Color _chevron = Color(0xFF1C274C);
  static const Color _btnPrimary = Color(0xFF8E10FC);

  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final phoneController = TextEditingController();

  List<CountryModel> countries = [];
  CountryModel? selectedCountry;
  List<DropdownItem> languages = [];
  DropdownItem? language;
  String? selectedCurrency;
  bool isLoading = true;

  // Originals — captured once profile + lookups load, used to gate Save.
  String _originalFirstName = '';
  String _originalLastName = '';
  String _originalCountryName = '';
  String? _originalCurrency;
  int? _originalLanguageId;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    final profile =
        Provider.of<ProfileProvider>(context, listen: false).profile;
    if (profile != null) {
      firstNameController.text = profile.firstName;
      lastNameController.text = profile.lastName;
      phoneController.text = profile.phone ?? '';
      _originalFirstName = profile.firstName;
      _originalLastName = profile.lastName;
      _originalCountryName = profile.country ?? '';
      _originalCurrency = profile.currency;
    }
    firstNameController.addListener(_recomputeHasChanges);
    lastNameController.addListener(_recomputeHasChanges);
    Future.microtask(loadAllData);
  }

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  void _recomputeHasChanges() {
    final changed = firstNameController.text != _originalFirstName ||
        lastNameController.text != _originalLastName ||
        (selectedCountry?.name ?? '') != _originalCountryName ||
        (selectedCurrency ?? '') != (_originalCurrency ?? '') ||
        language?.id != _originalLanguageId;
    if (changed != _hasChanges && mounted) {
      setState(() => _hasChanges = changed);
    }
  }

  Future<void> loadAllData() async {
    try {
      if (!mounted) return;
      setState(() => isLoading = true);

      final countryRes = await CountryService.fetchCountries();
      if (!mounted) return;
      countries = countryRes;

      if (countries.isNotEmpty) {
        // Prefer the user's saved country; fall back to first.
        final matches =
            countries.where((c) => c.name == _originalCountryName).toList();
        selectedCountry = matches.isNotEmpty ? matches.first : countries.first;
        selectedCurrency = selectedCountry?.currency ?? _originalCurrency;
      }

      final token = LocalStorage.getToken();
      final response = await DioClient.instance.get(
        ApiEndpoints.languages,
        options: Options(
          headers: {
            "Accept": "application/json",
            "Authorization": "Bearer $token",
          },
        ),
      );
      if (!mounted) return;

      if (response.statusCode == 200) {
        final data = response.data;
        if (data is Map && data['data'] is List) {
          final List list = data['data'];
          languages = list
              .map((e) => DropdownItem(id: e['id'], name: e['name']))
              .toList();
          if (languages.isNotEmpty) {
            language = languages.first;
            _originalLanguageId = language?.id;
          }
        }
      }
      if (!mounted) return;
      setState(() => isLoading = false);
      _recomputeHasChanges();
    } catch (_) {
      if (!mounted) return;
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ProfileProvider>(context);
    return Scaffold(
      backgroundColor: _sheetBg,
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                const CommonHeader(title: "Personal Info"),
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 24.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _labeledTextField("First Name", firstNameController),
                        SizedBox(height: 23.h),
                        _labeledTextField("Last Name", lastNameController),
                        SizedBox(height: 23.h),
                        _countryField(),
                        SizedBox(height: 23.h),
                        _currencyField(),
                        SizedBox(height: 23.h),
                        _languageField(),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 20.h),
                  child: _saveButton(provider),
                ),
              ],
            ),
    );
  }

  Widget _label(String text) => Text(
        text,
        style: TextStyle(
          fontSize: 16.sp,
          fontWeight: FontWeight.w600,
          color: _labelColor,
          fontFamily: AppTextStyle.fontFamily,
        ),
      );

  BoxDecoration get _inputDecoration => BoxDecoration(
        color: _inputBg,
        borderRadius: BorderRadius.circular(16.r),
      );

  TextStyle get _inputTextStyle => TextStyle(
        fontSize: 16.sp,
        fontWeight: FontWeight.w500,
        color: _inputText,
        fontFamily: AppTextStyle.fontFamily,
      );

  Widget _labeledTextField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label(label),
        SizedBox(height: 12.h),
        Container(
          height: 62.h,
          decoration: _inputDecoration,
          child: TextField(
            controller: controller,
            style: _inputTextStyle,
            decoration: InputDecoration(
              border: InputBorder.none,
              isCollapsed: true,
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
            ),
          ),
        ),
      ],
    );
  }

  Widget _countryField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label("Country of residence"),
        SizedBox(height: 12.h),
        Container(
          height: 62.h,
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          decoration: _inputDecoration,
          child: DropdownButtonHideUnderline(
            child: DropdownButton<CountryModel>(
              value: selectedCountry,
              isExpanded: true,
              icon: Icon(Icons.keyboard_arrow_down,
                  size: 24.sp, color: _chevron),
              dropdownColor: _sheetBg,
              items: countries.map((e) {
                return DropdownMenuItem<CountryModel>(
                  value: e,
                  child: Row(
                    children: [
                      if (e.flag.startsWith("http"))
                        ClipOval(
                          child: Image.network(
                            e.flag,
                            width: 24.w,
                            height: 24.w,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                                Icon(Icons.flag, size: 16.sp),
                          ),
                        )
                      else
                        Icon(Icons.flag, size: 16.sp),
                      SizedBox(width: 8.w),
                      Text(e.name, style: _inputTextStyle),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (val) {
                if (val == null) return;
                setState(() {
                  selectedCountry = val;
                  selectedCurrency = val.currency;
                });
                _recomputeHasChanges();
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _currencyField() {
    // Currency is derived from selectedCountry; the chevron is decorative.
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label("Preferred Currency"),
        SizedBox(height: 12.h),
        Container(
          height: 62.h,
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          decoration: _inputDecoration,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(selectedCurrency ?? '', style: _inputTextStyle),
              Icon(Icons.keyboard_arrow_down, size: 24.sp, color: _chevron),
            ],
          ),
        ),
      ],
    );
  }

  Widget _languageField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label("Language"),
        SizedBox(height: 12.h),
        Container(
          height: 62.h,
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          decoration: _inputDecoration,
          child: DropdownButtonHideUnderline(
            child: DropdownButton<DropdownItem>(
              value: language,
              isExpanded: true,
              icon: Icon(Icons.keyboard_arrow_down,
                  size: 24.sp, color: _chevron),
              dropdownColor: _sheetBg,
              items: languages.map((e) {
                return DropdownMenuItem<DropdownItem>(
                  value: e,
                  child: Text(e.name, style: _inputTextStyle),
                );
              }).toList(),
              onChanged: (val) {
                if (val == null) return;
                setState(() => language = val);
                _recomputeHasChanges();
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _saveButton(ProfileProvider provider) {
    final enabled =
        selectedCountry != null && _hasChanges && !provider.isLoading;
    return GestureDetector(
      onTap: enabled
          ? () async {
              final success = await provider.updateProfile(
                firstName: firstNameController.text,
                lastName: lastNameController.text,
                phone: phoneController.text,
              );
              if (!mounted) return;
              if (success) {
                CustomSnackBar.showSuccess(
                  context,
                  message: "Profile Updated",
                  duration: const Duration(seconds: 3),
                );
                Navigator.pop(context);
              }
            }
          : null,
      child: Container(
        height: 60.h,
        decoration: BoxDecoration(
          color: enabled ? _btnPrimary : _btnPrimary.withOpacity(0.5),
          borderRadius: BorderRadius.circular(32.r),
        ),
        alignment: Alignment.center,
        child: provider.isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Text(
                "Save changes",
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  fontFamily: AppTextStyle.fontFamily,
                ),
              ),
      ),
    );
  }
}

class DropdownItem {
  final int id;
  final String name;
  DropdownItem({required this.id, required this.name});
}

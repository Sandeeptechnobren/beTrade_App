import 'dart:convert';
import 'dart:io';
import 'package:betrade/core/theme/app_colors.dart';
import 'package:betrade/core/theme/app_text_style.dart';
import 'package:betrade/presentation/widget/common_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import '../../../data/provider/profile_provider.dart';
import '../../../data/model/country_model.dart';
import '../../../data/services/local_storage.dart';
import '../../widget/purple_button.dart';
import '../verification/country_services_step_one.dart';

class EditProfile extends StatefulWidget {
  const EditProfile({super.key, required ScrollController scrollController});

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final phoneController = TextEditingController();

  String gender = "male";
  File? selectedImage;
  final picker = ImagePicker();
  List<CountryModel> countries = [];
  CountryModel? selectedCountry;
  List<DropdownItem> languages = [];
  DropdownItem? language;
  String? selectedCurrency;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();

    final profile = Provider.of<ProfileProvider>(
      context,
      listen: false,
    ).profile;

    if (profile != null) {
      firstNameController.text = profile.firstName;
      lastNameController.text = profile.lastName;
      phoneController.text = profile.phone ?? '';
      gender = profile.gender ?? "male";
    }

    loadAllData();
  }

  Future<void> loadAllData() async {
    try {
      setState(() => isLoading = true);

      final countryRes = await CountryService.fetchCountries();
      countries = countryRes;

      if (countries.isNotEmpty) {
        selectedCountry = countries.first;
        selectedCurrency = selectedCountry!.currency;
      }

      final token = LocalStorage.getToken();
      final response = await http.get(
        Uri.parse(
          "https://api.easycoders.in/projects/betrade/public/api/languages",
        ),
        headers: {
          "Accept": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        print("TOKEN: $token");
        print("STATUS CODE: ${response.statusCode}");
        print("BODY: ${response.body}");
        final data = jsonDecode(response.body);
        final List list = data['data'];

        languages = list
            .map((e) => DropdownItem(id: e['id'], name: e['name']))
            .toList();

        if (languages.isNotEmpty) {
          language = languages.first;
        }
      }

      setState(() => isLoading = false);
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  Future<void> pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        selectedImage = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ProfileProvider>(context);

    return Scaffold(
      body: SafeArea(
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: Column(
                  children: [
                    const CommonHeader(title: "Personal Info"),

                    Padding(
                      padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.w),
                      child: Column(
                        children: [
                          SizedBox(height: 20.h),
                          Center(
                            child: Stack(
                              children: [
                                CircleAvatar(
                                  radius: 50.r,
                                  backgroundColor: Colors.grey.shade200,
                                  backgroundImage: selectedImage != null
                                      ? FileImage(selectedImage!)
                                      : (provider.profile?.avatar.isNotEmpty ==
                                            true)
                                      ? NetworkImage(provider.profile!.avatar)
                                      : null,
                                  child:
                                      selectedImage == null &&
                                          (provider.profile?.avatar.isEmpty ??
                                              true)
                                      ? Icon(
                                          Icons.person,
                                          size: 40.sp,
                                          color: Colors.grey,
                                        )
                                      : null,
                                ),
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: GestureDetector(
                                    onTap: pickImage,
                                    child: Container(
                                      padding: EdgeInsets.all(6.w),
                                      decoration: BoxDecoration(
                                        color: AppColors.primary,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        Icons.camera_alt,
                                        color: Colors.white,
                                        size: 18.sp,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 16.w,
                              vertical: 20.h,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(24.r),
                            ),
                            child: Column(
                              children: [
                                _buildField("First Name", firstNameController),
                                _buildField("Last Name", lastNameController),
                                buildCountryDropdown(),
                                buildCurrencyDropdown(),
                                buildLanguageDropdown(),
                              ],
                            ),
                          ),

                          SizedBox(height: 100.h),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
      ),

      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Button(
            title: "Save Changes",
            isLoading: provider.isLoading,
            onPressed: () async {
              bool success = await provider.updateProfile(
                firstName: firstNameController.text,
                lastName: lastNameController.text,
                phone: phoneController.text,
                gender: gender,
                country: selectedCountry!.name,
                image: selectedImage,
              );

              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Profile Updated")),
                );
                Navigator.pop(context);
              }
            },
          ),
        ),
      ),
    );
  }

  Widget _buildField(String title, TextEditingController controller) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyle.body),
          SizedBox(height: 6.h),
          Container(
            decoration: BoxDecoration(
              color: AppColors.inputFieldBgDynamic(context),
              borderRadius: BorderRadius.circular(14.r),
            ),
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.all(14.w),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildCountryDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Country of residence", style: AppTextStyle.body),
        SizedBox(height: 8),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: AppColors.inputFieldBgDynamic(context),
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButton<CountryModel>(
            value: selectedCountry,
            isExpanded: true,
            underline: SizedBox(),
            items: countries.map((e) {
              return DropdownMenuItem(
                value: e,
                child: Row(
                  children: [Text(e.flag), SizedBox(width: 8), Text(e.name)],
                ),
              );
            }).toList(),
            onChanged: (val) {
              setState(() {
                selectedCountry = val;
                selectedCurrency = val!.currency;
              });
            },
          ),
        ),
        SizedBox(height: 16),
      ],
    );
  }

  Widget buildCurrencyDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Preferred Currency", style: AppTextStyle.body),
        SizedBox(height: 8),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: AppColors.inputFieldBgDynamic(context),
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButton<String>(
            value: selectedCurrency,
            isExpanded: true,
            underline: SizedBox(),
            items: selectedCurrency != null
                ? [
                    DropdownMenuItem(
                      value: selectedCurrency,
                      child: Text(selectedCurrency!),
                    ),
                  ]
                : [],
            onChanged: null,
          ),
        ),
        SizedBox(height: 16),
      ],
    );
  }

  Widget buildLanguageDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Language", style: AppTextStyle.body),
        SizedBox(height: 8),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: AppColors.inputFieldBgDynamic(context),
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButton<DropdownItem>(
            value: language,
            isExpanded: true,
            underline: SizedBox(),
            items: languages.map((e) {
              return DropdownMenuItem(value: e, child: Text(e.name));
            }).toList(),
            onChanged: (val) {
              setState(() {
                language = val;
              });
            },
          ),
        ),
        SizedBox(height: 16),
      ],
    );
  }
}

class DropdownItem {
  final int id;
  final String name;

  DropdownItem({required this.id, required this.name});
}

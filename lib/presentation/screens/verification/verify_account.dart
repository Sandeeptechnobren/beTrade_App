import 'dart:convert';
import 'dart:io';
import 'package:betrade/core/theme/app_colors.dart';
import 'package:betrade/presentation/screens/verification/step_heder.dart';
import 'package:betrade/presentation/widget/purple_button.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import '../../../data/model/country_model.dart';
import '../camera/camera_screen.dart';
import '../camera/selfie_camera.dart';
import '../main_screen.dart';
import 'country_services_step_one.dart';

class VerificationFlow extends StatefulWidget {
  @override
  State<VerificationFlow> createState() => _VerificationFlowState();
}

class _VerificationFlowState extends State<VerificationFlow> {
  int currentStep = 0;
  File? selfieImage;
  bool isSelfieUploaded = false;
  File? frontImage;
  File? backImage;
  bool isLoading = true;
  bool isFrontUploaded = false;
  bool isBackUploaded = false;
  final ImagePicker picker = ImagePicker();

  List<CountryModel> countries = [];
  CountryModel? selectedCountry;
  List<DropdownItem> currencies = [];
  List<DropdownItem> languages = [];

  DropdownItem? currency;
  DropdownItem? language;

  @override
  void initState() {
    super.initState();
    loadData();
    loadLanguages();
  }

  Future<void> loadData() async {
    try {
      countries = await CountryService.fetchCountries();

      // Default selection
      if (countries.isNotEmpty) {
        selectedCountry = countries.first;
      }

      // Keep your existing static data
      currencies = [
        DropdownItem(id: 1, name: "INR"),
        DropdownItem(id: 2, name: "USD"),
      ];

      languages = [
        DropdownItem(id: 1, name: "English"),
        DropdownItem(id: 2, name: "Hindi"),
      ];

      currency = currencies.first;
      language = languages.first;

      setState(() => isLoading = false);
    } catch (e) {
      print("Error: $e");
      setState(() => isLoading = false);
    }
  }

  Future<void> loadLanguages() async {
    try {
      final response = await http.get(
        Uri.parse(
          "https://api.easycoders.in/projects/betrade/public/api/languages",
        ),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        final List list = data['data'];

        setState(() {
          languages = list.map((e) {
            return DropdownItem(id: e['id'], name: e['name']);
          }).toList();

          language = languages.first; // default select
        });
      } else {
        print("Error: ${response.body}");
      }
    } catch (e) {
      print("Exception: $e");
    }
  }

  Future<void> openCamera(bool isFront) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => CameraScreen(isFront: isFront)),
    );

    if (result != null) {
      setState(() {
        if (isFront) {
          frontImage = File(result);
          isFrontUploaded = true;
        } else {
          backImage = File(result);
          isBackUploaded = true;
        }
      });
    }
  }

  bool isStepValid() {
    if (currentStep == 0) {
      return selectedCountry != null && currency != null && language != null;
    }
    return true;
  }

  void nextStep() async {
    if (currentStep == 0) {
      await submitStep1();

      // Optional: stop if API fails
      // return;
    }

    if (currentStep < 2) {
      setState(() {
        currentStep++;
      });
    } else {
      Navigator.pop(context);
    }
  }

  void previousStep() {
    if (currentStep > 0) {
      setState(() {
        currentStep--;
      });
    }
  }

  Future<void> submitStep1() async {
    try {
      final url = Uri.parse(
        "https://api.easycoders.in/projects/betrade/public/api/profile/preferences",
      );

      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "country_id": selectedCountry?.id,
          "preferred_language_id": language?.id,
        }),
      );

      if (response.statusCode == 200) {
        print("Step1 Success: ${response.body}");
      } else {
        print("Step1 Error: ${response.body}");
      }
    } catch (e) {
      print("API Error: $e");
    }
  }

  Widget buildStepContent() {
    switch (currentStep) {
      case 0:
        return step1();
      case 1:
        return step2();
      case 2:
        return step3();
      default:
        return step1();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: SafeArea(
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.symmetric(vertical: 10),
              height: 5,
              width: 50,
              decoration: BoxDecoration(
                color: Colors.grey,
                borderRadius: BorderRadius.circular(10),
              ),
            ),

            // 🔵 Step Indicator
            StepHeader(currentStep: currentStep),

            Expanded(
              child: isLoading
                  ? Center(child: CircularProgressIndicator())
                  : buildStepContent(),
            ),
            if (currentStep != 2)
              Padding(
                padding: EdgeInsets.all(16),
                child: Row(
                  children: [
                    if (currentStep > 0) SizedBox(width: 10),

                    Expanded(
                      child: SizedBox(
                        height: 55,
                        child: Button(
                          title: "Next",
                          onPressed: isStepValid() ? nextStep : null,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget step1() {
    return Padding(
      padding: EdgeInsets.only(left: 16, right: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Divider(),
          SizedBox(height: 20),
          buildCountryDropdown(),
          buildDropdown(
            "Currency",
            currency,
            currencies,
            (val) => setState(() => currency = val),
          ),

          buildDropdown(
            "Language",
            language,
            languages,
            (val) => setState(() => language = val),
          ),
        ],
      ),
    );
  }

  Widget step2() {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "ID Verification",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),

          SizedBox(height: 20),

          // FRONT
          buildUploadBox("ID Card (Front)", frontImage, () => openCamera(true)),

          // BACK
          buildUploadBox("ID Card (Back)", backImage, () => openCamera(false)),
        ],
      ),
    );
  }

  Widget step3() {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(),
          SizedBox(height: 20),
          buildSelfieBox(),
          Spacer(),
          SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: isSelfieUploaded
                    ? AppColors.primary
                    : Colors.purple.shade200,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              onPressed: isSelfieUploaded
                  ? () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (_) => MainScreen()),
                        (route) => false,
                      );
                    }
                  : null,
              child: Text(
                "Verify my account",
                style: TextStyle(color: Colors.white),
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
        Text("Country"),
        SizedBox(height: 8),

        Container(
          padding: EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
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
                  children: [
                    Text(e.flag), // 🇮🇳 flag
                    SizedBox(width: 8),
                    Text("${e.name}"),
                  ],
                ),
              );
            }).toList(),

            onChanged: (val) {
              setState(() {
                selectedCountry = val;
              });
            },
          ),
        ),

        SizedBox(height: 16),
      ],
    );
  }

  Widget buildDropdown(
    String title,
    DropdownItem? value,
    List<DropdownItem> items,
    Function(DropdownItem?) onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title),
        SizedBox(height: 8),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButton<DropdownItem>(
            value: value,
            isExpanded: true,
            underline: SizedBox(),
            items: items.map((e) {
              return DropdownMenuItem(value: e, child: Text(e.name));
            }).toList(),
            onChanged: onChanged,
          ),
        ),
        SizedBox(height: 16),
      ],
    );
  }

  Widget buildUploadBox(String title, File? image, VoidCallback onTap) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title),
        SizedBox(height: 8),

        GestureDetector(
          onTap: onTap,
          child: Container(
            height: 120,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(12),
            ),

            child: image != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(image, fit: BoxFit.cover),
                  )
                : Icon(Icons.add_a_photo, size: 40, color: Colors.grey),
          ),
        ),

        SizedBox(height: 16),
      ],
    );
  }

  Widget buildSelfieBox() {
    return GestureDetector(
      onTap: openSelfieCamera,
      child: Container(
        height: 140,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(12),
        ),
        child: selfieImage != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(selfieImage!, fit: BoxFit.cover),
              )
            : Icon(Icons.add_a_photo, size: 40, color: Colors.grey),
      ),
    );
  }

  Future<void> openSelfieCamera() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => SelfieCameraScreen()),
    );

    if (result != null) {
      setState(() {
        selfieImage = File(result);
        isSelfieUploaded = true;
      });
    }
  }
}

class DropdownItem {
  final int id;
  final String name;

  DropdownItem({required this.id, required this.name});
}

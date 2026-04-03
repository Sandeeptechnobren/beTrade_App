import 'dart:convert';
import 'dart:io';
import 'package:betrade/core/theme/app_colors.dart';
import 'package:betrade/presentation/screens/verification/step_heder.dart';
import 'package:betrade/presentation/widget/purple_button.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import '../../../data/model/country_model.dart';
import '../../../data/services/local_storage.dart';
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
  List<DropdownItem> languages = [];
  DropdownItem? language;
  String? selectedCurrency;
  @override
  void initState() {
    super.initState();
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
        Uri.parse("https://api.easycoders.in/projects/betrade/public/api/languages"),
        headers: {
          "Accept": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      print("TOKEN: $token");
      print("LANG RESPONSE: ${response.body}");

      print("LANG RESPONSE: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        final List list = data['data'];

        languages = list
            .map((e) => DropdownItem(id: e['id'], name: e['name']))
            .toList();

        if (languages.isNotEmpty) {
          language = languages.first;
        }

      }

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      print("ERROR: $e");
      setState(() => isLoading = false);
    }
  }

  bool isStep2Valid() {
    return frontImage != null && backImage != null;
  }

  Future<void> submitKyc() async {
    try {
      final token = LocalStorage.getToken();

      var request = http.MultipartRequest(
        'POST',
        Uri.parse("https://api.easycoders.in/projects/betrade/public/api/kyc/submit"),
      );

      request.headers.addAll({
        "Authorization": "Bearer $token",
        "Accept": "application/json",
      });

      // 🔥 Images attach
      request.files.add(await http.MultipartFile.fromPath(
        'id_front',
        frontImage!.path,
      ));

      request.files.add(await http.MultipartFile.fromPath(
        'id_back',
        backImage!.path,
      ));

      request.files.add(await http.MultipartFile.fromPath(
        'selfie',
        selfieImage!.path,
      ));

      var response = await request.send();

      var responseData = await response.stream.bytesToString();

      print("KYC RESPONSE: $responseData");

      if (response.statusCode == 200) {
        print("✅ KYC SUCCESS");
      } else {
        print("❌ KYC FAILED");
      }

    } catch (e) {
      print("KYC ERROR: $e");
    }
  }

  Future<void> submitStep1() async {
    try {
      final token = LocalStorage.getToken();

      final url = Uri.parse(
        "https://api.easycoders.in/projects/betrade/public/api/profile/preferences",
      );

      final response = await http.post(
        url,
        headers: {
          "Accept": "application/json", //
          "Authorization": "Bearer $token", //
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "country_id": selectedCountry?.id,
          "preferred_language_id": language?.id,
        }),
      );

      print("STEP1 RESPONSE: ${response.body}");

    } catch (e) {
      print("API Error: $e");
    }
  }

  bool isStepValid() {
    return selectedCountry != null && language != null;
  }

  void nextStep() async {
    if (currentStep == 0) {
      await submitStep1();
    }

    if (currentStep < 2) {
      setState(() {
        currentStep++;
      });
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
            StepHeader(currentStep: currentStep),
            Expanded(
              child: isLoading
                  ? Center(child: CircularProgressIndicator())
                  : buildStepContent(),
            ),

            if (currentStep != 2)
              Padding(
                padding: EdgeInsets.all(16),
                child: SizedBox(
                  height: 55,
                  width: double.infinity,
                  child: Button(
                    title: "Next",
                    onPressed: () {
                      if (currentStep == 0 && isStepValid()) {
                        nextStep();
                      } else if (currentStep == 1 && isStep2Valid()) {
                        nextStep();
                      }
                    },
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }


  Widget step1() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Divider(),
          SizedBox(height: 20),
          buildCountryDropdown(),
          buildCurrencyDropdown(),
          buildLanguageDropdown(),
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
            value: countries.contains(selectedCountry) ? selectedCountry : null,
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
        Text("Currency"),
        SizedBox(height: 8),

        Container(
          padding: EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
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
        Text("Language"),
        SizedBox(height: 8),

        Container(
          padding: EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(12),
          ),

          child: languages.isEmpty
              ? Padding(
            padding: EdgeInsets.all(12),
            child: Text("No Language Found"),
          )
              : DropdownButton<DropdownItem>(
            value: language,
            isExpanded: true,
            underline: SizedBox(),

            items: languages.map((e) {
              return DropdownMenuItem(
                value: e,
                child: Text(e.name),
              );
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

  Widget step2() {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                  ? () async {
                if (frontImage == null || backImage == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Upload ID images first")),
                  );
                  return;
                }

                await submitKyc();

                // ✅ IMPORTANT FIX
                if (!mounted) return;

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

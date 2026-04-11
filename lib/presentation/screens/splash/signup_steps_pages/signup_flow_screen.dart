import 'dart:io';
import 'package:betrade/presentation/screens/splash/signup_steps_pages/step_name.dart';
import 'package:betrade/presentation/screens/splash/signup_steps_pages/step_profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;

import 'Gender_step.dart';

class SignupFlowScreen extends StatefulWidget {
  @override
  State<SignupFlowScreen> createState() => _SignupFlowScreenState();
}

class _SignupFlowScreenState extends State<SignupFlowScreen> {
  int step = 0;

  String gender = "";
  String firstName = "";
  String lastName = "";
  File? image;
  bool isLoading = false;
  void showMsg(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  bool validate() {
    if (gender.isEmpty) {
      showMsg("Select gender");
      return false;
    }
    if (firstName.isEmpty || lastName.isEmpty) {
      showMsg("Enter full name");
      return false;
    }
    if (image == null) {
      showMsg("Select profile image");
      return false;
    }
    return true;
  }

  Future submit() async {
    if (!validate()) return;

    setState(() => isLoading = true);

    var request = http.MultipartRequest(
      'POST',
      Uri.parse("https://api.easycoders.in/projects/betrade/public/api/complete-profile"),
    );

    request.fields['gender'] = gender;
    request.fields['first_name'] = firstName;
    request.fields['last_name'] = lastName;

    request.files.add(
      await http.MultipartFile.fromPath('avatar', image!.path),
    );

    var res = await request.send();

    setState(() => isLoading = false);

    if (res.statusCode == 200) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text("Success 🎉"),
          content: Text("Registration Successfully"),
        ),
      );
    } else {
      showMsg("Failed");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
          children: [

            Expanded(
              child: IndexedStack(
                index: step,
                children: [
                  StepGender(onChanged: (val) => gender = val, onValidationChanged: (bool p1) {  },),
                  StepName(onChanged: (f, l) {
                    firstName = f;
                    lastName = l;
                  }, onValidationChanged: (bool p1) {  },),
                  StepProfile(onImageSelected: (file) => image = file, onValidationChanged: (bool p1) {  },),
                ],
              ),
            ),

            ElevatedButton(
              onPressed: () {
                if (step < 2) {
                  setState(() => step++);
                } else {
                  submit();
                }
              },
              child: isLoading
                  ? CircularProgressIndicator(color: Colors.white)
                  : Text("Continue"),
            )
          ],
        ),
      ),
    );
  }
}
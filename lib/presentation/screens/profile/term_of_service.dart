import 'package:betrade/core/theme/app_text_style.dart';
import 'package:betrade/presentation/widget/common_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class TermsOfServicePage extends StatelessWidget {
  const TermsOfServicePage({
    super.key,
    required ScrollController scrollController,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CommonHeader(title: "Term of Service"),
            Padding(
              padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 32.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  sectionTitle("Acceptance of Terms"),
                  sectionText(
                    "By accessing or using this app, you agree to be bound by these Terms of Service. If you do not agree, please do not use the app.",
                  ),

                  sectionTitle("Use of the App"),
                  sectionText(
                    "You agree to use the app only for lawful purposes and in a way that does not violate any applicable laws or regulations.",
                  ),

                  sectionTitle("User Accounts"),
                  sectionText(
                    "You are responsible for maintaining the confidentiality of your account information and for all activities that occur under your account.",
                  ),

                  sectionTitle("Intellectual Property"),
                  sectionText(
                    "All content, features, and functionality in this app are the property of the company and are protected by applicable laws.",
                  ),

                  sectionTitle("Prohibited Activities"),
                  sectionText(
                    "You agree not to misuse the app, attempt unauthorized access, or engage in any activity that disrupts the service.",
                  ),

                  sectionTitle("Termination"),
                  sectionText(
                    "We reserve the right to suspend or terminate your account at our discretion, without prior notice, if you violate these terms.",
                  ),

                  sectionTitle("Limitation of Liability"),
                  sectionText(
                    "We are not liable for any damages or losses resulting from your use of the app.",
                  ),

                  sectionTitle("Changes to Terms"),
                  sectionText(
                    "We may update these Terms of Service at any time. Continued use of the app constitutes acceptance of the updated terms.",
                  ),

                  sectionTitle("Contact Us"),
                  sectionText(
                    "If you have any questions regarding these Terms, please contact us at support@yourapp.com.",
                  ),
                  SizedBox(height: 32.h),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget sectionTitle(String text) {
    return Padding(
      padding: EdgeInsets.only(top: 16.h, bottom: 6.h),
      child: Text(text, style: AppTextStyle.subHeadingBold),
    );
  }

  Widget sectionText(String text) {
    return Text(text, style: AppTextStyle.bodyBig);
  }
}

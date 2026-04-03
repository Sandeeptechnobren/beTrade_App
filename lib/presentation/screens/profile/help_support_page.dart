import 'package:betrade/core/theme/app_text_style.dart';
import 'package:betrade/presentation/widget/common_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key, required ScrollController scrollController});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CommonHeader(title: "Privacy Policy"),
        Padding(padding: EdgeInsets.fromLTRB(16.w,0,16.w,16.w),child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            sectionTitle("Introduction"),
            sectionText(
                "We value your privacy and are committed to protecting your personal data. This Privacy Policy explains how we collect, use, and safeguard your information when you use our app."),

            sectionTitle("Information We Collect"),
            sectionText(
                "We may collect personal information such as your name, email address, phone number, and usage data when you use our app."),

            sectionTitle("How We Use Your Information"),
            sectionText(
                "We use your data to provide and improve our services, personalize your experience, process transactions, and communicate with you."),

            sectionTitle("Data Sharing"),
            sectionText(
                "We do not sell your personal data. We may share your information with trusted third-party services for app functionality and analytics."),

            sectionTitle("Data Security"),
            sectionText(
                "We implement appropriate security measures to protect your data from unauthorized access or disclosure."),

            sectionTitle("Your Rights"),
            sectionText(
                "You have the right to access, update, or delete your personal data. You can contact us for any privacy-related requests."),

            sectionTitle("Changes to This Policy"),
            sectionText(
                "We may update this Privacy Policy from time to time. Changes will be reflected on this page."),

            sectionTitle("Contact Us"),
            sectionText(
                "If you have any questions about this Privacy Policy, please contact us at support@yourapp.com."),
          ],
        ),)
          ],
        ),
      ),
    );
  }

  Widget sectionTitle(String text) {
    return Padding(
      padding: EdgeInsets.only(top: 16.h, bottom: 6.h),
      child: Text(
        text,
        style: AppTextStyle.subHeadingBold
      ),
    );
  }

  Widget sectionText(String text) {
    return Text(
      text,
      style:AppTextStyle.bodyBig
    );
  }
}
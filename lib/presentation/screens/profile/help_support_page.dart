import 'package:betrade/presentation/widget/common_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class HelpSupportPage extends StatefulWidget {
  const HelpSupportPage({super.key});

  @override
  State<HelpSupportPage> createState() => _HelpSupportPageState();
}

class _HelpSupportPageState extends State<HelpSupportPage> {
  int selectedIndex = -1;

  final List<Map<String, dynamic>> faqs = [
    {
      "question": "How to create an account?",
      "answer": "Click on signup and enter your details to create account."
    },
    {
      "question": "How to withdraw money?",
      "answer": "Go to wallet section and click on withdraw."
    },
    {
      "question": "How to contact support?",
      "answer": "You can contact via chat or email support."
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const CommonHeader(title: "Help & Support"),

              SizedBox(height: 20.h),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 14.w),
                height: 50.h,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(15.r),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.search, color: Colors.black54),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: TextField(
                        style: const TextStyle(color: Colors.black),
                        decoration: const InputDecoration(
                          hintText: "Search help...",
                          hintStyle: TextStyle(color: Colors.grey),
                          border: InputBorder.none,
                        ),
                      ),
                    )
                  ],
                ),
              ),
              SizedBox(height: 25.h),
              Text(
                "Categories",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),

              SizedBox(height: 15.h),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _category(Icons.person, "Account"),
                  _category(Icons.account_balance_wallet, "Wallet"),
                  _category(Icons.security, "Security"),
                  _category(Icons.support_agent, "Support"),
                ],
              ),
              SizedBox(height: 30.h),
              Text(
                "FAQs",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),

              SizedBox(height: 10.h),

              ...List.generate(faqs.length, (index) {
                final faq = faqs[index];
                return _faqTile(faq, index);
              }),

              SizedBox(height: 30.h),
              Row(
                children: [
                  Expanded(
                    child: _contactCard(
                      Icons.chat,
                      "Live Chat",
                      "Instant support",
                      Colors.blue,
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: _contactCard(
                      Icons.email,
                      "Email",
                      "support@betrade.com",
                      Colors.green,
                    ),
                  ),
                ],
              ),

              SizedBox(height: 40.h),
              Container(
                height: 55.h,
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Colors.blue, Colors.purple],
                  ),
                  borderRadius: BorderRadius.circular(15.r),
                ),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                  ),
                  onPressed: () {},
                  child: Text(
                    "Raise Support Ticket",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  Widget _category(IconData icon, String text) {
    return Column(
      children: [
        Container(
          height: 60.h,
          width: 60.w,
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Icon(icon, color: Colors.black),
        ),
        SizedBox(height: 8.h),
        Text(
          text,
          style: TextStyle(color: Colors.black54, fontSize: 12.sp),
        )
      ],
    );
  }
  Widget _faqTile(Map<String, dynamic> faq, int index) {
    final isOpen = selectedIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedIndex = isOpen ? -1 : index;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: EdgeInsets.only(bottom: 10.h),
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(15.r),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    faq['question'],
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 14.sp,
                    ),
                  ),
                ),
                Icon(
                  isOpen ? Icons.remove : Icons.add,
                  color: Colors.black,
                )
              ],
            ),
            if (isOpen) ...[
              SizedBox(height: 10.h),
              Text(
                faq['answer'],
                style: TextStyle(
                  color: Colors.black54,
                  fontSize: 12.sp,
                ),
              )
            ]
          ],
        ),
      ),
    );
  }
  Widget _contactCard(
      IconData icon, String title, String subtitle, Color color) {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(15.r),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          SizedBox(height: 8.h),
          Text(
            title,
            style: TextStyle(
              color: Colors.black,
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.black54, fontSize: 12.sp),
          ),
        ],
      ),
    );
  }
}
import 'package:betrade/core/theme/app_text_style.dart';
import 'package:betrade/presentation/screens/profile/edit_profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../../data/provider/profile_provider.dart';
import '../../widget/common_header.dart';

class ProfileDetailsScreen extends StatefulWidget {
  const ProfileDetailsScreen({
    super.key,
    required ScrollController scrollController,
  });

  @override
  State<ProfileDetailsScreen> createState() => _ProfileDetailsScreenState();
}

class _ProfileDetailsScreenState extends State<ProfileDetailsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F6FA),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.only(
                left: 16.w,
                right: 16.w,
                top: 16.h,
                bottom: 0.h,
              ),
              child: CommonHeader(title: "Profile Details"),
            ),
            Expanded(
              child: Consumer<ProfileProvider>(
                builder: (context, provider, child) {
                  final profile = provider.profile;
                  if (provider.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (profile == null) {
                    return const Center(child: Text("No Profile Data"));
                  }
                  return SingleChildScrollView(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: Column(
                      children: [
                        SizedBox(height: 20.h),
                        Container(
                          padding: EdgeInsets.all(16.w),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20.r),
                            boxShadow: [
                              BoxShadow(color: Colors.black26, blurRadius: 10),
                            ],
                            image: DecorationImage(
                              image: AssetImage("assets/images/splash.png"),
                              fit: BoxFit.cover,
                            ),
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 35.r,
                                backgroundColor: Colors.white,
                                backgroundImage: profile.avatar.isNotEmpty
                                    ? NetworkImage(profile.avatar)
                                    : null,
                                child: profile.avatar.isEmpty
                                    ? Icon(Icons.person, size: 30.sp, color: Colors.grey,)
                                    : null,
                              ),
                              SizedBox(width: 15.w),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "${profile.firstName} ${profile.lastName}",
                                      style: AppTextStyle.bodyBig,
                                    ),
                                    SizedBox(height: 5.h),
                                    Text(
                                      profile.phone ?? "No phone",
                                      style: TextStyle(
                                        fontSize: 13.sp,
                                        color: Colors.white70,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => EditProfile(scrollController: ScrollController(),),
                                    ),
                                  );
                                },
                                borderRadius: BorderRadius.circular(10.r),
                                child: Container(
                                  padding: EdgeInsets.all(8.w),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(10.r),
                                  ),
                                  child: Icon(
                                    Icons.edit,
                                    color: Colors.white,
                                    size: 18.sp,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 25.h),
                        _sectionTitle("Personal Info"),
                        _buildTile(
                          Icons.person,
                          "First Name",
                          profile.firstName,
                        ),
                        _buildTile(
                          Icons.person_outline,
                          "Last Name",
                          profile.lastName,
                        ),
                        _buildTile(
                          Icons.phone,
                          "Phone",
                          profile.phone ?? "N/A",
                        ),
                        _buildTile(
                          Icons.male,
                          "Gender",
                          profile.gender ?? "N/A",
                        ),
                        SizedBox(height: 15.h),
                        _sectionTitle("Preferences"),
                        _buildTile(
                          Icons.flag,
                          "Country",
                          profile.country ?? "N/A",
                        ),
                        _buildTile(
                          Icons.currency_rupee,
                          "Currency",
                          profile.currency ?? "N/A",
                        ),
                        _buildTile(
                          Icons.language,
                          "Language",
                          profile.language ?? "N/A",
                        ),
                        SizedBox(height: 20.h),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(title, style: AppTextStyle.body),
      ),
    );
  }

  Widget _buildTile(IconData icon, String title, String value) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15.r),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6)],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              color: Colors.deepPurple.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(icon, color: Colors.deepPurple, size: 18.sp),
          ),
          SizedBox(width: 12.w),
          Expanded(child: Text(title, style: AppTextStyle.bodyBig)),
          Text(value, style: AppTextStyle.body),
        ],
      ),
    );
  }
}

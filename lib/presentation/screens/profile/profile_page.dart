import 'package:betrade/presentation/screens/portfolio/wallet_history.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.only(top: 60.h, bottom: 20.h),
            decoration: BoxDecoration(
              color: Colors.deepPurple,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30.r),
                bottomRight: Radius.circular(30.r),
              ),
            ),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 40.r,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person, size: 40.sp),
                ),
                SizedBox(height: 10.h),
                Text(
                  "User",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "technobren@gmail.com",
                  style: TextStyle(color: Colors.white70, fontSize: 13.sp),
                ),
                SizedBox(height: 10.h),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => WalletHistoryPage(),
                      ),
                    );
                  },
                  child: Text(
                    "Wallet History",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 20.h),
          Expanded(
            child: ListView(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              children: [
                buildTile(Icons.person, "Edit Profile"),
                buildTile(Icons.account_balance_wallet, "Wallet"),
                buildTile(Icons.history, "Transaction History"),
                buildTile(Icons.lock, "Change Password"),
                buildTile(Icons.help, "Help & Support"),
                buildTile(Icons.logout, "Logout"),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildTile(IconData icon, String title) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 15.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15.r),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.deepPurple),
          SizedBox(width: 15.w),
          Expanded(
            child: Text(
              title,
              style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500),
            ),
          ),
          const Icon(Icons.arrow_forward_ios, size: 16),
        ],
      ),
    );
  }
}

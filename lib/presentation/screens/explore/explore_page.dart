import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ExplorerPage extends StatefulWidget {
  const ExplorerPage({super.key});
  @override
  State<ExplorerPage> createState() => _ExplorerPageState();
}
class _ExplorerPageState extends State<ExplorerPage> {
  final List<String> categories = [
    "All",
    "Stocks",
    "Crypto",
    "Real Estate",
    "Gold",
  ];
  String selectedCategory = "All";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.only(
              top: 50.h,
              left: 16.w,
              right: 16.w,
              bottom: 20.h,
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.deepPurple, Colors.deepPurple.shade400],
              ),
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(30),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Explore",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 12.h),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(30.r),
                  ),
                  child: TextField(
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: "Search investments...",
                      hintStyle: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                      ),
                      prefixIcon: const Icon(Icons.search, color: Colors.white),
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 15.h),
          SizedBox(
            height: 40.h,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final cat = categories[index];
                final isSelected = selectedCategory == cat;

                return GestureDetector(
                  onTap: () {
                    setState(() => selectedCategory = cat);
                  },
                  child: Container(
                    margin: EdgeInsets.only(right: 10.w),
                    padding: EdgeInsets.symmetric(horizontal: 18.w),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.deepPurple : Colors.white,
                      borderRadius: BorderRadius.circular(30.r),
                      border: Border.all(
                        color: Colors.deepPurple.withOpacity(0.2),
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      cat,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.deepPurple,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          SizedBox(height: 10.h),
          Expanded(
            child: GridView.builder(
              padding: EdgeInsets.all(16.w),
              itemCount: 6,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 14.w,
                mainAxisSpacing: 14.h,
                childAspectRatio: 0.75,
              ),
              itemBuilder: (context, index) {
                return Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.deepPurple.withOpacity(0.08),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 45.h,
                        width: 45.h,
                        decoration: BoxDecoration(
                          color: Colors.deepPurple.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: const Icon(
                          Icons.trending_up,
                          color: Colors.deepPurple,
                        ),
                      ),
                      SizedBox(height: 10.h),
                      Text(
                        "Premium Plan",
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        "Returns upto 18%",
                        style: TextStyle(fontSize: 12.sp, color: Colors.grey),
                      ),
                      const Spacer(),
                      Container(
                        height: 36.h,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Colors.deepPurple,
                          borderRadius: BorderRadius.circular(30.r),
                        ),
                        child: Text(
                          "Invest Now",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

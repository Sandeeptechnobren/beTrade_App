// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:provider/provider.dart';
// import '../../data/provider/country_provider.dart';
// import '../../../data/model/country_model.dart';
// import '../screens/signin/country_picker_sheet.dart';
//
// Future<void> showCountryPicker(BuildContext context) async {
//   if (!context.mounted) return;
//
//   try {
//     final result = await showModalBottomSheet<CountryModel>(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: Colors.transparent,
//       builder: (context) {
//         return ChangeNotifierProvider.value(
//           value: Provider.of<CountryProvider>(context, listen: false),
//           child: const CountryPickerSheet(),
//         );
//       },
//     );
//
//     if (result != null && context.mounted) {
//       final provider = context.read<CountryProvider>();
//       provider.selectCountry(result);
//     }
//   } catch (e) {
//     debugPrint(" Country picker error: $e");
//   }
// }
//
// class _CountryPickerBody extends StatelessWidget {
//   const _CountryPickerBody({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return Consumer<CountryProvider>(
//       builder: (_, provider, __) {
//         return Container(
//           height: 650.h,
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
//           ),
//           child: Padding(
//             padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
//             child: Column(
//               children: [
//                 Container(
//                   width: 40.w,
//                   height: 4.h,
//                   decoration: BoxDecoration(
//                     color: Colors.grey.shade300,
//                     borderRadius: BorderRadius.circular(10.r),
//                   ),
//                 ),
//                 SizedBox(height: 12.h),
//                 Row(
//                   children: [
//                     GestureDetector(
//                       onTap: () => Navigator.pop(context),
//                       child: Container(
//                         padding: EdgeInsets.all(8.w),
//                         decoration: BoxDecoration(
//                           color: Colors.grey.shade100,
//                           shape: BoxShape.circle,
//                         ),
//                         child: Icon(Icons.arrow_back_ios_new, size: 16.sp),
//                       ),
//                     ),
//                     SizedBox(width: 12.w),
//                     Text(
//                       "Select Country Code",
//                       style: TextStyle(
//                         fontSize: 18.sp,
//                         fontWeight: FontWeight.w600,
//                         fontFamily: 'SFProRounded',
//                       ),
//                     ),
//                   ],
//                 ),
//                 SizedBox(height: 16.h),
//                 Container(
//                   decoration: BoxDecoration(
//                     color: Colors.grey.shade100,
//                     borderRadius: BorderRadius.circular(14.r),
//                   ),
//                   child: TextField(
//                     onChanged: (value) {
//                       provider.search(value);
//                     },
//                     decoration: InputDecoration(
//                       hintText: "Search Country",
//                       prefixIcon: Icon(Icons.search, color: Colors.grey),
//                       border: InputBorder.none,
//                       contentPadding: EdgeInsets.symmetric(vertical: 14.h),
//                     ),
//                   ),
//                 ),
//                 SizedBox(height: 12.h),
//                 Expanded(
//                   child: Builder(
//                     builder: (_) {
//                       if (provider.isLoading) {
//                         return const Center(child: CircularProgressIndicator());
//                       }
//                       if (provider.countries.isEmpty) {
//                         return const Center(child: Text("No countries found"));
//                       }
//                       return ListView.builder(
//                         itemCount: provider.countries.length,
//                         itemBuilder: (_, index) {
//                           final country = provider.countries[index];
//                           final isSelected =
//                               provider.selectedCountry?.phoneCode ==
//                                   country.phoneCode;
//                           return GestureDetector(
//                             onTap: () {
//                               provider.selectCountry(country);
//                               Navigator.pop(context);
//                             },
//                             child: Container(
//                               margin: EdgeInsets.symmetric(vertical: 4.h),
//                               padding: EdgeInsets.symmetric(
//                                 horizontal: 12.w,
//                                 vertical: 12.h,
//                               ),
//                               decoration: BoxDecoration(
//                                 color: isSelected
//                                     ? Colors.grey.withOpacity(0.15)
//                                     : Colors.transparent,
//                                 borderRadius: BorderRadius.circular(14.r),
//                               ),
//                               child: Row(
//                                 children: [
//                                   Text(
//                                     country.flag,
//                                     style: TextStyle(fontSize: 20.sp),
//                                   ),
//                                   SizedBox(width: 12.w),
//                                   Expanded(
//                                     child: Text(
//                                       country.name,
//                                       style: TextStyle(
//                                         fontSize: 15.sp,
//                                         fontWeight: FontWeight.w500,
//                                       ),
//                                     ),
//                                   ),
//                                   Text(
//                                     country.phoneCode,
//                                     style: TextStyle(
//                                       fontSize: 14.sp,
//                                       color: Colors.grey.shade700,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           );
//                         },
//                       );
//                     },
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../data/provider/country_provider.dart';
import '../../../data/model/country_model.dart';
import '../screens/signin/country_picker_sheet.dart';

// ✅ FIXED: Removed the redundant provider.selectCountry(result) call after
// showModalBottomSheet returns. The sheet already calls selectCountry internally
// before Navigator.pop(), so calling it again here was causing conflicts.
// Now we simply await the sheet — selection is handled inside the sheet itself.
Future<void> showCountryPicker(BuildContext context) async {
  if (!context.mounted) return;

  try {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return ChangeNotifierProvider.value(
          value: Provider.of<CountryProvider>(context, listen: false),
          child: const CountryPickerSheet(),
        );
      },
    );
  } catch (e) {
    debugPrint("Country picker error: $e");
  }
}

class _CountryPickerBody extends StatelessWidget {
  const _CountryPickerBody({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<CountryProvider>(
      builder: (_, provider, __) {
        return Container(
          height: 650.h,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            child: Column(
              children: [
                Container(
                  width: 40.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                ),
                SizedBox(height: 12.h),
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: EdgeInsets.all(8.w),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.arrow_back_ios_new, size: 16.sp),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Text(
                      "Select Country Code",
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'SFProRounded',
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16.h),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                  child: TextField(
                    onChanged: (value) {
                      provider.search(value);
                    },
                    decoration: InputDecoration(
                      hintText: "Search Country",
                      prefixIcon: const Icon(Icons.search, color: Colors.grey),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 14.h),
                    ),
                  ),
                ),
                SizedBox(height: 12.h),
                Expanded(
                  child: Builder(
                    builder: (_) {
                      if (provider.isLoading) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (provider.countries.isEmpty) {
                        return const Center(child: Text("No countries found"));
                      }
                      return ListView.builder(
                        itemCount: provider.countries.length,
                        itemBuilder: (_, index) {
                          final country = provider.countries[index];
                          final isSelected =
                              provider.selectedCountry?.phoneCode ==
                                  country.phoneCode;
                          return GestureDetector(
                            onTap: () {
                              provider.selectCountry(country);
                              Navigator.pop(context);
                            },
                            child: Container(
                              margin: EdgeInsets.symmetric(vertical: 4.h),
                              padding: EdgeInsets.symmetric(
                                horizontal: 12.w,
                                vertical: 12.h,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? Colors.grey.withOpacity(0.15)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(14.r),
                              ),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 15.r,
                                    backgroundColor: Colors.grey.shade200,
                                    backgroundImage: NetworkImage(country.flag),
                                    onBackgroundImageError: (_, __) {},
                                    child: country.flag.isEmpty
                                        ? Icon(Icons.flag, size: 16.sp)
                                        : null,
                                  ),
                                  SizedBox(width: 12.w),
                                  Expanded(
                                    child: Text(
                                      country.name,
                                      style: TextStyle(
                                        fontSize: 15.sp,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    country.phoneCode,
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      color: Colors.grey.shade700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// import 'package:betrade/presentation/widget/leading_icon.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:provider/provider.dart';
// import '../../../data/model/country_model.dart';
// import '../../../data/provider/country_provider.dart';
// class CountryPickerSheet extends StatefulWidget {
//   const CountryPickerSheet({super.key});
//   @override
//   State<CountryPickerSheet> createState() => _CountryPickerSheetState();
// }
//
// class _CountryPickerSheetState extends State<CountryPickerSheet> {
//   TextEditingController searchController = TextEditingController();
//   List<CountryModel> filteredCountries = [];
//   @override
//   void initState() {
//     super.initState();
//     Future.microtask(() async {
//       final provider = context.read<CountryProvider>();
//       await provider.fetchCountries();
//       setState(() {
//         filteredCountries = provider.countries.cast<CountryModel>();
//       });
//     });
//   }
//   void _filterCountries(String query) {
//     final provider = context.read<CountryProvider>();
//     if (query.isEmpty) {
//       setState(() {
//         filteredCountries = provider.countries.cast<CountryModel>();
//       });
//       return;
//     }
//     final lowerQuery = query.toLowerCase();
//     setState(() {
//       filteredCountries = provider.countries.where((country) {
//         return country.name.toLowerCase().contains(lowerQuery) ||
//             country.phoneCode.toLowerCase().contains(lowerQuery);
//       }).cast<CountryModel>().toList();
//     });
//   }
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       height: 650.h,
//       padding: EdgeInsets.all(16.w),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.vertical(top: Radius.circular(30.r)),
//       ),
//       child: Column(
//         children: [
//           Container(
//             width: 40.w,
//             height: 4.h,
//             decoration: BoxDecoration(
//               color: Colors.grey.shade300,
//               borderRadius: BorderRadius.circular(10.r),
//             ),
//           ),
//           SizedBox(height: 15.h),
//           Row(
//             children: [
//               LeadingIcon(),
//               SizedBox(width: 5,),
//               Text(
//                 "Select Country Code",
//                 style: TextStyle(
//                   fontSize: 16.sp,
//                   fontWeight: FontWeight.w500,
//                 ),
//               ),
//             ],
//           ),
//           SizedBox(height: 10.h),
//           Container(
//             decoration: BoxDecoration(
//               color: Color(0xFFF4F4F5),
//               borderRadius: BorderRadius.circular(12.r),
//             ),
//             child: TextField(
//               controller: searchController,
//               onChanged: _filterCountries,
//               decoration: InputDecoration(
//                 hintText: "Search Country",
//                 hintStyle: TextStyle(
//                   color: Colors.grey
//                 ),
//                 prefixIcon: const Icon(Icons.search,color: Colors.grey,),
//                 contentPadding: EdgeInsets.symmetric(vertical: 12.h),
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(12.r),
//                   borderSide: BorderSide.none
//                 ),
//                 enabledBorder: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(12.r),
//                     borderSide: BorderSide.none
//                 )
//               ),
//             ),
//           ),
//           SizedBox(height: 10.h),
//           Expanded(
//             child: Consumer<CountryProvider>(
//               builder: (context, provider, child) {
//                 if (provider.isLoading) {
//                   return const Center(child: CircularProgressIndicator());
//                 }
//                 if (provider.countries.isEmpty) {
//                   return const Center(child: Text("No countries found"));
//                 }
//                 return ListView.builder(
//                   itemCount: filteredCountries.length,
//                   itemBuilder: (context, index) {
//                     if (filteredCountries.isEmpty) {
//                       return const Center(child: Text("No matching country"));
//                     }
//                     return _countryTile(
//                       context,
//                       filteredCountries[index],
//                     );
//                   },
//                 );
//               },
//             ),
//           )
//         ],
//       ),
//     );
//   }
//   Widget _countryTile(
//       BuildContext context,
//       CountryModel country, {
//         bool isSelected = false,
//       }) {
//     return GestureDetector(
//       onTap: () {
//         Navigator.pop(context, country);
//       },
//       child: Container(
//         margin: EdgeInsets.only(bottom: 10.h),
//         padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 14.h),
//         decoration: BoxDecoration(
//           color: isSelected ? Colors.purple.shade100 : Colors.transparent,
//           borderRadius: BorderRadius.circular(12.r),
//         ),
//         child: Row(
//           children: [
//             Text(country.flag, style: TextStyle(fontSize: 18.sp)),
//             SizedBox(width: 10.w),
//             Text(
//               "${country.name} (${country.phoneCode})",
//               style: TextStyle(fontSize: 14.sp),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:provider/provider.dart';
// import '../../../data/model/country_model.dart';
// import '../../../data/provider/country_provider.dart';
//
// class CountryPickerSheet extends StatefulWidget {
//   const CountryPickerSheet({super.key});
//
//   @override
//   State<CountryPickerSheet> createState() => _CountryPickerSheetState();
// }
//
// class _CountryPickerSheetState extends State<CountryPickerSheet> {
//   final TextEditingController _searchController = TextEditingController();
//
//   @override
//   void dispose() {
//     _searchController.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       height: 650.h,
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
//       ),
//       child: Column(
//         children: [
//           // Drag handle
//           Container(
//             margin: EdgeInsets.only(top: 12.h),
//             width: 40.w,
//             height: 4.h,
//             decoration: BoxDecoration(
//               color: Colors.grey.shade300,
//               borderRadius: BorderRadius.circular(10.r),
//             ),
//           ),
//           SizedBox(height: 16.h),
//
//           // Header
//           Padding(
//             padding: EdgeInsets.symmetric(horizontal: 16.w),
//             child: Row(
//               children: [
//                 GestureDetector(
//                   onTap: () => Navigator.pop(context),
//                   child: Container(
//                     padding: EdgeInsets.all(8.w),
//                     decoration: BoxDecoration(
//                       color: Colors.grey.shade100,
//                       shape: BoxShape.circle,
//                     ),
//                     child: Icon(Icons.arrow_back_ios_new, size: 16.sp),
//                   ),
//                 ),
//                 SizedBox(width: 12.w),
//                 Text(
//                   "Select Country Code",
//                   style: TextStyle(
//                     fontSize: 18.sp,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           SizedBox(height: 16.h),
//
//           // Search bar
//           Padding(
//             padding: EdgeInsets.symmetric(horizontal: 16.w),
//             child: Container(
//               decoration: BoxDecoration(
//                 color: Colors.grey.shade100,
//                 borderRadius: BorderRadius.circular(14.r),
//               ),
//               child: TextField(
//                 controller: _searchController,
//                 onChanged: (value) {
//                   context.read<CountryProvider>().search(value);
//                 },
//                 decoration: InputDecoration(
//                   hintText: "Search Country",
//                   prefixIcon: Icon(Icons.search, color: Colors.grey),
//                   border: InputBorder.none,
//                   contentPadding: EdgeInsets.symmetric(vertical: 14.h),
//                 ),
//               ),
//             ),
//           ),
//           SizedBox(height: 12.h),
//
//           // Country list
//           Expanded(
//             child: Consumer<CountryProvider>(
//               builder: (context, provider, child) {
//                 if (provider.isLoading) {
//                   return const Center(child: CircularProgressIndicator());
//                 }
//
//                 if (provider.countries.isEmpty) {
//                   return const Center(child: Text("No countries found"));
//                 }
//
//                 return ListView.builder(
//                   itemCount: provider.countries.length,
//                   itemBuilder: (context, index) {
//                     final country = provider.countries[index];
//                     final isSelected = provider.selectedCountry?.phoneCode == country.phoneCode;
//
//                     return GestureDetector(
//                       onTap: () {
//                         provider.selectCountry(country);
//                         Navigator.pop(context, country);
//                       },
//                       child: Container(
//                         margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
//                         padding: EdgeInsets.symmetric(
//                           horizontal: 12.w,
//                           vertical: 12.h,
//                         ),
//                         decoration: BoxDecoration(
//                           color: isSelected
//                               ? Colors.purple.withOpacity(0.1)
//                               : Colors.transparent,
//                           borderRadius: BorderRadius.circular(14.r),
//                         ),
//                         child: Row(
//                           children: [
//                             Text(
//                               country.flag,
//                               style: TextStyle(fontSize: 20.sp),
//                             ),
//                             SizedBox(width: 12.w),
//                             Expanded(
//                               child: Text(
//                                 country.name,
//                                 style: TextStyle(
//                                   fontSize: 15.sp,
//                                   fontWeight: FontWeight.w500,
//                                 ),
//                               ),
//                             ),
//                             Container(
//                               padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
//                               decoration: BoxDecoration(
//                                 color: Colors.grey.shade200,
//                                 borderRadius: BorderRadius.circular(8.r),
//                               ),
//                               child: Text(
//                                 country.phoneCode,
//                                 style: TextStyle(
//                                   fontSize: 13.sp,
//                                   color: Colors.grey.shade700,
//                                   fontWeight: FontWeight.w500,
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     );
//                   },
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:provider/provider.dart';
// import '../../../core/theme/app_colors.dart';
// import '../../../data/model/country_model.dart';
// import '../../../data/provider/country_provider.dart';
//
// class CountryPickerSheet extends StatefulWidget {
//   const CountryPickerSheet({super.key});
//
//   @override
//   State<CountryPickerSheet> createState() => _CountryPickerSheetState();
// }
//
// class _CountryPickerSheetState extends State<CountryPickerSheet> {
//   final TextEditingController _searchController = TextEditingController();
//
//   @override
//   void dispose() {
//     _searchController.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final isDarkMode = Theme.of(context).brightness == Brightness.dark;
//
//     return Container(
//       height: 650.h,
//       decoration: BoxDecoration(
//         color: AppColors.cardBackgroundDynamic(context),
//         borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
//       ),
//       child: Column(
//         children: [
//           // Drag handle
//           Container(
//             margin: EdgeInsets.only(top: 12.h),
//             width: 40.w,
//             height: 4.h,
//             decoration: BoxDecoration(
//               color: AppColors.borderDynamic(context),
//               borderRadius: BorderRadius.circular(10.r),
//             ),
//           ),
//           SizedBox(height: 16.h),
//
//           // Header
//           Padding(
//             padding: EdgeInsets.symmetric(horizontal: 16.w),
//             child: Row(
//               children: [
//                 GestureDetector(
//                   onTap: () => Navigator.pop(context),
//                   child: Container(
//                     padding: EdgeInsets.all(8.w),
//                     decoration: BoxDecoration(
//                       color: AppColors.iconBgDynamic(context),
//                       shape: BoxShape.circle,
//                     ),
//                     child: Icon(
//                       Icons.arrow_back_ios_new,
//                       size: 16.sp,
//                       color: AppColors.textPrimaryDynamic(context),
//                     ),
//                   ),
//                 ),
//                 SizedBox(width: 12.w),
//                 Text(
//                   "Select Country Code",
//                   style: TextStyle(
//                     fontSize: 18.sp,
//                     fontWeight: FontWeight.w600,
//                     color: AppColors.textPrimaryDynamic(context),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           SizedBox(height: 16.h),
//
//           // Search bar
//           Padding(
//             padding: EdgeInsets.symmetric(horizontal: 16.w),
//             child: Container(
//               decoration: BoxDecoration(
//                 color: AppColors.inputFieldBgDynamic(context),
//                 borderRadius: BorderRadius.circular(14.r),
//                 border: Border.all(
//                   color: AppColors.borderDynamic(context),
//                 ),
//               ),
//               child: TextField(
//                 controller: _searchController,
//                 onChanged: (value) {
//                   context.read<CountryProvider>().search(value);
//                 },
//                 style: TextStyle(
//                   color: AppColors.textPrimaryDynamic(context),
//                 ),
//                 decoration: InputDecoration(
//                   hintText: "Search Country",
//                   hintStyle: TextStyle(
//                     color: AppColors.textSecondaryDynamic(context),
//                   ),
//                   prefixIcon: Icon(
//                     Icons.search,
//                     color: AppColors.textSecondaryDynamic(context),
//                   ),
//                   border: InputBorder.none,
//                   contentPadding: EdgeInsets.symmetric(vertical: 14.h),
//                 ),
//               ),
//             ),
//           ),
//           SizedBox(height: 12.h),
//
//           // Country list
//           Expanded(
//             child: Consumer<CountryProvider>(
//               builder: (context, provider, child) {
//                 if (provider.isLoading) {
//                   return Center(
//                     child: CircularProgressIndicator(
//                       color: AppColors.primary,
//                     ),
//                   );
//                 }
//
//                 if (provider.countries.isEmpty) {
//                   return Center(
//                     child: Text(
//                       "No countries found",
//                       style: TextStyle(
//                         color: AppColors.textSecondaryDynamic(context),
//                       ),
//                     ),
//                   );
//                 }
//
//                 return ListView.builder(
//                   itemCount: provider.countries.length,
//                   itemBuilder: (context, index) {
//                     final country = provider.countries[index];
//                     final isSelected = provider.selectedCountry?.phoneCode == country.phoneCode;
//
//                     return GestureDetector(
//                       onTap: () {
//                         provider.selectCountry(country);
//                         Navigator.pop(context, country);
//                       },
//                       child: Container(
//                         margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
//                         padding: EdgeInsets.symmetric(
//                           horizontal: 12.w,
//                           vertical: 12.h,
//                         ),
//                         decoration: BoxDecoration(
//                           color: isSelected
//                               ? AppColors.primary.withOpacity(0.15)
//                               : Colors.transparent,
//                           borderRadius: BorderRadius.circular(14.r),
//                         ),
//                         child: Row(
//                           children: [
//                             Text(
//                               country.flag,
//                               style: TextStyle(fontSize: 20.sp),
//                             ),
//                             SizedBox(width: 12.w),
//                             Expanded(
//                               child: Text(
//                                 country.name,
//                                 style: TextStyle(
//                                   fontSize: 15.sp,
//                                   fontWeight: FontWeight.w500,
//                                   color: AppColors.textPrimaryDynamic(context),
//                                 ),
//                               ),
//                             ),
//                             Container(
//                               padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
//                               decoration: BoxDecoration(
//                                 color: AppColors.buttonSecondaryDynamic(context),
//                                 borderRadius: BorderRadius.circular(8.r),
//                                 border: Border.all(
//                                   color: AppColors.borderDynamic(context),
//                                 ),
//                               ),
//                               child: Text(
//                                 country.phoneCode,
//                                 style: TextStyle(
//                                   fontSize: 13.sp,
//                                   color: AppColors.textSecondaryDynamic(context),
//                                   fontWeight: FontWeight.w500,
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     );
//                   },
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/model/country_model.dart';
import '../../../data/provider/country_provider.dart';

class CountryPickerSheet extends StatefulWidget {
  const CountryPickerSheet({super.key});

  @override
  State<CountryPickerSheet> createState() => _CountryPickerSheetState();
}

class _CountryPickerSheetState extends State<CountryPickerSheet> {
  final TextEditingController _searchController = TextEditingController();
  bool _isDisposed = false;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _isDisposed = true;
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    if (_isDisposed || !mounted) return;
    final query = _searchController.text;
    if (query != _searchQuery) {
      _searchQuery = query;
      _performSearch(query);
    }
  }

  void _performSearch(String query) {
    if (_isDisposed) return;

    try {
      final provider = Provider.of<CountryProvider>(context, listen: false);
      provider.search(query);
    } catch (e) {
      debugPrint(" Search error: $e");
    }
  }

  void _closeWithResult(CountryModel? country) {
    if (_isDisposed || !mounted) return;

    try {
      Navigator.pop(context, country);
    } catch (e) {
      debugPrint("Navigator pop error: $e");
      if (mounted) {
        Navigator.pop(context);
      }
    }
  }
  String _safeFlag(CountryModel? country) {
    return country?.flag ?? '🏳️';
  }

  String _safeName(CountryModel? country) {
    return country?.name ?? 'Unknown';
  }

  String _safePhoneCode(CountryModel? country) {
    return country?.phoneCode ?? '';
  }
  Widget _buildCountryRow(CountryModel country, bool isSelected) {
    final flag = _safeFlag(country);
    final name = _safeName(country);
    final phoneCode = _safePhoneCode(country);

    return GestureDetector(
      onTap: () {
        try {
          final provider = Provider.of<CountryProvider>(context, listen: false);
          provider.selectCountry(country);
          _closeWithResult(country);
        } catch (e) {
          debugPrint(" Country select error: $e");
        }
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
        padding: EdgeInsets.symmetric(
          horizontal: 12.w,
          vertical: 12.h,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withOpacity(0.05)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(14.r),
        ),
        child: Row(
          children: [
            ClipOval(
              child: Image.network(
                flag,
                width:23.4.w,
                height:23.4.w,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Icon(Icons.flag),
              ),
            ),
            SizedBox(width:7.8.w),
            Text(
              name,
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimaryDynamic(context),
              ),
            ),
            SizedBox(width:7.8.w),
            if (phoneCode.isNotEmpty)
              Text(
                "($phoneCode)",
                style: TextStyle(
                  fontSize: 13.sp,

                  fontWeight: FontWeight.w500,
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Container(
      height: 650.h,
      decoration: BoxDecoration(
        color: AppColors.cardBackgroundDynamic(context),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
      ),
      child: Column(
        children: [
          Container(
            margin: EdgeInsets.only(top: 12.h),
            width: 40.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: AppColors.borderDynamic(context),
              borderRadius: BorderRadius.circular(10.r),
            ),
          ),
          SizedBox(height: 16.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => _closeWithResult(null),
                  child: Container(
                    padding: EdgeInsets.all(8.w),
                    decoration: BoxDecoration(
                      color: AppColors.iconBgDynamic(context),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.arrow_back_ios_new,
                      size: 16.sp,
                      color: AppColors.textPrimaryDynamic(context),
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Text(
                  "Select Country Code",
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimaryDynamic(context),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 16.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.inputFieldBgDynamic(context),
                borderRadius: BorderRadius.circular(14.r),
                border: Border.all(
                  color: AppColors.borderDynamic(context),
                ),
              ),
              child: TextField(
                controller: _searchController,
                style: TextStyle(
                  color: AppColors.textPrimaryDynamic(context),
                ),
                decoration: InputDecoration(
                  hintText: "Search Country",
                  hintStyle: TextStyle(
                    color: AppColors.textSecondaryDynamic(context),
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color: AppColors.textSecondaryDynamic(context),
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 14.h),
                ),
              ),
            ),
          ),
          SizedBox(height: 5.h,),
          Divider(
            color: Colors.grey,
            thickness: 0.5,
          ),
          SizedBox(height: 3.h),
          Expanded(
            child: Consumer<CountryProvider>(
              builder: (context, provider, child) {
                if (_isDisposed) return const SizedBox();
                if (provider.isLoading) {
                  return Center(
                    child: CircularProgressIndicator(
                      color:AppColors.inputFieldBg,
                    ),
                  );
                }
                final countries = provider.countries;
                if (countries.isEmpty) {
                  return Center(
                    child: Text(
                      "No countries found",
                      style: TextStyle(
                        color: AppColors.textSecondaryDynamic(context),
                      ),
                    ),
                  );
                }
                return ListView.builder(
                  itemCount: countries.length,
                  itemBuilder: (context, index) {
                    if (index >= countries.length) return const SizedBox();
                    final country = countries[index];
                    if (country == null) return const SizedBox();
                    final isSelected = provider.selectedCountry?.phoneCode == country.phoneCode;
                    return _buildCountryRow(country, isSelected);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
import 'package:betrade/presentation/widget/leading_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../../data/model/country_model.dart';
import '../../../data/provider/country_provider.dart';


class CountryPickerSheet extends StatefulWidget {
  const CountryPickerSheet({super.key});

  @override
  State<CountryPickerSheet> createState() => _CountryPickerSheetState();
}

class _CountryPickerSheetState extends State<CountryPickerSheet> {
  TextEditingController searchController = TextEditingController();

  List<CountryModel> filteredCountries = [];

  @override
  void initState() {
    super.initState();

    Future.microtask(() async {
      final provider = context.read<CountryProvider>();
      await provider.fetchCountries();

      setState(() {
        filteredCountries = provider.countries.cast<CountryModel>();
      });
    });
  }

  void _filterCountries(String query) {
    final provider = context.read<CountryProvider>();

    if (query.isEmpty) {
      setState(() {
        filteredCountries = provider.countries.cast<CountryModel>();
      });
      return;
    }

    final lowerQuery = query.toLowerCase();

    setState(() {
      filteredCountries = provider.countries.where((country) {
        return country.name.toLowerCase().contains(lowerQuery) ||
            country.phoneCode.toLowerCase().contains(lowerQuery);
      }).cast<CountryModel>().toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 650.h,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30.r)),
      ),
      child: Column(
        children: [

          /// DRAG HANDLE
          Container(
            width: 40.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(10.r),
            ),
          ),

          SizedBox(height: 15.h),

          /// TITLE
          Row(
            children: [
              LeadingIcon(),
              SizedBox(width: 5,),
              Text(
                "Select Country Code",
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),

          SizedBox(height: 10.h),

          /// SEARCH FIELD
          Container(
            decoration: BoxDecoration(
              color: Color(0xFFF4F4F5),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: TextField(
              controller: searchController,
              onChanged: _filterCountries,
              decoration: InputDecoration(
                hintText: "Search Country",
                hintStyle: TextStyle(
                  color: Colors.grey
                ),
                prefixIcon: const Icon(Icons.search,color: Colors.grey,),
                contentPadding: EdgeInsets.symmetric(vertical: 12.h),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide.none
                ),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide.none
                )
              ),
            ),
          ),

          SizedBox(height: 10.h),

          /// COUNTRY LIST
          Expanded(
            child: Consumer<CountryProvider>(
              builder: (context, provider, child) {

                if (provider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (provider.countries.isEmpty) {
                  return const Center(child: Text("No countries found"));
                }

                return ListView.builder(
                  itemCount: filteredCountries.length,
                  itemBuilder: (context, index) {
                    if (filteredCountries.isEmpty) {
                      return const Center(child: Text("No matching country"));
                    }
                    return _countryTile(
                      context,
                      filteredCountries[index],
                    );
                  },
                );
              },
            ),
          )
        ],
      ),
    );
  }

  Widget _countryTile(
      BuildContext context,
      CountryModel country, {
        bool isSelected = false,
      }) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context, country);
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 10.h),
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: isSelected ? Colors.purple.shade100 : Colors.transparent,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          children: [
            Text(country.flag, style: TextStyle(fontSize: 18.sp)),
            SizedBox(width: 10.w),
            Text(
              "${country.name} (${country.phoneCode})",
              style: TextStyle(fontSize: 14.sp),
            ),
          ],
        ),
      ),
    );
  }
}
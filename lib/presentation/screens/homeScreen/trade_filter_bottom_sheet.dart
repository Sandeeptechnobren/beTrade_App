// import 'package:betrade/core/theme/app_colors.dart';
// import 'package:betrade/core/theme/app_text_style.dart';
// import 'package:betrade/presentation/widget/common_header.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:provider/provider.dart';
// import '../../../data/provider/trade_provider.dart';
// import '../../widget/purple_button.dart';
//
// class FilterBottomSheet extends StatefulWidget {
//   const FilterBottomSheet({
//     super.key,
//     required ScrollController scrollController,
//   });
//
//   @override
//   State<FilterBottomSheet> createState() => _FilterBottomSheetState();
// }
// class _FilterBottomSheetState extends State<FilterBottomSheet> {
//   int selectedTopic = 0;
//   int selectedSort = 0;
//   int selectedDate = 0;
//
//   final topics = ["All", "Trending", "Crypto", "Politics", "Sports", "Entertainment"];
//   final sortOptions = ["Relevance", "Upload Date", "Trade Count"];
//   final dateOptions = ["Any Time", "Last hour", "Today", "This Week"];
//
//   @override
//   void initState() {
//     super.initState();
//     final provider = context.read<TradeProvider>();
//     selectedTopic = topics.indexOf(provider.selectedCategory);
//     selectedSort = sortOptions.indexOf(provider.selectedSort);
//     selectedDate = dateOptions.indexOf(provider.selectedDate);
//
//     // safety fallback
//     if (selectedTopic == -1) selectedTopic = 0;
//     if (selectedSort == -1) selectedSort = 0;
//     if (selectedDate == -1) selectedDate = 0;
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final provider = context.watch<TradeProvider>();
//     return Container(
//       height: 0.85.sh,
//       decoration: BoxDecoration(
//         color: AppColors.inputFieldBgDynamic(context),
//         borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
//       ),
//       child: Column(
//         children: [
//          CommonHeader(title: "Filter Feed"),
//           Expanded(
//             child: SingleChildScrollView(
//               padding: EdgeInsets.symmetric(horizontal: 16.w),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   _title("By Topic"),
//                   _radioList(topics, selectedTopic, (val) {
//                     setState(() => selectedTopic = val);
//                   }),
//
//                   const Divider(),
//
//                   _title("Sort By"),
//                   _radioList(sortOptions, selectedSort, (val) {
//                     setState(() => selectedSort = val);
//                   }),
//
//                   const Divider(),
//
//                   _title("Upload Date"),
//                   _radioList(dateOptions, selectedDate, (val) {
//                     setState(() => selectedDate = val);
//                   }),
//
//                   SizedBox(height: 80.h),
//                 ],
//               ),
//             ),
//           ),
//
//           Padding(
//             padding: EdgeInsets.all(16.w),
//             child: Button(
//               title: "Apply",
//               isPrimary: true,
//               isLoading: provider.isLoading,
//               onPressed: () async {
//                 await provider.applyFilter(
//                   category: topics[selectedTopic],
//                   sort: sortOptions[selectedSort],
//                   date: dateOptions[selectedDate],
//                 );
//
//                 Navigator.pop(context);
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _title(String text) {
//     return Padding(
//       padding: EdgeInsets.symmetric(vertical: 8.h),
//       child: Text(text, style: AppTextStyle.smallGrey),
//     );
//   }
//
//   Widget _radioList(List<String> list, int selected, Function(int) onTap) {
//     return Column(
//       children: List.generate(list.length, (index) {
//         final isSelected = selected == index;
//
//         return InkWell(
//           onTap: () => onTap(index),
//           child: Padding(
//             padding: EdgeInsets.symmetric(vertical: 10.h),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text(list[index], style: AppTextStyle.body),
//
//                 AnimatedContainer(
//                   duration: const Duration(milliseconds: 200),
//                   width: 24.w,
//                   height: 24.w,
//                   decoration: BoxDecoration(
//                     shape: BoxShape.circle,
//                     color: isSelected
//                         ? AppColors.primary
//                         : Colors.transparent,
//                     border: Border.all(
//                       color: isSelected
//                           ? AppColors.primary
//                           : Colors.grey.shade400,
//                       width: 2,
//                     ),
//                   ),
//                   child: isSelected
//                       ? Icon(Icons.check, size: 14.sp, color: Colors.white)
//                       : null,
//                 ),
//               ],
//             ),
//           ),
//         );
//       }),
//     );
//   }
// }
// //
// // import 'package:betrade/core/theme/app_colors.dart';
// // import 'package:betrade/core/theme/app_text_style.dart';
// // import 'package:betrade/presentation/widget/common_header.dart';
// // import 'package:flutter/material.dart';
// // import 'package:flutter_screenutil/flutter_screenutil.dart';
// // import 'package:provider/provider.dart';
// // import '../../../data/provider/trade_provider.dart';
// // import '../../../data/provider/category_provider.dart';
// // import '../../widget/purple_button.dart';
// //
// // class FilterBottomSheet extends StatefulWidget {
// //   const FilterBottomSheet({
// //     super.key,
// //     required ScrollController scrollController,
// //   });
// //
// //   @override
// //   State<FilterBottomSheet> createState() => _FilterBottomSheetState();
// // }
// //
// // class _FilterBottomSheetState extends State<FilterBottomSheet> {
// //   int selectedTopic = 0;
// //   int selectedSort = 0;
// //   int selectedDate = 0;
// //
// //   final sortOptions = ["Relevance", "Upload Date", "Trade Count"];
// //   final dateOptions = ["Any Time", "Last hour", "Today", "This Week"];
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     final tradeProvider = context.watch<TradeProvider>();
// //     final categoryProvider = context.watch<CategoryProvider>();
// //
// //     // 🔥 Dynamic topics from API
// //     final topics = [
// //       "All",
// //       ...categoryProvider.categories.map((e) => e.name),
// //     ];
// //
// //     // 🔥 selected index sync
// //     selectedTopic = topics.contains(tradeProvider.selectedCategory)
// //         ? topics.indexOf(tradeProvider.selectedCategory)
// //         : 0;
// //
// //     selectedSort = sortOptions.contains(tradeProvider.selectedSort)
// //         ? sortOptions.indexOf(tradeProvider.selectedSort)
// //         : 0;
// //
// //     selectedDate = dateOptions.contains(tradeProvider.selectedDate)
// //         ? dateOptions.indexOf(tradeProvider.selectedDate)
// //         : 0;
// //
// //     return Container(
// //       height: 0.85.sh,
// //       decoration: BoxDecoration(
// //         color: AppColors.inputFieldBgDynamic(context),
// //         borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
// //       ),
// //       child: Column(
// //         children: [
// //           CommonHeader(title: "Filter Feed"),
// //
// //           Expanded(
// //             child: categoryProvider.isLoading
// //                 ? const Center(child: CircularProgressIndicator())
// //                 : SingleChildScrollView(
// //               padding: EdgeInsets.symmetric(horizontal: 16.w),
// //               child: Column(
// //                 crossAxisAlignment: CrossAxisAlignment.start,
// //                 children: [
// //                   _title("By Topic"),
// //
// //                   // 🔥 Dynamic Category List
// //                   _radioList(topics, selectedTopic, (val) {
// //                     setState(() => selectedTopic = val);
// //                   }),
// //
// //                   const Divider(),
// //
// //                   _title("Sort By"),
// //                   _radioList(sortOptions, selectedSort, (val) {
// //                     setState(() => selectedSort = val);
// //                   }),
// //
// //                   const Divider(),
// //
// //                   _title("Upload Date"),
// //                   _radioList(dateOptions, selectedDate, (val) {
// //                     setState(() => selectedDate = val);
// //                   }),
// //
// //                   SizedBox(height: 80.h),
// //                 ],
// //               ),
// //             ),
// //           ),
// //
// //           Padding(
// //             padding: EdgeInsets.all(16.w),
// //             child: Button(
// //               title: "Apply",
// //               isPrimary: true,
// //               isLoading: tradeProvider.isLoading,
// //               onPressed: () async {
// //                 await tradeProvider.applyFilter(
// //                   category: topics[selectedTopic],
// //                   sort: sortOptions[selectedSort],
// //                   date: dateOptions[selectedDate],
// //                 );
// //
// //                 Navigator.pop(context);
// //               },
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// //
// //   Widget _title(String text) {
// //     return Padding(
// //       padding: EdgeInsets.symmetric(vertical: 8.h),
// //       child: Text(text, style: AppTextStyle.smallGrey),
// //     );
// //   }
// //
// //   Widget _radioList(List<String> list, int selected, Function(int) onTap) {
// //     return Column(
// //       children: List.generate(list.length, (index) {
// //         final isSelected = selected == index;
// //
// //         return InkWell(
// //           onTap: () => onTap(index),
// //           child: Padding(
// //             padding: EdgeInsets.symmetric(vertical: 10.h),
// //             child: Row(
// //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //               children: [
// //                 Text(list[index], style: AppTextStyle.body),
// //
// //                 AnimatedContainer(
// //                   duration: const Duration(milliseconds: 200),
// //                   width: 24.w,
// //                   height: 24.w,
// //                   decoration: BoxDecoration(
// //                     shape: BoxShape.circle,
// //                     color: isSelected
// //                         ? AppColors.primary
// //                         : Colors.transparent,
// //                     border: Border.all(
// //                       color: isSelected
// //                           ? AppColors.primary
// //                           : Colors.grey.shade400,
// //                       width: 2,
// //                     ),
// //                   ),
// //                   child: isSelected
// //                       ? Icon(Icons.check, size: 14.sp, color: Colors.white)
// //                       : null,
// //                 ),
// //               ],
// //             ),
// //           ),
// //         );
// //       }),
// //     );
// //   }
// // }
// import 'package:betrade/core/theme/app_colors.dart';
// import 'package:betrade/core/theme/app_text_style.dart';
// import 'package:betrade/presentation/widget/common_header.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:provider/provider.dart';
//
// import '../../../data/provider/trade_provider.dart';
// import '../../../data/provider/category_provider.dart';
// import '../../widget/purple_button.dart';
//
// class FilterBottomSheet extends StatefulWidget {
//   const FilterBottomSheet({
//     super.key,
//     required ScrollController scrollController,
//   });
//
//   @override
//   State<FilterBottomSheet> createState() => _FilterBottomSheetState();
// }
//
// class _FilterBottomSheetState extends State<FilterBottomSheet> {
//   int selectedTopic = 0;
//   int selectedSort = 0;
//   int selectedDate = 0;
//
//   final sortOptions = ["Relevance", "Upload Date", "Trade Count"];
//   final dateOptions = ["Any Time", "Last hour", "Today", "This Week"];
//
//   @override
//   Widget build(BuildContext context) {
//     final tradeProvider = context.watch<TradeProvider>();
//     final categoryProvider = context.watch<CategoryProvider>();
//
//     /// ✅ Dynamic category list (API se)
//     final topics = [
//       "All",
//       ...categoryProvider.categories.map((e) => e.name),
//     ];
//
//     /// ✅ Selected state sync (IMPORTANT FIX)
//     selectedTopic = topics.contains(tradeProvider.selectedCategory)
//         ? topics.indexOf(tradeProvider.selectedCategory)
//         : 0;
//
//     selectedSort = sortOptions.contains(tradeProvider.selectedSort)
//         ? sortOptions.indexOf(tradeProvider.selectedSort)
//         : 0;
//
//     selectedDate = dateOptions.contains(tradeProvider.selectedDate)
//         ? dateOptions.indexOf(tradeProvider.selectedDate)
//         : 0;
//
//     return Container(
//       height: 0.85.sh,
//       decoration: BoxDecoration(
//         color: AppColors.inputFieldBgDynamic(context),
//         borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
//       ),
//       child: Column(
//         children: [
//           /// 🔥 Header
//           CommonHeader(title: "Filter Feed"),
//
//           /// 🔥 Body
//           Expanded(
//             child: categoryProvider.isLoading
//                 ? const Center(child: CircularProgressIndicator())
//                 : SingleChildScrollView(
//               padding: EdgeInsets.symmetric(horizontal: 16.w),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   /// 🔥 CATEGORY
//                   _title("By Topic"),
//                   _radioList(topics, selectedTopic, (val) {
//                     setState(() => selectedTopic = val);
//                   }),
//
//                   const Divider(),
//
//                   /// 🔥 SORT
//                   _title("Sort By"),
//                   _radioList(sortOptions, selectedSort, (val) {
//                     setState(() => selectedSort = val);
//                   }),
//
//                   const Divider(),
//
//                   /// 🔥 DATE
//                   _title("Upload Date"),
//                   _radioList(dateOptions, selectedDate, (val) {
//                     setState(() => selectedDate = val);
//                   }),
//
//                   SizedBox(height: 80.h),
//                 ],
//               ),
//             ),
//           ),
//
//           /// 🔥 APPLY BUTTON
//           Padding(
//             padding: EdgeInsets.all(16.w),
//             child: Button(
//               title: "Apply",
//               isPrimary: true,
//               isLoading: tradeProvider.isLoading,
//               onPressed: () async {
//                 await tradeProvider.applyFilter(
//                   category: topics[selectedTopic],
//                   sort: sortOptions[selectedSort],
//                   date: dateOptions[selectedDate],
//                 );
//
//                 Navigator.pop(context);
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   /// 🔥 TITLE
//   Widget _title(String text) {
//     return Padding(
//       padding: EdgeInsets.symmetric(vertical: 8.h),
//       child: Text(text, style: AppTextStyle.smallGrey),
//     );
//   }
//
//   /// 🔥 RADIO LIST
//   Widget _radioList(List<String> list, int selected, Function(int) onTap) {
//     return Column(
//       children: List.generate(list.length, (index) {
//         final isSelected = selected == index;
//
//         return InkWell(
//           onTap: () => onTap(index),
//           child: Padding(
//             padding: EdgeInsets.symmetric(vertical: 10.h),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text(list[index], style: AppTextStyle.body),
//
//                 AnimatedContainer(
//                   duration: const Duration(milliseconds: 200),
//                   width: 24.w,
//                   height: 24.w,
//                   decoration: BoxDecoration(
//                     shape: BoxShape.circle,
//                     color: isSelected
//                         ? AppColors.primary
//                         : Colors.transparent,
//                     border: Border.all(
//                       color: isSelected
//                           ? AppColors.primary
//                           : Colors.grey.shade400,
//                       width: 2,
//                     ),
//                   ),
//                   child: isSelected
//                       ? Icon(Icons.check, size: 14.sp, color: Colors.white)
//                       : null,
//                 ),
//               ],
//             ),
//           ),
//         );
//       }),
//     );
//   }
// }

import 'package:betrade/core/theme/app_colors.dart';
import 'package:betrade/core/theme/app_text_style.dart';
import 'package:betrade/presentation/widget/common_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../../data/provider/trade_provider.dart';
import '../../../data/provider/category_provider.dart';
import '../../widget/purple_button.dart';

class FilterBottomSheet extends StatefulWidget {
  const FilterBottomSheet({
    super.key,
    required ScrollController scrollController,
  });
  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  int selectedTopic = 0;
  int selectedSort = 0;
  int selectedDate = 0;
  bool isInitialized = false;
  final sortOptions = ["Relevance", "Upload Date", "Trade Count"];
  final dateOptions = ["Any Time", "Last hour", "Today", "This Week"];

  @override
  Widget build(BuildContext context) {
    final tradeProvider = context.watch<TradeProvider>();
    final categoryProvider = context.watch<CategoryProvider>();
    final topics = [
      ...categoryProvider.categories.map((e) => e.name),
    ];
    if (!isInitialized && topics.isNotEmpty) {
      selectedTopic = topics.contains(tradeProvider.selectedCategory)
          ? topics.indexOf(tradeProvider.selectedCategory)
          : 0;

      selectedSort = sortOptions.contains(tradeProvider.selectedSort)
          ? sortOptions.indexOf(tradeProvider.selectedSort)
          : 0;

      selectedDate = dateOptions.contains(tradeProvider.selectedDate)
          ? dateOptions.indexOf(tradeProvider.selectedDate)
          : 0;

      isInitialized = true;
    }

    return Container(
      height: 0.85.sh,
      decoration: BoxDecoration(
        color: AppColors.inputFieldBgDynamic(context),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      child: Column(
        children: [
          CommonHeader(title: "Filter Feed"),
          Expanded(
            child: categoryProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _title("By Topic"),
                  _radioList(topics, selectedTopic, (val) {
                    setState(() {
                      selectedTopic = val;
                    });
                  }),
                  const Divider(),
                  _title("Sort By"),
                  _radioList(sortOptions, selectedSort, (val) {
                    setState(() {
                      selectedSort = val;
                    });
                  }),
                  const Divider(),
                  _title("Upload Date"),
                  _radioList(dateOptions, selectedDate, (val) {
                    setState(() {
                      selectedDate = val;
                    });
                  }),
                  SizedBox(height: 80.h),
                ],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Button(
              title: "Apply",
              isPrimary: true,
              isLoading: tradeProvider.isLoading,
              onPressed: () async {
                await tradeProvider.applyFilter(
                  category: topics[selectedTopic],
                  sort: sortOptions[selectedSort],
                  date: dateOptions[selectedDate],
                );
                Navigator.pop(context);
              },
            ),
          ),
        ],
      ),
    );
  }
  Widget _title(String text) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Text(text, style: AppTextStyle.smallGrey),
    );
  }
  Widget _radioList(List<String> list, int selected, Function(int) onTap) {
    return Column(
      children: List.generate(list.length, (index) {
        final isSelected = selected == index;
        return InkWell(
          onTap: () => onTap(index),
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 10.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(list[index], style: AppTextStyle.body),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 24.w,
                  height: 24.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected
                        ? AppColors.primary
                        : Colors.transparent,
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primary
                          : Colors.grey.shade400,
                      width: 2,
                    ),
                  ),
                  child: isSelected
                      ? Icon(Icons.check, size: 14.sp, color: Colors.white)
                      : null,
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}
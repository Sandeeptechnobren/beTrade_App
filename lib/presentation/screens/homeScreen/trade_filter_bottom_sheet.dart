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
//
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
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       height: 0.85.sh,
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
//       ),
//       child: Column(
//         children: [
//           Padding(
//             padding: EdgeInsets.all(16.w),
//             child: CommonHeader(title: "Filter Feed"),
//           ),
//           Divider(),
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
//                   Divider(),
//                   _title("Sort By"),
//                   _radioList(sortOptions, selectedSort, (val) {
//                     setState(() => selectedSort = val);
//                   }),
//                   Divider(),
//                   _title("Upload Date"),
//                   _radioList(dateOptions, selectedDate, (val) {
//                     setState(() => selectedDate = val);
//                   }),
//                   SizedBox(height: 80.h),
//                 ],
//               ),
//             ),
//           ),
//           Padding(
//             padding: EdgeInsets.all(16.w),
//             child: Button(
//               title: "Apply",
//               isPrimary: true,
//               isLoading: context.watch<TradeProvider>().isLoading,
//               onPressed: () async {
//                 final provider = context.read<TradeProvider>();
//                 await provider.applyFilter(
//                   category: topics[selectedTopic],
//                   sort: sortOptions[selectedSort],
//                   date: dateOptions[selectedDate],
//                 );
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
//       padding: EdgeInsets.symmetric(vertical: 0.h),
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
//             padding: EdgeInsets.symmetric(vertical: 8.h),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text(list[index], style: AppTextStyle.body),
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
//                           ? const Color(0xFF7B2FF7)
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

  final topics = ["All", "Trending", "Crypto", "Politics", "Sports", "Entertainment"];
  final sortOptions = ["Relevance", "Upload Date", "Trade Count"];
  final dateOptions = ["Any Time", "Last hour", "Today", "This Week"];

  @override
  void initState() {
    super.initState();

    final provider = context.read<TradeProvider>();

    selectedTopic = topics.indexOf(provider.selectedCategory);
    selectedSort = sortOptions.indexOf(provider.selectedSort);
    selectedDate = dateOptions.indexOf(provider.selectedDate);

    // safety fallback
    if (selectedTopic == -1) selectedTopic = 0;
    if (selectedSort == -1) selectedSort = 0;
    if (selectedDate == -1) selectedDate = 0;
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TradeProvider>();

    return Container(
      height: 0.85.sh,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16.w),
            child: CommonHeader(title: "Filter Feed"),
          ),
          const Divider(),

          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _title("By Topic"),
                  _radioList(topics, selectedTopic, (val) {
                    setState(() => selectedTopic = val);
                  }),

                  const Divider(),

                  _title("Sort By"),
                  _radioList(sortOptions, selectedSort, (val) {
                    setState(() => selectedSort = val);
                  }),

                  const Divider(),

                  _title("Upload Date"),
                  _radioList(dateOptions, selectedDate, (val) {
                    setState(() => selectedDate = val);
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
              isLoading: provider.isLoading,
              onPressed: () async {
                await provider.applyFilter(
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
// import 'package:betrade/core/theme/app_colors.dart';
// import 'package:betrade/core/theme/app_text_style.dart';
// import 'package:betrade/presentation/widget/Common_header_withlogo.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:provider/provider.dart';
// import '../../../data/model/trade_model.dart';
// import '../../../data/provider/trade_provider.dart';
//
// class ExplorePage extends StatefulWidget {
//   const ExplorePage({super.key});
//
//   @override
//   State<ExplorePage> createState() => _ExplorePageState();
// }
//
// class _ExplorePageState extends State<ExplorePage> {
//   String searchQuery = "";
//
//   @override
//   void initState() {
//     super.initState();
//     Future.microtask(
//       () => Provider.of<TradeProvider>(context, listen: false).fetchTrades(),
//     );
//   }
//   @override
//   Widget build(BuildContext context) {
//     final provider = Provider.of<TradeProvider>(context);
//     List<TradeModel> filtered = provider.trades.where((item) {
//       return item.description.toLowerCase().contains(searchQuery.toLowerCase());
//     }).toList();
//     List<TradeModel> trending = filtered.take(3).toList();
//     List<TradeModel> newList = filtered.skip(3).toList();
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: GlobalAppBar(),
//       body: provider.isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : provider.error.isNotEmpty
//           ? Center(child: Text(provider.error))
//           : SingleChildScrollView(
//               padding: EdgeInsets.all(16.w),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Container(
//                     alignment: Alignment.center,
//                     padding: EdgeInsets.symmetric(horizontal: 12.w),
//                     height: 48.h,
//                     decoration: BoxDecoration(
//                       color: AppColors.inputFieldBg,
//                       borderRadius: BorderRadius.circular(12.r),
//                     ),
//                     child: TextField(
//                       onChanged: (value) {
//                         setState(() {
//                           searchQuery = value;
//                         });
//                       },
//                       decoration: InputDecoration(
//                         hintText: "Search",
//                         hintStyle: AppTextStyle.subHeading,
//                         border: InputBorder.none,
//                         icon: Icon(Icons.search, size: 25.sp),
//                       ),
//                     ),
//                   ),
//                   SizedBox(height: 20.h),
//                   if (trending.isNotEmpty) ...[
//                     Text("Trending", style: AppTextStyle.heading),
//                     SizedBox(height: 10.h),
//                     ...trending.map((item) => _buildCard(item)),
//                     SizedBox(height: 10.h),
//                   ],
//                   if (newList.isNotEmpty) ...[
//                     Text("New", style: AppTextStyle.heading),
//                     SizedBox(height: 10.h),
//                     ...newList.map((item) => _buildCard(item)),
//                   ],
//                 ],
//               ),
//             ),
//     );
//   }
//
//   Widget _buildCard(TradeModel item) {
//     return Container(
//       margin: EdgeInsets.only(bottom: 12.h),
//       padding: EdgeInsets.all(10.w),
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(12.r),
//         border: Border.all(color: Colors.grey.shade300),
//       ),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           if (item.image != null && item.image!.isNotEmpty)
//             ClipRRect(
//               borderRadius: BorderRadius.circular(8.r),
//               child: Image.network(
//                 item.image!,
//                 height: 72.h,
//                 width: 72.w,
//                 fit: BoxFit.cover,
//                 loadingBuilder: (context, child, progress) {
//                   if (progress == null) return child;
//                   return SizedBox(
//                     height: 50.h,
//                     width: 50.w,
//                     child: const Center(
//                       child: CircularProgressIndicator(strokeWidth: 2),
//                     ),
//                   );
//                 },
//                 errorBuilder: (context, error, stackTrace) {
//                   return const SizedBox();
//                 },
//               ),
//             ),
//           SizedBox(width: 10.w),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   item.description,
//                   maxLines: 2,
//                   overflow: TextOverflow.ellipsis,
//                   style: AppTextStyle.body,
//                 ),
//                 SizedBox(height: 6.h),
//                 Row(
//                   children: [
//                     Expanded(
//                       child: Text(
//                         "${item.categoryName} • ${_formatTime(item.endDate)}",
//                         style: AppTextStyle.smallGrey,
//                         overflow: TextOverflow.ellipsis,
//                       ),
//                     ),
//                     Row(
//                       children: [
//                         CircleAvatar(radius: 12.r),
//                         SizedBox(width: 2.w),
//                         CircleAvatar(radius: 12.r),
//                         SizedBox(width: 2.w),
//                         CircleAvatar(radius: 12.r),
//                         SizedBox(width: 4.w),
//                         Text("500K", style: AppTextStyle.smallGrey),
//                       ],
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   String _formatTime(String date) {
//     try {
//       final d = DateTime.parse(date);
//       final diff = DateTime.now().difference(d);
//
//       if (diff.inMinutes < 60) return "${diff.inMinutes}m";
//       if (diff.inHours < 24) return "${diff.inHours}h";
//       return "${diff.inDays}d";
//     } catch (e) {
//       return "";
//     }
//   }
// }
import 'package:betrade/core/theme/app_colors.dart';
import 'package:betrade/core/theme/app_text_style.dart';
import 'package:betrade/presentation/widget/Common_header_withlogo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../../data/model/trade_model.dart';
import '../../../data/provider/explorer_provider.dart';

class ExplorePage extends StatefulWidget {
  const ExplorePage({super.key});

  @override
  State<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  String searchQuery = "";

  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => Provider.of<ExploreProvider>(
        context,
        listen: false,
      ).fetchExploreTrades(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ExploreProvider>(context);
    List<TradeModel> filtered = provider.exploreTrades.where((item) {
      return item.description.toLowerCase().contains(searchQuery.toLowerCase());
    }).toList();

    Map<String, List<TradeModel>> groupedTrades = {};

    for (var item in filtered) {
      final category = item.categoryName.isNotEmpty
          ? item.categoryName
          : "Other";

      if (!groupedTrades.containsKey(category)) {
        groupedTrades[category] = [];
      }

      groupedTrades[category]!.add(item);
    }

    List<String> sortedKeys = groupedTrades.keys.toList();
    sortedKeys.sort((a, b) {
      if (a == "Trending") return -1;
      if (b == "Trending") return 1;
      return a.compareTo(b);
    });

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: GlobalAppBar(),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : provider.error.isNotEmpty
          ? Center(child: Text(provider.error))
          : SingleChildScrollView(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    alignment: Alignment.center,
                    padding: EdgeInsets.symmetric(horizontal: 12.w),
                    height: 48.h,
                    decoration: BoxDecoration(
                      color: AppColors.inputFieldBg,
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: TextField(
                      onChanged: (value) {
                        setState(() {
                          searchQuery = value;
                        });
                      },
                      decoration: InputDecoration(
                        hintText: "Search",
                        hintStyle: AppTextStyle.subHeading,
                        border: InputBorder.none,
                        icon: Icon(Icons.search, size: 25.sp),
                      ),
                    ),
                  ),

                  SizedBox(height: 20.h),
                  ...sortedKeys.map((categoryName) {
                    final items = groupedTrades[categoryName]!;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        /// CATEGORY TITLE
                        Text(categoryName, style: AppTextStyle.heading),
                        SizedBox(height: 10.h),

                        /// ITEMS
                        ...items.map((item) => _buildCard(item)),

                        SizedBox(height: 20.h),
                      ],
                    );
                  }),
                ],
              ),
            ),
    );
  }

  Widget _buildCard(TradeModel item) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(10.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (item.image != null && item.image!.isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(8.r),
              child: Image.network(
                item.image!,
                height: 72.h,
                width: 72.w,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, progress) {
                  if (progress == null) return child;
                  return SizedBox(
                    height: 50.h,
                    width: 50.w,
                    child: const Center(
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return const SizedBox();
                },
              ),
            ),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyle.body,
                ),
                SizedBox(height: 6.h),

                Row(
                  children: [
                    Expanded(
                      child: Text(
                        "${item.categoryName} • ${_formatTime(item.endDate)}",
                        style: AppTextStyle.smallGrey,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),

                    Row(
                      children: [
                        CircleAvatar(radius: 12.r),
                        SizedBox(width: 2.w),
                        CircleAvatar(radius: 12.r),
                        SizedBox(width: 2.w),
                        CircleAvatar(radius: 12.r),
                        SizedBox(width: 4.w),
                        Text("500K", style: AppTextStyle.smallGrey),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(String date) {
    try {
      final d = DateTime.parse(date);
      final diff = DateTime.now().difference(d);

      if (diff.inMinutes < 60) return "${diff.inMinutes}m";
      if (diff.inHours < 24) return "${diff.inHours}h";
      return "${diff.inDays}d";
    } catch (e) {
      return "";
    }
  }
}

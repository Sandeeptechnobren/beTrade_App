import 'dart:async';
import 'package:betrade/core/theme/app_colors.dart';
import 'package:betrade/core/theme/app_text_style.dart';
import 'package:betrade/presentation/widget/Common_header_withlogo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../../data/model/trade_model.dart';
import '../../../data/provider/explorer_provider.dart';
import '../../widget/common_bottom_sheet.dart';
import '../trade/trade_page.dart';

class ExplorePage extends StatefulWidget {
  const ExplorePage({super.key});

  @override
  State<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  String searchQuery = "";
  Timer? _debounce;

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
    List<TradeModel> filtered = provider.isSearching
        ? provider.searchResults
        : provider.exploreTrades;
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
      appBar: GlobalAppBar(),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : provider.error.isNotEmpty
          ? Center(child: Text(provider.error))
          : RefreshIndicator(
              color: AppColors.primary,
              backgroundColor: AppColors.whiteDynamic(context),
              onRefresh: () async {
                await Provider.of<ExploreProvider>(
                  context,
                  listen: false,
                ).fetchExploreTrades();
              },
              child: SingleChildScrollView(
                padding: EdgeInsets.all(16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      alignment: Alignment.center,
                      padding: EdgeInsets.symmetric(horizontal: 12.w),
                      height: 48.h,
                      decoration: BoxDecoration(
                        color: AppColors.whiteDynamic(context),
                        border: Border.all(color: Colors.grey, width: 0.5),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: TextField(
                        // onChanged: (value) {
                        //   setState(() {
                        //     searchQuery = value;
                        //   });
                        onChanged: (value) {
                          searchQuery = value;

                          if (_debounce?.isActive ?? false) _debounce!.cancel();

                          _debounce = Timer(
                            const Duration(milliseconds: 400),
                            () {
                              final provider = Provider.of<ExploreProvider>(
                                context,
                                listen: false,
                              );

                              if (value.trim().isEmpty) {
                                provider.clearSearch();
                              } else {
                                provider.searchTrades(value.trim());
                              }
                            },
                          );
                        },
                        decoration: InputDecoration(
                          hintText: "Search",
                          hintStyle: AppTextStyle.subHeading,
                          border: InputBorder.none,
                          suffixIcon: searchQuery.isNotEmpty
                              ? IconButton(
                                  icon: Icon(Icons.close),
                                  onPressed: () {
                                    setState(() {
                                      searchQuery = "";
                                    });
                                    Provider.of<ExploreProvider>(
                                      context,
                                      listen: false,
                                    ).clearSearch();
                                  },
                                )
                              : null,
                          prefixIcon: Padding(
                            padding: EdgeInsets.only(top: 4.h),
                            child: Icon(Icons.search, size: 22.sp),
                          ),
                          prefixIconConstraints: BoxConstraints(
                            minHeight: 20,
                            minWidth: 40,
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: 20.h),
                    ...sortedKeys.map((categoryName) {
                      final items = groupedTrades[categoryName]!;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(categoryName, style: AppTextStyle.heading),
                          SizedBox(height: 10.h),
                          ...items.map(
                            (item) => GestureDetector(
                              onTap: () {
                                print("CLICK UUID: ${item.uuid}");
                                CommonBottomSheet.open(
                                  context: context,
                                  builder: (controller) => TradePage(
                                    scrollController: controller,
                                    tradeUuid: item.uuid,
                                  ),
                                );
                              },
                              child: _buildCard(item),
                            ),
                          ),
                          SizedBox(height: 20.h),
                        ],
                      );
                    }),
                  ],
                ),
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
                        _buildMeta(item),
                        style: AppTextStyle.smallGrey,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),

                    Row(
                      children: [
                        SizedBox(
                          width: 50,
                          height: 24,
                          child: Stack(
                            children: [
                              Positioned(
                                left: 0,
                                child: CircleAvatar(
                                  radius: 12.r,
                                  // backgroundImage: NetworkImage("image1_url"),
                                ),
                              ),
                              Positioned(
                                left: 12,
                                child: CircleAvatar(
                                  radius: 12.r,
                                  // backgroundImage: NetworkImage("image2_url"),
                                ),
                              ),
                              Positioned(
                                left: 24,
                                child: CircleAvatar(
                                  radius: 12.r,
                                  // backgroundImage: NetworkImage("image3_url"),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          "500K",
                          style: AppTextStyle.smallGrey,
                        ),
                      ],
                    ),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  // String _formatTime(String date) {
  //   try {
  //     final d = DateTime.parse(date);
  //     final diff = DateTime.now().difference(d);
  //     if (diff.inSeconds < 60) {
  //       return "${diff.inSeconds}s";
  //     } else if (diff.inMinutes < 60) {
  //       return "${diff.inMinutes}m";
  //     } else if (diff.inHours < 24) {
  //       return "${diff.inHours}h";
  //     } else {
  //       return "${diff.inDays}d";
  //     }
  //   } catch (e) {
  //     return "";
  //   }
  // }
  String _formatTime(String date) {
    try {
      if (date.isEmpty) return "";
      DateTime d = DateTime.tryParse(date) ?? DateTime.parse(date);
      final now = DateTime.now();
      if (d.isAfter(now)) {
        final diff = d.difference(now);
        if (diff.inSeconds < 60) {
          return "in ${diff.inSeconds}s";
        } else if (diff.inMinutes < 60) {
          return "in ${diff.inMinutes}m";
        } else if (diff.inHours < 24) {
          return "in ${diff.inHours}h";
        } else {
          return "in ${diff.inDays}d";
        }
      }

      final diff = now.difference(d);
      if (diff.inSeconds < 60) {
        return "${diff.inSeconds}s";
      } else if (diff.inMinutes < 60) {
        return "${diff.inMinutes}m";
      } else if (diff.inHours < 24) {
        return "${diff.inHours}h";
      } else {
        return "${diff.inDays}d";
      }
    } catch (e) {
      print("Time parse error: $e, date: $date");
      return "";
    }
  }

  String _buildMeta(TradeModel item) {
    final category = item.categoryName.isNotEmpty
        ? item.categoryName
        : "Unknown";
    final time = _formatTime(item.endDate);
    if (time.isEmpty) return category;
    return "$category • $time";
  }
}

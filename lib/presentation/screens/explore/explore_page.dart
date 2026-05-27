import 'dart:async';
import 'package:betrade/core/theme/app_colors.dart';
import 'package:betrade/core/theme/app_text_style.dart';
import 'package:betrade/presentation/widget/Common_header_withlogo.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  Timer? _debounce;
  bool _isDisposed = false;
  bool _isSearchFocused = false;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  List<String> _searchHistory = [];
  bool _showSearchHistory = false;

  @override
  void initState() {
    super.initState();

    _searchFocusNode.addListener(_onFocusChange);
    _loadSearchHistory();

    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (!_isDisposed && mounted) {
        context.read<ExploreProvider>().fetchExploreTrades();
      }
    });
  }

  @override
  void dispose() {
    _isDisposed = true;
    _debounce?.cancel();
    _searchFocusNode.removeListener(_onFocusChange);
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    if (_isDisposed || !mounted) return;
    setState(() {
      _isSearchFocused = _searchFocusNode.hasFocus;
      _showSearchHistory = _isSearchFocused && _searchHistory.isNotEmpty && _searchController.text.isEmpty;
    });
  }

  Future<void> _loadSearchHistory() async {
    final prefs = await SharedPreferences.getInstance();

    _searchHistory =
        prefs.getStringList('explore_search_history') ?? [];

    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _saveToHistory(String query) async {
    if (query.trim().isEmpty) return;

    _searchHistory.remove(query);
    _searchHistory.insert(0, query);

    if (_searchHistory.length > 10) {
      _searchHistory = _searchHistory.take(10).toList();
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      'explore_search_history',
      _searchHistory,
    );

    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _clearSearchHistory() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove('explore_search_history');

    setState(() {
      _searchHistory.clear();
      _showSearchHistory = false;
    });
  }
  void _performSearch(String value) {
    if (_isDisposed) return;

    // rebuild for suffix icon
    setState(() {});

    _debounce?.cancel();

    // Clear search immediately
    if (value.trim().isEmpty) {
      context.read<ExploreProvider>().clearSearch();

      setState(() {
        _showSearchHistory =
            _isSearchFocused &&
                _searchHistory.isNotEmpty;
      });

      return;
    }

    // optional optimization
    if (value.trim().length < 2) return;

    _debounce = Timer(
      const Duration(milliseconds: 300),
          () async {
        if (_isDisposed || !mounted) return;

        try {
          final provider = context.read<ExploreProvider>();

          await provider.searchTrades(value.trim());

          if (!mounted) return;

          setState(() {
            _showSearchHistory = false;
          });
        } catch (e) {
          debugPrint("❌ Search error: $e");
        }
      },
    );
  }

  void _onSearchSubmitted(String value) async {
    if (value.trim().isEmpty) return;

    _debounce?.cancel();

    _saveToHistory(value.trim());

    try {
      final provider = context.read<ExploreProvider>();

      await provider.searchTrades(value.trim());

      if (!mounted) return;

      setState(() {
        _showSearchHistory = false;
      });

      _searchFocusNode.unfocus();
    } catch (e) {
      debugPrint("❌ Search error: $e");
    }
  }


  void _clearSearch() {
    if (_isDisposed || !mounted) return;

    _searchController.clear();

    try {
      final provider = context.read<ExploreProvider>();

      provider.clearSearch();

      setState(() {
        _showSearchHistory =
            _isSearchFocused &&
                _searchHistory.isNotEmpty;
      });
    } catch (e) {
      debugPrint("❌ Clear search error: $e");
    }
  }

  void _searchFromHistory(String query) {
    if (_isDisposed || !mounted) return;

    _searchController.text = query;
    _saveToHistory(query);

    try {
      final provider = context.read<ExploreProvider>();
      provider.searchTrades(query);
      setState(() {
        _showSearchHistory = false;
        _searchFocusNode.unfocus();
      });
    } catch (e) {
      debugPrint("❌ Search error: $e");
    }
  }

  Widget _safeNetworkImage(String? url, {double? height, double? width}) {
    if (url == null || url.isEmpty || !_isValidUrl(url)) {
      return Container(
        height: height ?? 72.h,
        width: width ?? 72.w,
        color: Colors.grey.shade300,
        child: const Icon(Icons.image_not_supported, size: 30),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(8.r),
      child: Image.network(
        url,
        height: height ?? 72.h,
        width: width ?? 72.w,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return Container(
            height: height ?? 72.h,
            width: width ?? 72.w,
            color: Colors.grey.shade300,
            child: const Center(
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          debugPrint("❌ Image error: $error");
          return Container(
            height: height ?? 72.h,
            width: width ?? 72.w,
            color: Colors.grey.shade300,
            child: const Icon(Icons.broken_image, size: 30),
          );
        },
      ),
    );
  }

  bool _isValidUrl(String url) {
    return url.startsWith('http://') || url.startsWith('https://');
  }

  Widget _buildAvatarStack() {
    return SizedBox(
      width: 50.w,
      height: 24.h,
      child: Stack(
        children: [
          Positioned(
            left: 0,
            child: CircleAvatar(
              radius: 12.r,
              backgroundColor:AppColors.whiteDynamic(context),
              child: const Icon(Icons.person, size: 12),
            ),
          ),
          Positioned(
            left: 12.w,
            child: CircleAvatar(
              radius: 12.r,
              backgroundColor:AppColors.whiteDynamic(context),
              child: const Icon(Icons.person, size: 12),
            ),
          ),
          Positioned(
            left: 24.w,
            child: CircleAvatar(
              radius: 12.r,
              backgroundColor:AppColors.whiteDynamic(context),
              child: const Icon(Icons.person, size: 12),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isDisposed) return const SizedBox();
    final provider = context.watch<ExploreProvider>();
    List<TradeModel> displayedTrades = provider.isSearchMode
        ? provider.searchResults
        : provider.exploreTrades;

    
    Map<String, List<TradeModel>> groupedTrades = {};
    for (var item in displayedTrades) {
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
      // Matches Figma: BeTrade™ + bell only, no hairline below.
      // Consistent with Rankings / Portfolio / Profile.
      appBar: GlobalAppBar(showBottomDivider: false),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : provider.error.isNotEmpty
          ? Center(child: Text(provider.error))
          : RefreshIndicator(
        color: AppColors.primary,
        backgroundColor: AppColors.whiteDynamic(context),
        onRefresh: () async {
          if (!_isDisposed && mounted) {
            await context.read<ExploreProvider>().fetchExploreTrades();
          }
        },
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
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
                      controller: _searchController,
                      focusNode: _searchFocusNode,
                      onChanged: _performSearch,
                      onSubmitted: _onSearchSubmitted,
                      decoration: InputDecoration(
                        hintText: "Search",
                        hintStyle: AppTextStyle.subHeading,
                        border: InputBorder.none,
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                          icon: Icon(Icons.close, size: 20.sp),
                          onPressed: _clearSearch,
                          tooltip: "Clear search",
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

                  // Search History Dropdown
                  if (_showSearchHistory)
                    Container(
                      margin: EdgeInsets.only(top: 8.h),
                      decoration: BoxDecoration(
                        color: AppColors.whiteDynamic(context),
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(color: Colors.grey.shade300),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Recent Searches",
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimaryDynamic(context),
                                  ),
                                ),
                                TextButton(
                                  onPressed: _clearSearchHistory,
                                  child: Text(
                                    "Clear All",
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      color: Colors.red.shade400,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Divider(height: 0, color: Colors.grey.shade300),
                          ..._searchHistory.map((query) => InkWell(
                            onTap: () => _searchFromHistory(query),
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                              child: Row(
                                children: [
                                  Icon(Icons.history, size: 18.sp, color: Colors.grey),
                                  SizedBox(width: 12.w),
                                  Expanded(
                                    child: Text(
                                      query,
                                      style: TextStyle(
                                        fontSize: 14.sp,
                                        color: AppColors.textPrimaryDynamic(context),
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.close, size: 16.sp, color: Colors.grey),
                                    onPressed: () {
                                      setState(() {
                                        _searchHistory.remove(query);
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ),
                          )),
                        ],
                      ),
                    ),
                ],
              ),

              SizedBox(height: 20.h),
              if (provider.isSearchMode && _searchController.text.isNotEmpty) ...[
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.search, size: 20.sp, color: AppColors.primary),
                      SizedBox(width: 10.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Showing results for:",
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: AppColors.primary.withOpacity(0.7),
                              ),
                            ),
                            Text(
                              "\"${_searchController.text}\"",
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                        child: Text(
                          "${provider.searchResults.length} results",
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16.h),
              ],
              if (!provider.isSearching &&
                  provider.isSearchMode &&
                  provider.searchResults.isEmpty) ...[
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 80.h),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 80.sp,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 16.h),
                        Text(
                          "No results found",
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          "Try searching with different keywords",
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Colors.grey.shade400,
                          ),
                        ),
                        SizedBox(height: 20.h),
                        OutlinedButton(
                          onPressed: _clearSearch,
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: AppColors.primary),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30.r),
                            ),
                          ),
                          child: Text(
                            "Clear Search",
                            style: TextStyle(color: AppColors.primary),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
              if (!provider.isSearchMode || provider.searchResults.isNotEmpty)
                ...sortedKeys.map((categoryName) {
                  final items = groupedTrades[categoryName]!;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (!provider.isSearchMode) ...[
                        Text(categoryName, style: AppTextStyle.heading),
                        SizedBox(height: 10.h),
                      ],
                      ...items.map(
                            (item) => GestureDetector(
                          onTap: () {
                            debugPrint("CLICK UUID: ${item.uuid}");
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
          _safeNetworkImage(item.image, height: 72.h, width: 72.w),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.description ?? "",
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
                        _buildAvatarStack(),
                        SizedBox(width: 4.w),
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
      debugPrint("Time parse error: $e, date: $date");
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

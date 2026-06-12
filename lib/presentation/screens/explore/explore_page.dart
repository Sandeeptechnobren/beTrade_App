import 'dart:async';
import 'package:betrade/core/theme/app_colors.dart';
import 'package:betrade/presentation/widget/Common_header_withlogo.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../data/model/trade_model.dart';
import '../../../data/provider/explorer_provider.dart';
import '../../../data/provider/connectivity_provider.dart';
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
  final ScrollController _scrollController = ScrollController();

  List<String> _searchHistory = [];
  bool _showSearchHistory = false;

  @override
  void initState() {
    super.initState();
    _searchFocusNode.addListener(_onFocusChange);
    _scrollController.addListener(_onScroll);
    _loadSearchHistory();

    WidgetsBinding.instance.addPostFrameCallback((_) {
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
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isDisposed || !_scrollController.hasClients) return;
    final pos = _scrollController.position;
    if (pos.pixels >= pos.maxScrollExtent - 320) {
      context.read<ExploreProvider>().loadMore();
    }
  }

  void _onFocusChange() {
    if (_isDisposed || !mounted) return;
    setState(() {
      _isSearchFocused = _searchFocusNode.hasFocus;
      _showSearchHistory = _isSearchFocused &&
          _searchHistory.isNotEmpty &&
          _searchController.text.isEmpty;
    });
  }

  Future<void> _loadSearchHistory() async {
    final prefs = await SharedPreferences.getInstance();
    _searchHistory = prefs.getStringList('explore_search_history') ?? [];
    if (mounted) setState(() {});
  }

  Future<void> _saveToHistory(String query) async {
    if (query.trim().isEmpty) return;
    _searchHistory.remove(query);
    _searchHistory.insert(0, query);
    if (_searchHistory.length > 10) {
      _searchHistory = _searchHistory.take(10).toList();
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('explore_search_history', _searchHistory);
    if (mounted) setState(() {});
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
    setState(() {});
    _debounce?.cancel();

    if (value.trim().isEmpty) {
      context.read<ExploreProvider>().clearSearch();
      setState(() {
        _showSearchHistory = _isSearchFocused && _searchHistory.isNotEmpty;
      });
      return;
    }

    if (value.trim().length < 2) return;

    _debounce = Timer(const Duration(milliseconds: 300), () async {
      if (_isDisposed || !mounted) return;
      await context.read<ExploreProvider>().searchTrades(value.trim());
      if (!mounted) return;
      setState(() => _showSearchHistory = false);
    });
  }

  void _onSearchSubmitted(String value) async {
    if (value.trim().isEmpty) return;
    _debounce?.cancel();
    _saveToHistory(value.trim());
    await context.read<ExploreProvider>().searchTrades(value.trim());
    if (!mounted) return;
    setState(() => _showSearchHistory = false);
    _searchFocusNode.unfocus();
  }

  void _clearSearch() {
    if (_isDisposed || !mounted) return;
    _searchController.clear();
    context.read<ExploreProvider>().clearSearch();
    setState(() {
      _showSearchHistory = _isSearchFocused && _searchHistory.isNotEmpty;
    });
  }

  void _searchFromHistory(String query) {
    if (_isDisposed || !mounted) return;
    _searchController.text = query;
    _saveToHistory(query);
    context.read<ExploreProvider>().searchTrades(query);
    setState(() {
      _showSearchHistory = false;
      _searchFocusNode.unfocus();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isDisposed) return const SizedBox();
    final provider = context.watch<ExploreProvider>();

    return Scaffold(
      appBar: GlobalAppBar(),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 0),
            child: _searchArea(provider),
          ),
          Expanded(child: _listArea(provider)),
        ],
      ),
    );
  }

  Widget _searchArea(ExploreProvider provider) {
    return Column(
      children: [
        Container(
          alignment: Alignment.center,
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          height: 48.h,
          decoration: BoxDecoration(
            color: AppColors.inputFieldBgDynamic(context),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: TextField(
            controller: _searchController,
            focusNode: _searchFocusNode,
            onChanged: _performSearch,
            onSubmitted: _onSearchSubmitted,
            textInputAction: TextInputAction.search,
            style: TextStyle(
              fontFamily: 'SFProRounded',
              fontSize: 16.sp,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimaryDynamic(context),
            ),
            decoration: InputDecoration(
              hintText: "Search",
              hintStyle: TextStyle(
                fontFamily: 'SFProRounded',
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondaryDynamic(context),
              ),
              filled: false,
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              disabledBorder: InputBorder.none,
              errorBorder: InputBorder.none,
              focusedErrorBorder: InputBorder.none,
              isCollapsed: true,
              contentPadding: EdgeInsets.symmetric(vertical: 12.h),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: Icon(Icons.close,
                          size: 20.sp,
                          color: AppColors.textSecondaryDynamic(context)),
                      onPressed: _clearSearch,
                      tooltip: "Clear search",
                    )
                  : null,
              prefixIcon: Padding(
                padding: EdgeInsets.only(right: 8.w),
                child: Icon(Icons.search,
                    size: 20.sp,
                    color: AppColors.textSecondaryDynamic(context)),
              ),
              prefixIconConstraints:
                  BoxConstraints(minHeight: 20.h, minWidth: 28.w),
            ),
          ),
        ),
        if (_showSearchHistory) _searchHistoryDropdown(),
      ],
    );
  }

  Widget _searchHistoryDropdown() {
    return Container(
      margin: EdgeInsets.only(top: 8.h),
      decoration: BoxDecoration(
        color: AppColors.cardBackgroundDynamic(context),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.borderDynamic(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Recent searches",
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimaryDynamic(context),
                    )),
                TextButton(
                  onPressed: _clearSearchHistory,
                  child: Text("Clear all",
                      style:
                          TextStyle(fontSize: 12.sp, color: AppColors.btnRed)),
                ),
              ],
            ),
          ),
          Divider(height: 0, color: AppColors.borderDynamic(context)),
          ..._searchHistory.map((query) => InkWell(
                onTap: () => _searchFromHistory(query),
                child: Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                  child: Row(
                    children: [
                      Icon(Icons.history,
                          size: 18.sp,
                          color: AppColors.textSecondaryDynamic(context)),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Text(query,
                            style: TextStyle(
                                fontSize: 14.sp,
                                color: AppColors.textPrimaryDynamic(context))),
                      ),
                      IconButton(
                        icon: Icon(Icons.close,
                            size: 16.sp,
                            color: AppColors.textSecondaryDynamic(context)),
                        onPressed: () =>
                            setState(() => _searchHistory.remove(query)),
                      ),
                    ],
                  ),
                ),
              )),
        ],
      ),
    );
  }

  Widget _listArea(ExploreProvider provider) {
    if (provider.isLoading && provider.trades.isEmpty) {
      return ListView(
        padding: EdgeInsets.all(16.w),
        physics: const NeverScrollableScrollPhysics(),
        children: List.generate(5, (_) => _skeletonCard()),
      );
    }

    final isOffline = context.watch<ConnectivityProvider>().isOffline;

    return RefreshIndicator(
      color: AppColors.primary,
      backgroundColor: AppColors.cardBackgroundDynamic(context),
      onRefresh: () async {
        if (!_isDisposed && mounted) {
          await context.read<ExploreProvider>().fetchExploreTrades();
        }
      },
      child: (provider.trades.isEmpty && isOffline)
          ? _stateScroll(_offlineState())
          : (provider.error.isNotEmpty && provider.trades.isEmpty)
              ? _stateScroll(_errorState())
              : provider.trades.isEmpty
                  ? _stateScroll(_emptyState(provider))
                  : provider.isSearchMode
                      ? _searchResults(provider)
                      : _trendingNewList(provider),
    );
  }

  Widget _searchResults(ExploreProvider provider) {
    return ListView.builder(
      controller: _scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 24.h),
      itemCount: provider.trades.length + 1,
      itemBuilder: (context, i) {
        if (i == provider.trades.length) return _listFooter(provider);
        return _tradeCard(provider.trades[i]);
      },
    );
  }

  Widget _trendingNewList(ExploreProvider provider) {
    final trending = provider.trades;
    return ListView(
      controller: _scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 24.h),
      children: [
        _sectionHeader("Trending"),
        SizedBox(height: 12.h),
        ...trending.map(_tradeCard),
        SizedBox(height: 24.h),
        _sectionHeader("New"),
        SizedBox(height: 12.h),
        _emptySection("No new markets yet"),
        _listFooter(provider),
      ],
    );
  }

  Widget _sectionHeader(String title) {
    return Text(
      title,
      style: TextStyle(
        fontFamily: 'SFProRounded',
        fontSize: 20.sp,
        fontWeight: FontWeight.w600,
        height: 1.6,
        color: AppColors.textPrimaryDynamic(context),
      ),
    );
  }

  Widget _emptySection(String message) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16.h),
      child: Text(
        message,
        style: TextStyle(
          fontFamily: 'SFProRounded',
          fontSize: 14.sp,
          color: AppColors.textSecondaryDynamic(context),
        ),
      ),
    );
  }

  Widget _tradeCard(TradeModel item) {
    return GestureDetector(
      onTap: () => CommonBottomSheet.open(
        context: context,
        builder: (controller) => TradePage(
          scrollController: controller,
          tradeUuid: item.uuid,
        ),
      ),
      child: _buildCard(item),
    );
  }

  Widget _stateScroll(Widget child) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [SizedBox(height: 120.h), child],
    );
  }

  Widget _listFooter(ExploreProvider provider) {
    if (provider.isLoadingMore) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 20.h),
        child: Center(
          child: SizedBox(
            width: 22.w,
            height: 22.w,
            child: CircularProgressIndicator(
                strokeWidth: 2, color: AppColors.primary),
          ),
        ),
      );
    }
    return SizedBox(height: 8.h);
  }

  Widget _buildCard(TradeModel item) {
    final category =
        item.categoryName.isNotEmpty ? item.categoryName : "Market";
    final time = _formatTime(item.endDate);

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(8.w),
      decoration: BoxDecoration(
        color: AppColors.cardBackgroundDynamic(context),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.borderDynamic(context), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _safeNetworkImage(item.image, height: 71.h, width: 72.w),
              SizedBox(width: 8.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: 'SFProRounded',
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w400,
                        color: AppColors.textPrimaryDynamic(context),
                        height: 1.4,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    _metaRow(category: category, time: time, item: item),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _metaRow(
      {required String category,
      required String time,
      required TradeModel item}) {
    final labelStyle = TextStyle(
      fontFamily: 'SFProRounded',
      fontSize: 14.sp,
      fontWeight: FontWeight.w500,
      color: AppColors.textSecondaryDynamic(context),
      height: 1.4,
    );

    return Row(
      children: [
        Flexible(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(category,
                    overflow: TextOverflow.ellipsis, style: labelStyle),
              ),
              if (time.isNotEmpty) ...[
                SizedBox(width: 4.w),
                Container(
                  width: 4.w,
                  height: 4.w,
                  decoration: BoxDecoration(
                    color: AppColors.textSecondaryDynamic(context),
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(width: 4.w),
                Text(time, style: labelStyle),
              ],
            ],
          ),
        ),
        const Spacer(),
        _socialProof(item, labelStyle),
      ],
    );
  }

  Widget _socialProof(TradeModel item, TextStyle labelStyle) {
    if (item.totalTrades <= 0) return const SizedBox.shrink();
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _avatarStack(item.traderAvatars),
        if (item.traderAvatars.isNotEmpty) SizedBox(width: 4.w),
        Text(item.totalTradesDisplay,
            style: labelStyle.copyWith(fontWeight: FontWeight.w400)),
      ],
    );
  }

  Widget _avatarStack(List<String> urls) {
    if (urls.isEmpty) return const SizedBox.shrink();
    final shown = urls.take(3).toList();
    return SizedBox(
      width: ((shown.length - 1) * 12 + 24).w,
      height: 24.h,
      child: Stack(
        children: [
          for (int i = 0; i < shown.length; i++)
            Positioned(left: (i * 12).w, child: _avatarCircle(shown[i])),
        ],
      ),
    );
  }

  Widget _avatarCircle(String url) {
    return Container(
      width: 24.w,
      height: 24.w,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.iconBgDynamic(context),
        border: Border.all(
            color: AppColors.cardBackgroundDynamic(context), width: 2),
      ),
      child: ClipOval(
        child: CachedNetworkImage(
          imageUrl: url,
          fit: BoxFit.cover,
          placeholder: (context, url) => Container(
            color: AppColors.grey200Dynamic(context),
            child: Center(
              child: SizedBox(
                width: 12.w,
                height: 12.w,
                child: const CircularProgressIndicator(strokeWidth: 1),
              ),
            ),
          ),
          errorWidget: (_, __, ___) => Icon(Icons.person,
              size: 12.sp, color: AppColors.textSecondaryDynamic(context)),
        ),
      ),
    );
  }

  Widget _skeletonCard() {
    Widget block(double w, double h) => Container(
          width: w,
          height: h,
          decoration: BoxDecoration(
            color: AppColors.grey200Dynamic(context),
            borderRadius: BorderRadius.circular(4.r),
          ),
        );
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(10.w),
      decoration: BoxDecoration(
        color: AppColors.cardBackgroundDynamic(context),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.borderDynamic(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              block(64.w, 64.w),
              SizedBox(width: 10.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    block(double.infinity, 14.h),
                    SizedBox(height: 8.h),
                    block(140.w, 12.h),
                    SizedBox(height: 12.h),
                    block(90.w, 12.h),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _emptyState(ExploreProvider provider) {
    final searching = provider.isSearchMode;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 32.w),
      child: Column(
        children: [
          Icon(searching ? Icons.search_off : Icons.explore_outlined,
              size: 72.sp, color: AppColors.textSecondaryDynamic(context)),
          SizedBox(height: 16.h),
          Text(
            searching ? "No results found" : "No markets yet",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'SFProRounded',
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimaryDynamic(context),
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            searching
                ? "Try a different keyword."
                : "Check back soon — new markets are added regularly.",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'SFProRounded',
              fontSize: 14.sp,
              color: AppColors.textSecondaryDynamic(context),
            ),
          ),
          if (searching) ...[
            SizedBox(height: 20.h),
            OutlinedButton(
              onPressed: _clearSearch,
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: AppColors.primary),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.r)),
              ),
              child: Text("Clear search",
                  style: TextStyle(color: AppColors.primary)),
            ),
          ],
        ],
      ),
    );
  }

  Widget _offlineState() => _statePlaceholder(
        icon: Icons.cloud_off,
        title: "You're offline",
        subtitle: "Connect to the internet to load markets.",
      );

  Widget _errorState() => _statePlaceholder(
        icon: Icons.error_outline_rounded,
        title: "Couldn't load markets",
        subtitle: "Something went wrong. Please try again.",
      );

  Widget _statePlaceholder({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 32.w),
      child: Column(
        children: [
          Icon(icon,
              size: 72.sp, color: AppColors.textSecondaryDynamic(context)),
          SizedBox(height: 16.h),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'SFProRounded',
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimaryDynamic(context),
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'SFProRounded',
              fontSize: 14.sp,
              color: AppColors.textSecondaryDynamic(context),
            ),
          ),
          SizedBox(height: 20.h),
          ElevatedButton(
            onPressed: () =>
                context.read<ExploreProvider>().fetchExploreTrades(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.r)),
            ),
            child: const Text("Retry", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _safeNetworkImage(String? url, {double? height, double? width}) {
    final h = height ?? 64.h;
    final w = width ?? 64.w;
    if (url == null || url.isEmpty || !_isValidUrl(url)) {
      return Container(
        height: h,
        width: w,
        decoration: BoxDecoration(
          color: AppColors.grey200Dynamic(context),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Icon(Icons.image_outlined,
            size: 28.sp, color: AppColors.textSecondaryDynamic(context)),
      );
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(8.r),
      child: CachedNetworkImage(
        imageUrl: url,
        height: h,
        width: w,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          height: h,
          width: w,
          color: AppColors.grey200Dynamic(context),
          child: Center(
            child: SizedBox(
              width: 18.w,
              height: 18.w,
              child: const CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        ),
        errorWidget: (context, url, error) => Container(
          height: h,
          width: w,
          decoration: BoxDecoration(
            color: AppColors.grey200Dynamic(context),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Icon(Icons.broken_image_outlined,
              size: 28.sp, color: AppColors.textSecondaryDynamic(context)),
        ),
      ),
    );
  }

  bool _isValidUrl(String url) =>
      url.startsWith('http://') || url.startsWith('https://');

  String _formatTime(String date) {
    try {
      if (date.isEmpty) return "";
      final d = DateTime.tryParse(date);
      if (d == null) return "";
      final now = DateTime.now();
      if (d.isAfter(now)) {
        final diff = d.difference(now);
        if (diff.inMinutes < 60) return "in ${diff.inMinutes}m";
        if (diff.inHours < 24) return "in ${diff.inHours}h";
        return "in ${diff.inDays}d";
      }
      final diff = now.difference(d);
      if (diff.inMinutes < 60) return "${diff.inMinutes}m";
      if (diff.inHours < 24) return "${diff.inHours}h";
      return "${diff.inDays}d";
    } catch (_) {
      return "";
    }
  }
}

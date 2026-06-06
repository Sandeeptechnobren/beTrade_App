import 'package:betrade/core/theme/app_colors.dart';
import 'package:betrade/core/theme/app_text_style.dart';
import 'package:betrade/presentation/widget/common_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../../data/provider/trade_provider.dart';
import '../../../data/provider/category_provider.dart';

class FilterBottomSheet extends StatefulWidget {
  const FilterBottomSheet({
    super.key,
    required ScrollController scrollController,
  });

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  int _selectedTopic = 0;
  int _selectedSort = 0;
  int _selectedDate = 0;
  bool _isDisposed = false;
  bool _isNavigating = false;
  bool _isInitialized = false;

  final List<String> _sortOptions = ["Relevance", "Upload Date", "Trade Count"];
  final List<String> _dateOptions = [
    "Any Time",
    "Last hour",
    "Today",
    "This Week"
  ];

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  // ✅ FIX #1: Safe setState with mounted check
  void _safeSetState(VoidCallback fn) {
    if (!_isDisposed && mounted) {
      setState(fn);
    }
  }

  // ✅ FIX #2: Safe navigation with guard
  void _safePop() {
    if (_isDisposed || !mounted || _isNavigating) return;
    _isNavigating = true;

    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (!_isDisposed && mounted) {
        try {
          Navigator.pop(context);
        } catch (e) {
          debugPrint("❌ Pop error: $e");
        }
      }
      _isNavigating = false;
    });
  }

  // ✅ FIX #3: Safe initialization after build
  void _initializeSelections(List<String> topics) {
    if (_isInitialized || _isDisposed || !mounted) return;

    try {
      final tradeProvider = Provider.of<TradeProvider>(context, listen: false);

      if (topics.isNotEmpty) {
        final selectedCategory = tradeProvider.selectedCategory;
        final topicIndex = topics.indexOf(selectedCategory);
        _selectedTopic = topicIndex >= 0 ? topicIndex : 0;
      }

      final sortIndex = _sortOptions.indexOf(tradeProvider.selectedSort);
      _selectedSort = sortIndex >= 0 ? sortIndex : 0;

      final dateIndex = _dateOptions.indexOf(tradeProvider.selectedDate);
      _selectedDate = dateIndex >= 0 ? dateIndex : 0;

      _isInitialized = true;
    } catch (e) {
      debugPrint("❌ Init error: $e");
      _selectedTopic = 0;
      _selectedSort = 0;
      _selectedDate = 0;
      _isInitialized = true;
    }
  }

  // ✅ FIX #4: Safe apply filter with index checks
  Future<void> _applyFilter(List<String> topics) async {
    if (_isDisposed || !mounted) return;

    // Validate indices before using
    if (topics.isEmpty) {
      debugPrint("❌ No topics available");
      _safePop();
      return;
    }

    final safeTopicIndex = _selectedTopic.clamp(0, topics.length - 1);
    final safeSortIndex = _selectedSort.clamp(0, _sortOptions.length - 1);
    final safeDateIndex = _selectedDate.clamp(0, _dateOptions.length - 1);

    try {
      final tradeProvider = Provider.of<TradeProvider>(context, listen: false);
      await tradeProvider.applyFilter(
        category: topics[safeTopicIndex],
        sort: _sortOptions[safeSortIndex],
        date: _dateOptions[safeDateIndex],
      );
    } catch (e) {
      debugPrint("❌ Apply filter error: $e");
    } finally {
      if (!_isDisposed && mounted) {
        _safePop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final tradeProvider = context.watch<TradeProvider>();
    final categoryProvider = context.watch<CategoryProvider>();

    // ✅ FIX #5: Safe topics list with empty check
    final List<String> topics = categoryProvider.categories
        .map((e) => e.name)
        .where((name) => name != null && name.isNotEmpty)
        .toList();

    // Initialize selections after first build
    if (!_isInitialized && topics.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!_isDisposed && mounted) {
          _initializeSelections(topics);
          _safeSetState(() {}); // Trigger rebuild with initialized values
        }
      });
    }

    return Container(
      height: 0.85.sh,
      decoration: BoxDecoration(
        color: AppColors.cardBackgroundDynamic(context),
        borderRadius: BorderRadius.vertical(top: Radius.circular(32.r)),
      ),
      child: Column(
        children: [
          const CommonHeader(title: "Filter Feed"),
          Expanded(
            child: categoryProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ✅ Show message if no topics available
                        if (topics.isEmpty)
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: 20.h),
                            child: Center(
                              child: Text(
                                "No categories available",
                                style: AppTextStyle.body.copyWith(
                                  color: AppColors.textSecondaryDynamic(context),
                                ),
                              ),
                            ),
                          ),
                        if (topics.isNotEmpty) ...[
                          _buildTitle("By Topic"),
                          _buildRadioList(topics, _selectedTopic, (val) {
                            _safeSetState(() {
                              _selectedTopic = val;
                            });
                          }),
                          Divider(
                            height: 24.h,
                            thickness: 1,
                            color: AppColors.borderDynamic(context),
                          ),
                        ],
                        _buildTitle("Sort By"),
                        _buildRadioList(_sortOptions, _selectedSort, (val) {
                          _safeSetState(() {
                            _selectedSort = val;
                          });
                        }),
                        Divider(
                          height: 24.h,
                          thickness: 1,
                          color: AppColors.borderDynamic(context),
                        ),
                        _buildTitle("Upload Date"),
                        _buildRadioList(_dateOptions, _selectedDate, (val) {
                          _safeSetState(() {
                            _selectedDate = val;
                          });
                        }),
                        SizedBox(height: 80.h),
                      ],
                    ),
                  ),
          ),
          Padding(
            padding: EdgeInsets.all(16.w),
            // Figma "Button" — 60 tall pill, radius 32, solid #8E10FC,
            // label 15.6/700 white. Brand color stays static in both
            // light and dark modes.
            child: SizedBox(
              width: double.infinity,
              height: 60.h,
              child: ElevatedButton(
                onPressed: tradeProvider.isLoading
                    ? null
                    : () => _applyFilter(topics),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8E10FC),
                  disabledBackgroundColor:
                      const Color(0xFF8E10FC).withValues(alpha: 0.45),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(32.r),
                  ),
                ),
                child: tradeProvider.isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        "Apply",
                        style: TextStyle(
                          fontFamily: AppTextStyle.fontFamily,
                          fontSize: 15.6.sp,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitle(String text) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Text(
        text,
        style: TextStyle(
          fontFamily: AppTextStyle.fontFamily,
          fontSize: 14.sp,
          fontWeight: FontWeight.w500,
          color: AppColors.textSecondaryDynamic(context),
        ),
      ),
    );
  }

  Widget _buildRadioList(List<String> list, int selected, Function(int) onTap) {
    // Figma-accurate checkbox — bright purple #AA45FF when selected
    // (lighter than AppColors.primary so it pops on white). Kept static
    // since it stays readable on both light and dark sheet surfaces.
    const selectedFill = Color(0xFFAA45FF);
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
                Expanded(
                  child: Text(
                    list[index],
                    style: TextStyle(
                      fontFamily: AppTextStyle.fontFamily,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimaryDynamic(context),
                    ),
                  ),
                ),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 23.4.w,
                  height: 23.4.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected ? selectedFill : Colors.transparent,
                    border: Border.all(
                      color: isSelected
                          ? selectedFill
                          : AppColors.textSecondaryDynamic(context),
                      width: 1,
                    ),
                  ),
                  child: isSelected
                      ? Icon(Icons.check, size: 15.6.sp, color: Colors.white)
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

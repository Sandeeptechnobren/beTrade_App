// import 'package:flutter/material.dart';
// import '../model/trade_model.dart';
// import '../services/trade_service.dart';
//
// class TradeProvider extends ChangeNotifier {
//   List<TradeModel> trades = [];
//   bool isLoading = false;
//   String error = '';
//   String selectedCategory = "All";
//   String selectedSort = "Relevance";
//   String selectedDate = "Any Time";
//
//   Future<void> fetchTrades() async {
//     try {
//       isLoading = true;
//       error = '';
//       notifyListeners();
//
//       List<TradeModel> allTrades = await TradeService.getTrades();
//
//       trades = _applyLocalFilter(allTrades);
//     } catch (e) {
//       error = e.toString();
//     } finally {
//       isLoading = false;
//       notifyListeners();
//     }
//   }
//
//   Future<void> applyFilter({
//     required String category,
//     required String sort,
//     required String date,
//   }) async {
//     try {
//       isLoading = true;
//       notifyListeners();
//       selectedCategory = category;
//       selectedSort = sort;
//       selectedDate = date;
//
//       List<TradeModel> allTrades = await TradeService.getTrades();
//
//       trades = _applyLocalFilter(allTrades);
//     } catch (e) {
//       error = e.toString();
//     } finally {
//       isLoading = false;
//       notifyListeners();
//     }
//   }
//
//   List<TradeModel> _applyLocalFilter(List<TradeModel> allTrades) {
//     //CATEGORY
//     if (selectedCategory != "All") {
//       allTrades = allTrades
//           .where((e) => e.categoryName == selectedCategory)
//           .toList();
//     }
//     //SORTING
//     if (selectedSort == "Upload Date") {
//       allTrades.sort((a, b) {
//         DateTime aDate = _parseDate(a.endDate);
//         DateTime bDate = _parseDate(b.endDate);
//         return bDate.compareTo(aDate);
//       });
//     }
//     // DATE FILTER
//     if (selectedDate != "Any Time") {
//       DateTime now = DateTime.now();
//       allTrades = allTrades.where((e) {
//         DateTime tradeDate = _parseDate(e.endDate);
//         if (selectedDate == "Today") {
//           return tradeDate.year == now.year &&
//               tradeDate.month == now.month &&
//               tradeDate.day == now.day;
//         } else if (selectedDate == "This Week") {
//           return tradeDate.isAfter(now.subtract(const Duration(days: 7)));
//         } else if (selectedDate == "Last hour") {
//           return tradeDate.isAfter(now.subtract(const Duration(hours: 1)));
//         }
//         return true;
//       }).toList();
//     }
//     return allTrades;
//   }
//
//   DateTime _parseDate(String date) {
//     try {
//       return DateTime.parse(date);
//     } catch (e) {
//       return DateTime(2000);
//     }
//   }
// }
import 'package:flutter/material.dart';
import '../model/trade_model.dart';
import '../services/trade_service.dart';

class TradeProvider extends ChangeNotifier {
  List<TradeModel> trades = [];
  List<TradeModel> _allTrades = [];

  bool isLoading = false;
  bool isPaginationLoading = false;

  String error = '';
  String selectedCategory = "All";
  String selectedSort = "Relevance";
  String selectedDate = "Any Time";

  int currentPage = 1;
  final int limit = 20;
  bool hasMore = true;

  //  INITIAL LOAD
  // Future<void> fetchTrades() async {
  //   try {
  //
  //     isLoading = true;
  //     error = '';
  //     currentPage = 1;
  //     hasMore = true;
  //     notifyListeners();
  //
  //     _allTrades = await TradeService.getTrades();
  //
  //     _applyPagination(reset: true);
  //   } catch (e) {
  //     error = e.toString();
  //   } finally {
  //     isLoading = false;
  //     notifyListeners();
  //   }
  // }
  Future<void> fetchTrades({bool isRefresh = false}) async {
    try {
      if (!isRefresh) {
        isLoading = true; // first load pe loader
      }

      error = '';
      currentPage = 1;
      hasMore = true;
      notifyListeners();

      _allTrades = await TradeService.getTrades(page: 1);

      // If page 1 came back empty, there's nothing more to fetch.
      if (_allTrades.isEmpty) hasMore = false;

      _applyPagination();
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // LOAD MORE — actually fetches the next server page now.
  Future<void> loadMore() async {
    if (isPaginationLoading || !hasMore) return;

    isPaginationLoading = true;
    notifyListeners();

    try {
      final nextPage = currentPage + 1;
      final newTrades = await TradeService.getTrades(page: nextPage);

      if (newTrades.isEmpty) {
        hasMore = false;
      } else {
        currentPage = nextPage;
        _allTrades.addAll(newTrades);
        _applyPagination();
      }
    } catch (e) {
      error = e.toString();
    } finally {
      isPaginationLoading = false;
      notifyListeners();
    }
  }

  //  APPLY FILTER
  Future<void> applyFilter({
    required String category,
    required String sort,
    required String date,
  }) async {
    try {
      isLoading = true;
      notifyListeners();

      selectedCategory = category;
      selectedSort = sort;
      selectedDate = date;

      currentPage = 1;
      hasMore = true;

      _allTrades = await TradeService.getTrades(page: 1);
      if (_allTrades.isEmpty) hasMore = false;

      _applyPagination();
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // Apply the current category/sort/date filter to whatever has been
  // fetched so far. Server pagination owns "is there more?", so this no
  // longer slices by page — it just exposes the filtered union.
  void _applyPagination() {
    trades = _applyLocalFilter(_allTrades);
  }

  // FILTER (same tera logic)
  List<TradeModel> _applyLocalFilter(List<TradeModel> allTrades) {
    if (selectedCategory != "All") {
      allTrades = allTrades
          .where((e) => e.categoryName == selectedCategory)
          .toList();
    }

    if (selectedSort == "Upload Date") {
      allTrades.sort((a, b) {
        DateTime aDate = _parseDate(a.endDate);
        DateTime bDate = _parseDate(b.endDate);
        return bDate.compareTo(aDate);
      });
    }

    if (selectedDate != "Any Time") {
      DateTime now = DateTime.now();
      allTrades = allTrades.where((e) {
        DateTime tradeDate = _parseDate(e.endDate);

        if (selectedDate == "Today") {
          return tradeDate.year == now.year &&
              tradeDate.month == now.month &&
              tradeDate.day == now.day;
        } else if (selectedDate == "This Week") {
          return tradeDate.isAfter(now.subtract(const Duration(days: 7)));
        } else if (selectedDate == "Last hour") {
          return tradeDate.isAfter(now.subtract(const Duration(hours: 1)));
        }
        return true;
      }).toList();
    }

    return allTrades;
  }

  DateTime _parseDate(String date) {
    try {
      return DateTime.parse(date);
    } catch (e) {
      return DateTime(2000);
    }
  }
}

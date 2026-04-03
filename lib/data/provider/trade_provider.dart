// import 'package:flutter/material.dart';
// import '../model/trade_model.dart';
// import '../services/trade_service.dart';
//
// class TradeProvider extends ChangeNotifier {
//   List<TradeModel> trades = [];
//   bool isLoading = false;
//   String error = '';
//
//   String selectedCategory = "Trending";
//   String selectedSort = "Relevance";
//   String selectedDate = "Any Time";
//
//   Future<void> fetchTrades() async {
//     try {
//       isLoading = true;
//       error = '';
//       notifyListeners();
//
//       trades = await TradeService.getTrades();
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
//
//       selectedCategory = category;
//       selectedSort = sort;
//       selectedDate = date;
//
//       List<TradeModel> allTrades = await TradeService.getTrades();
//
//       /// ✅ CATEGORY FILTER
//       if (category != "Trending") {
//         allTrades = allTrades
//             .where((e) => e.categoryName == category)
//             .toList();
//       }
//
//       /// ✅ SORT (USING endDate)
//       if (sort == "Upload Date") {
//         allTrades.sort((a, b) {
//           DateTime aDate = _parseDate(a.endDate);
//           DateTime bDate = _parseDate(b.endDate);
//           return bDate.compareTo(aDate);
//         });
//       }
//
//       /// ❌ REMOVE TRADE COUNT SORT (not available)
//
//       /// ✅ DATE FILTER
//       if (date != "Any Time") {
//         DateTime now = DateTime.now();
//
//         allTrades = allTrades.where((e) {
//           DateTime tradeDate = _parseDate(e.endDate);
//
//           if (date == "Today") {
//             return tradeDate.year == now.year &&
//                 tradeDate.month == now.month &&
//                 tradeDate.day == now.day;
//           } else if (date == "This Week") {
//             return tradeDate.isAfter(now.subtract(const Duration(days: 7)));
//           } else if (date == "Last hour") {
//             return tradeDate.isAfter(
//                 now.subtract(const Duration(hours: 1)));
//           }
//           return true;
//         }).toList();
//       }
//
//       trades = allTrades;
//     } catch (e) {
//       error = e.toString();
//     } finally {
//       isLoading = false;
//       notifyListeners();
//     }
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
// import 'package:flutter/material.dart';
// import '../model/trade_model.dart';
// import '../services/trade_service.dart';
//
// class TradeProvider extends ChangeNotifier {
//   List<TradeModel> trades = [];
//   bool isLoading = false;
//   String error = '';
//
//   /// ✅ DEFAULTS
//   String selectedCategory = "All";
//   String selectedSort = "Relevance";
//   String selectedDate = "Any Time";
//
//   /// ✅ FETCH ALL TRADES (INITIAL LOAD)
//   Future<void> fetchTrades() async {
//     try {
//       isLoading = true;
//       error = '';
//       notifyListeners();
//
//       trades = await TradeService.getTrades();
//     } catch (e) {
//       error = e.toString();
//     } finally {
//       isLoading = false;
//       notifyListeners();
//     }
//   }
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
//       List<TradeModel> allTrades = await TradeService.getTrades();
//       if (category != "All") {
//         allTrades = allTrades
//             .where((e) => e.categoryName == category)
//             .toList();
//       }
//
//       /// =========================
//       /// ✅ SORTING
//       /// =========================
//       if (sort == "Upload Date") {
//         allTrades.sort((a, b) {
//           DateTime aDate = _parseDate(a.endDate);
//           DateTime bDate = _parseDate(b.endDate);
//           return bDate.compareTo(aDate); // latest first
//         });
//       }
//
//       /// =========================
//       /// ✅ DATE FILTER
//       /// =========================
//       if (date != "Any Time") {
//         DateTime now = DateTime.now();
//
//         allTrades = allTrades.where((e) {
//           DateTime tradeDate = _parseDate(e.endDate);
//
//           if (date == "Today") {
//             return tradeDate.year == now.year &&
//                 tradeDate.month == now.month &&
//                 tradeDate.day == now.day;
//           } else if (date == "This Week") {
//             return tradeDate.isAfter(
//               now.subtract(const Duration(days: 7)),
//             );
//           } else if (date == "Last hour") {
//             return tradeDate.isAfter(
//               now.subtract(const Duration(hours: 1)),
//             );
//           }
//
//           return true;
//         }).toList();
//       }
//       trades = allTrades;
//     } catch (e) {
//       error = e.toString();
//     } finally {
//       isLoading = false;
//       notifyListeners();
//     }
//   }
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
  bool isLoading = false;
  String error = '';
  String selectedCategory = "All";
  String selectedSort = "Relevance";
  String selectedDate = "Any Time";

  Future<void> fetchTrades() async {
    try {
      isLoading = true;
      error = '';
      notifyListeners();

      List<TradeModel> allTrades = await TradeService.getTrades();

      trades = _applyLocalFilter(allTrades);
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

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

      List<TradeModel> allTrades = await TradeService.getTrades();

      trades = _applyLocalFilter(allTrades);
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  List<TradeModel> _applyLocalFilter(List<TradeModel> allTrades) {
    //CATEGORY
    if (selectedCategory != "All") {
      allTrades = allTrades
          .where((e) => e.categoryName == selectedCategory)
          .toList();
    }
    //SORTING
    if (selectedSort == "Upload Date") {
      allTrades.sort((a, b) {
        DateTime aDate = _parseDate(a.endDate);
        DateTime bDate = _parseDate(b.endDate);
        return bDate.compareTo(aDate);
      });
    }
    // DATE FILTER
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

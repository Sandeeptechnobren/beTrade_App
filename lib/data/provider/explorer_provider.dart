// import 'package:flutter/material.dart';
// import '../model/trade_model.dart';
// import '../services/explorer_service.dart';
// import '../services/trade_service.dart';
// // class ExploreProvider extends ChangeNotifier {
// //   List<TradeModel> exploreTrades = [];
// //   bool isLoading = false;
// //   String error = "";
// //
// //   Future<void> fetchExploreTrades() async {
// //     try {
// //       isLoading = true;
// //       notifyListeners();
// //       exploreTrades = await TradeService.getAllTrades();
// //       isLoading = false;
// //       notifyListeners();
// //     } catch (e) {
// //       isLoading = false;
// //       error = e.toString();
// //       notifyListeners();
// //     }
// //   }
// //
// //   Future<void> searchTrades(String query) async {
// //     try {
// //       isLoading = true;
// //       notifyListeners();
// //       exploreTrades = await ExploreService.searchTrades(query);
// //       error = "";
// //     } catch (e) {
// //       exploreTrades = [];
// //       error = e.toString();
// //     } finally {
// //       isLoading = false;
// //       notifyListeners();
// //     }
// //   }
// // }
// class ExploreProvider extends ChangeNotifier {
//   List<TradeModel> exploreTrades = [];
//   List<TradeModel> searchResults = [];
//
//   bool isLoading = false;
//   bool isSearching = false;
//   String error = "";
//
//   Future<void> fetchExploreTrades() async {
//     try {
//       isLoading = true;
//       notifyListeners();
//
//       exploreTrades = await TradeService.getAllTrades();
//
//       isLoading = false;
//       notifyListeners();
//     } catch (e) {
//       isLoading = false;
//       error = e.toString();
//       notifyListeners();
//     }
//   }
//
//   Future<void> searchTrades(String query) async {
//     try {
//       isSearching = true;
//       notifyListeners();
//       searchResults = await ExploreService.searchTrades(query);
//       notifyListeners();
//     } catch (e) {
//       error = e.toString();
//       notifyListeners();
//     }
//   }
//
//   void clearSearch() {
//     isSearching = false;
//     searchResults.clear();
//     notifyListeners();
//   }
// }
// import 'package:flutter/material.dart';
// import '../model/trade_model.dart';
// import '../services/explorer_service.dart';
// import '../services/trade_service.dart';
//
// class ExploreProvider extends ChangeNotifier {
//   List<TradeModel> exploreTrades = [];
//   List<TradeModel> searchResults = [];
//
//   bool isLoading = false;
//   bool isSearching = false;
//   String error = "";
//
//   Future<void> fetchExploreTrades() async {
//     try {
//       isLoading = true;
//       error = "";
//       notifyListeners();
//
//       exploreTrades = await TradeService.getAllTrades();
//
//     } catch (e) {
//       error = e.toString();
//     } finally {
//       isLoading = false;
//       notifyListeners();
//     }
//   }
//
//   Future<void> searchTrades(String query) async {
//     try {
//       isSearching = true;
//       error = "";
//       notifyListeners();
//
//       searchResults = await ExploreService.searchTrades(query);
//
//     } catch (e) {
//       error = e.toString();
//     } finally {
//       isSearching = false;
//       notifyListeners();
//     }
//   }
//   void clearSearch() {
//     isSearching = false;
//     searchResults.clear();
//     notifyListeners();
//   }
// }

import 'package:flutter/material.dart';
import '../model/trade_model.dart';
import '../services/explorer_service.dart';
import '../services/trade_service.dart';

class ExploreProvider extends ChangeNotifier {
  List<TradeModel> exploreTrades = [];
  List<TradeModel> searchResults = [];

  bool isLoading = false;
  bool isSearching = false;
  String error = "";

  String _lastSearchQuery = "";

  Future<void> fetchExploreTrades() async {
    try {
      isLoading = true;
      error = "";
      notifyListeners();

      exploreTrades = await TradeService.getAllTrades();

    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> searchTrades(String query) async {
    if (query.trim().isEmpty) {
      return;
    }

    try {
      isSearching = true;
      error = "";
      _lastSearchQuery = query;
      notifyListeners();

      final results = await ExploreService.searchTrades(query);
      if (_lastSearchQuery == query) {
        searchResults = results;
      }

    } catch (e) {
      error = e.toString();
    } finally {
      isSearching = false;
      notifyListeners();
    }
  }

  void clearSearch() {
    isSearching = false;
    searchResults = [];
    _lastSearchQuery = "";
    notifyListeners();
  }

  Future<void> refreshSearch() async {
    if (_lastSearchQuery.isNotEmpty) {
      await searchTrades(_lastSearchQuery);
    }
  }
}
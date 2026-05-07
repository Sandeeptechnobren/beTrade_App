//
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
//   String _lastSearchQuery = "";
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
//     if (query.trim().isEmpty) {
//       return;
//     }
//
//     try {
//       isSearching = true;
//       error = "";
//       _lastSearchQuery = query;
//       notifyListeners();
//
//       final results = await ExploreService.searchTrades(query);
//       if (_lastSearchQuery == query) {
//         searchResults = results;
//       }
//
//     } catch (e) {
//       error = e.toString();
//     } finally {
//       isSearching = false;
//       notifyListeners();
//     }
//   }
//
//   void clearSearch() {
//     isSearching = false;
//     searchResults = [];
//     _lastSearchQuery = "";
//     notifyListeners();
//   }
//
//   Future<void> refreshSearch() async {
//     if (_lastSearchQuery.isNotEmpty) {
//       await searchTrades(_lastSearchQuery);
//     }
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

  // SEARCH API LOADING
  bool isSearching = false;

  // SEARCH ACTIVE OR NOT
  bool isSearchMode = false;

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
      clearSearch();
      return;
    }

    try {
      isSearching = true;
      isSearchMode = true;

      error = "";
      _lastSearchQuery = query;

      notifyListeners();

      final results = await ExploreService.searchTrades(query);

      // Prevent old API response overwrite
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
    isSearchMode = false;

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
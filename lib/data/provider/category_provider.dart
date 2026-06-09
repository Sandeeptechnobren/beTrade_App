// import 'package:flutter/material.dart';
// import '../model/category_model.dart';
// import '../services/category_service.dart';
//
// class CategoryProvider extends ChangeNotifier {
//   List<CategoryModel> categories = [];
//   bool isLoading = false;
//   String error = "";
//
//   Future<void> fetchCategories() async {
//     isLoading = true;
//     error = "";
//     notifyListeners();
//
//     try {
//       categories = await CategoryService.getCategories();
//
//       if (categories.isEmpty) {
//         error = "No data found";
//       }
//     } catch (e) {
//       error = "Something went wrong";
//     }
//
//     isLoading = false;
//     notifyListeners();
//   }
// }

import 'dart:convert';
import 'package:flutter/material.dart';
import '../model/category_model.dart';
import '../services/category_service.dart';
import '../services/local_storage.dart';

class CategoryProvider extends ChangeNotifier {
  List<CategoryModel> _categories = [];
  bool _isLoading = false;
  String _error = "";
  bool _isDisposed = false;  
  bool _isFetching = false;   

  // Getters
  List<CategoryModel> get categories => List.unmodifiable(_categories);
  bool get isLoading => _isLoading;
  String get error => _error;

  CategoryProvider() {
    _loadCachedCategories();
  }

  void _loadCachedCategories() {
    final cached = LocalStorage.getCachedData("categories");
    if (cached != null) {
      try {
        final List<dynamic> decoded = jsonDecode(cached);
        _categories = decoded.map((e) => CategoryModel.fromJson(e)).toList();
        _safeNotifyListeners();
      } catch (e) {
        debugPrint("Error decoding cached categories: $e");
      }
    }
  }

  // Safe index access
  CategoryModel? getCategoryAtIndex(int index) {
    if (!_isDisposed && index >= 0 && index < _categories.length) {
      return _categories[index];
    }
    return null;
  }

  Future<void> fetchCategories() async {
    if (_isDisposed || _isFetching) return;

    _isFetching = true;
    if (_categories.isEmpty) {
      _isLoading = true;
    }
    _error = "";
    _safeNotifyListeners();

    try {
      final result = await CategoryService.getCategories();

      if (_isDisposed) return;

      if (result.isNotEmpty) {
        _categories = result;
        LocalStorage.cacheData("categories", jsonEncode(_categories.map((e) => e.toJson()).toList()));
      }

      if (_categories.isEmpty && !_isDisposed) {
        _error = "No data found";
      } else {
        _error = "";
      }

    } catch (e, stackTrace) {
      if (_isDisposed) return;

      debugPrint("❌ CategoryProvider Error: $e");
      // Don't clear categories on error if we have cached ones
      if (_categories.isEmpty) {
        _error = "Something went wrong. Please try again.";
      }
    } finally {
      if (!_isDisposed) {
        _isLoading = false;
        _isFetching = false;
        _safeNotifyListeners();
      }
    }
  }

  // ✅ COMPLETELY SAFE notifyListeners
  void _safeNotifyListeners() {
    // Check BOTH conditions
    if (!_isDisposed && hasListeners) {
      try {
        notifyListeners();
      } catch (e) {
        // Fallback safety
        debugPrint("⚠️ notifyListeners failed: $e");
      }
    }
  }

  // ✅ Reset method for retry scenarios
  void reset() {
    if (_isDisposed) return;
    _categories = [];
    _isLoading = false;
    _error = "";
    _isFetching = false;
    _safeNotifyListeners();
  }

  @override
  void dispose() {
    _isDisposed = true;
    _isFetching = false;
    _categories = [];
    super.dispose();
  }
}
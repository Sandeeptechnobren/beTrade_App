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

import 'package:flutter/material.dart';
import '../model/category_model.dart';
import '../services/category_service.dart';

class CategoryProvider extends ChangeNotifier {
  List<CategoryModel> _categories = [];
  bool _isLoading = false;
  String _error = "";
  bool _isDisposed = false;  // ✅ Added
  bool _isFetching = false;   // ✅ Prevent concurrent calls

  // Getters
  List<CategoryModel> get categories => List.unmodifiable(_categories);
  bool get isLoading => _isLoading;
  String get error => _error;

  // Safe index access
  CategoryModel? getCategoryAtIndex(int index) {
    if (!_isDisposed && index >= 0 && index < _categories.length) {
      return _categories[index];
    }
    return null;
  }

  Future<void> fetchCategories() async {
    // ✅ Check both conditions
    if (_isDisposed || _isFetching) return;

    _isFetching = true;
    _isLoading = true;
    _error = "";
    _safeNotifyListeners();

    try {
      final result = await CategoryService.getCategories();

      // ✅ CRITICAL: Check disposed AFTER async operation
      if (_isDisposed) return;

      // ✅ Null safety
      _categories = result ?? [];

      // ✅ Error message update
      if (_categories.isEmpty && !_isDisposed) {
        _error = "No data found";
      } else {
        _error = "";
      }

    } catch (e, stackTrace) {
      // ✅ Check disposed before updating state
      if (_isDisposed) return;

      debugPrint("❌ CategoryProvider Error: $e");
      debugPrint("📚 StackTrace: $stackTrace");
      _error = "Something went wrong. Please try again.";
      _categories = [];
    } finally {
      // ✅ Check disposed before final state update
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
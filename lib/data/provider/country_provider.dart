// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import '../model/country_model.dart';
// class CountryProvider with ChangeNotifier {
//   List<CountryModel> _countries = [];
//   List<CountryModel> _filtered = [];
//   bool isLoading = false;
//   List<CountryModel> get countries => _filtered;
//   CountryModel? selectedCountry;
//   bool _isFetched = false;
//   Future<void> fetchCountries() async {
//     if (_isFetched) return;
//     try {
//       isLoading = true;
//       notifyListeners();
//       final url = Uri.parse("https://api.easycoders.in/projects/betrade/public/api/countries");
//       final response = await http.get(url);
//       if (response.statusCode == 200) {
//         _isFetched = true;
//         final data = jsonDecode(response.body);
//         _countries = (data['data'] as List).map((e) => CountryModel.fromJson(e)).toList();
//         _filtered = _countries;
//         selectedCountry = _countries.isNotEmpty ? _countries.first : null;
//       }
//     } catch (e) {
//       debugPrint("Error: $e");
//     }
//     isLoading = false;
//     notifyListeners();
//   }
//   void search(String value) {
//     if (value.isEmpty) {
//       _filtered = _countries;
//     } else {
//       _filtered = _countries.where((e) {return e.name.toLowerCase().contains(value.toLowerCase()) || e.phoneCode.contains(value);
//       }).toList();
//     }
//     notifyListeners();
//   }
//   void selectCountry(CountryModel country) {
//     selectedCountry = country;
//     notifyListeners();
//   }
// }

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../model/country_model.dart';

class CountryProvider with ChangeNotifier {
  List<CountryModel> _countries = [];
  List<CountryModel> _filtered = [];
  bool _isLoading = false;
  bool _isFetched = false;
  bool _isDisposed = false;
  CountryModel? _selectedCountry;

  List<CountryModel> get countries => List.unmodifiable(_filtered);
  bool get isLoading => _isLoading;
  CountryModel? get selectedCountry => _selectedCountry;
  bool get isFetched => _isFetched;

  void _safeNotify() {
    if (!_isDisposed && hasListeners) {
      notifyListeners();  // ✅ Try-catch ki zaroorat nahi
    }
  }

  Future<void> fetchCountries() async {
    if (_isDisposed || _isFetched || _isLoading) return;

    try {
      _isLoading = true;
      _safeNotify();

      final url = Uri.parse(
          "https://api.easycoders.in/projects/betrade/public/api/countries"
      );

      final response = await http.get(url).timeout(
        const Duration(seconds: 30),
      );

      if (_isDisposed) return;

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data is Map<String, dynamic> && data['data'] is List) {
          _countries = (data['data'] as List)
              .map((item) {
            try {
              return CountryModel.fromJson(item as Map<String, dynamic>);
            } catch (e) {
              debugPrint("Parse error: $e");
              return null;
            }
          })
              .whereType<CountryModel>()
              .toList();
        } else {
          _countries = [];
        }

        _filtered = List.from(_countries);
        _selectedCountry = _countries.isNotEmpty ? _countries.first : null;
        _isFetched = true;
      } else {
        _countries = [];
        _filtered = [];
      }
    } catch (e, stack) {
      debugPrint("Error: $e");
      debugPrint("Stack: $stack");
      _countries = [];
      _filtered = [];
    } finally {
      if (!_isDisposed) {
        _isLoading = false;
        _safeNotify();
      }
    }
  }

  void search(String value) {
    if (_isDisposed) return;

    final term = value.trim();

    if (term.isEmpty) {
      _filtered = List.from(_countries);
    } else {
      _filtered = _countries.where((country) {
        final name = country.name ?? '';
        final code = country.phoneCode ?? '';
        return name.toLowerCase().contains(term.toLowerCase()) ||
            code.contains(term);
      }).toList();
    }

    _safeNotify();
  }

  void selectCountry(CountryModel? country) {
    if (_isDisposed) return;
    if (country != null && _countries.contains(country)) {
      _selectedCountry = country;
      _safeNotify();
    }
  }

  // 🔥 FIXED: YAHI EK BUG THA
  CountryModel? getCountryById(String id) {
    if (_isDisposed || id.isEmpty) return null;

    // ✅ Method 1: Simple try-catch
    try {
      return _countries.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  int get totalCount => _countries.length;
  int get filteredCount => _filtered.length;

  void reset() {
    if (_isDisposed) return;
    _countries = [];
    _filtered = [];
    _selectedCountry = null;
    _isFetched = false;
    _isLoading = false;
    _safeNotify();
  }

  @override
  void dispose() {
    _isDisposed = true;
    _countries = [];  // ✅ Optional but harmless
    _filtered = [];
    super.dispose();
  }
}
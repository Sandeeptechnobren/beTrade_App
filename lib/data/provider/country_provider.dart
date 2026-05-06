// // // import 'dart:convert';
// // // import 'package:flutter/material.dart';
// // // import 'package:http/http.dart' as http;
// // // import '../model/country_model.dart';
// // // class CountryProvider with ChangeNotifier {
// // //   List<CountryModel> _countries = [];
// // //   List<CountryModel> _filtered = [];
// // //   bool isLoading = false;
// // //   List<CountryModel> get countries => _filtered;
// // //   CountryModel? selectedCountry;
// // //   bool _isFetched = false;
// // //   Future<void> fetchCountries() async {
// // //     if (_isFetched) return;
// // //     try {
// // //       isLoading = true;
// // //       notifyListeners();
// // //       final url = Uri.parse("https://api.easycoders.in/projects/betrade/public/api/countries");
// // //       final response = await http.get(url);
// // //       if (response.statusCode == 200) {
// // //         _isFetched = true;
// // //         final data = jsonDecode(response.body);
// // //         _countries = (data['data'] as List).map((e) => CountryModel.fromJson(e)).toList();
// // //         _filtered = _countries;
// // //         selectedCountry = _countries.isNotEmpty ? _countries.first : null;
// // //       }
// // //     } catch (e) {
// // //       debugPrint("Error: $e");
// // //     }
// // //     isLoading = false;
// // //     notifyListeners();
// // //   }
// // //   void search(String value) {
// // //     if (value.isEmpty) {
// // //       _filtered = _countries;
// // //     } else {
// // //       _filtered = _countries.where((e) {return e.name.toLowerCase().contains(value.toLowerCase()) || e.phoneCode.contains(value);
// // //       }).toList();
// // //     }
// // //     notifyListeners();
// // //   }
// // //   void selectCountry(CountryModel country) {
// // //     selectedCountry = country;
// // //     notifyListeners();
// // //   }
// // // }
// //
// // import 'package:dio/dio.dart';
// // import 'package:flutter/material.dart';
// // import '../../core/config/api_endpoint.dart';
// // import '../../core/network/dio_client.dart';
// // import '../model/country_model.dart';
// //
// // class CountryProvider with ChangeNotifier {
// //   List<CountryModel> _countries = [];
// //   List<CountryModel> _filtered = [];
// //   bool _isLoading = false;
// //   bool _isFetched = false;
// //   bool _isDisposed = false;
// //   CountryModel? _selectedCountry;
// //   List<CountryModel> get countries => List.unmodifiable(_filtered);
// //   bool get isLoading => _isLoading;
// //   CountryModel? get selectedCountry => _selectedCountry;
// //   bool get isFetched => _isFetched;
// //   void _safeNotify() {
// //     if (!_isDisposed && hasListeners) {
// //       notifyListeners();
// //     }
// //   }
// //
// //   Future<void> fetchCountries() async {
// //     if (_isDisposed || _isFetched || _isLoading) return;
// //     try {
// //       _isLoading = true;
// //       _safeNotify();
// //       final response = await DioClient.instance.get(
// //         ApiEndpoints.countries,
// //       );
// //       if (_isDisposed) return;
// //       if (response.statusCode == 200) {
// //         final data = response.data;
// //         if (data is Map<String, dynamic> && data['data'] is List) {
// //           _countries = (data['data'] as List)
// //               .map((item) {
// //                 try {
// //                   return CountryModel.fromJson(item as Map<String, dynamic>);
// //                 } catch (e) {
// //                   debugPrint("Parse error: $e");
// //                   return null;
// //                 }
// //               })
// //               .whereType<CountryModel>()
// //               .toList();
// //         } else {
// //           _countries = [];
// //         }
// //         _filtered = List.from(_countries);
// //         _isFetched = true;
// //       } else {
// //         _countries = [];
// //         _filtered = [];
// //       }
// //     } catch (e, stack) {
// //       if (e is DioException) {
// //         debugPrint("Dio Error: ${e.message}");
// //         debugPrint("Response: ${e.response?.data}");
// //       } else {
// //         debugPrint("Error: $e");
// //         debugPrint("Stack: $stack");
// //       }
// //       _countries = [];
// //       _filtered = [];
// //     } finally {
// //       if (!_isDisposed) {
// //         _isLoading = false;
// //         _safeNotify();
// //       }
// //     }
// //   }
// //
// //   void search(String value) {
// //     if (_isDisposed) return;
// //     final term = value.trim();
// //     if (term.isEmpty) {
// //       _filtered = List.from(_countries);
// //     } else {
// //       _filtered = _countries.where((country) {
// //         final name = country.name ?? '';
// //         final code = country.phoneCode ?? '';
// //         return name.toLowerCase().contains(term.toLowerCase()) ||
// //             code.contains(term);
// //       }).toList();
// //     }
// //     _safeNotify();
// //   }
// //   void selectCountry(CountryModel? country) {
// //     if (_isDisposed) return;
// //     if (country != null && _countries.contains(country)) {
// //       _selectedCountry = country;
// //       _safeNotify();
// //     }
// //   }
// //   CountryModel? getCountryById(String id) {
// //     if (_isDisposed || id.isEmpty) return null;
// //     try {
// //       return _countries.firstWhere((c) => c.id == id);
// //     } catch (_) {
// //       return null;
// //     }
// //   }
// //   int get totalCount => _countries.length;
// //   int get filteredCount => _filtered.length;
// //   void reset() {
// //     if (_isDisposed) return;
// //     _countries = [];
// //     _filtered = [];
// //     _selectedCountry = null;
// //     _isFetched = false;
// //     _isLoading = false;
// //     _safeNotify();
// //   }
// //   @override
// //   void dispose() {
// //     _isDisposed = true;
// //     _countries = [];
// //     _filtered = [];
// //     super.dispose();
// //   }
// // }
//
//
// import 'package:dio/dio.dart';
// import 'package:flutter/material.dart';
// import '../../core/config/api_endpoint.dart';
// import '../../core/network/dio_client.dart';
// import '../model/country_model.dart';
//
// class CountryProvider with ChangeNotifier {
//   List<CountryModel> _countries = [];
//   List<CountryModel> _filtered = [];
//   bool _isLoading = false;
//   bool _isFetched = false;
//   bool _isDisposed = false;
//   CountryModel? _selectedCountry;
//
//   List<CountryModel> get countries => List.unmodifiable(_filtered);
//   bool get isLoading => _isLoading;
//   CountryModel? get selectedCountry => _selectedCountry;
//   bool get isFetched => _isFetched;
//
//   void _safeNotify() {
//     if (!_isDisposed && hasListeners) {
//       notifyListeners();
//     }
//   }
//
//   Future<void> fetchCountries() async {
//     if (_isDisposed || _isFetched || _isLoading) return;
//     try {
//       _isLoading = true;
//       _safeNotify();
//
//       final response = await DioClient.instance.get(
//         ApiEndpoints.countries,
//       );
//
//       if (_isDisposed) return;
//
//       if (response.statusCode == 200) {
//         final data = response.data;
//         if (data is Map<String, dynamic> && data['data'] is List) {
//           _countries = (data['data'] as List)
//               .map((item) {
//             try {
//               return CountryModel.fromJson(item as Map<String, dynamic>);
//             } catch (e) {
//               debugPrint("Parse error: $e");
//               return null;
//             }
//           })
//               .whereType<CountryModel>()
//               .toList();
//         } else {
//           _countries = [];
//         }
//         _filtered = List.from(_countries);
//         _isFetched = true;
//       } else {
//         _countries = [];
//         _filtered = [];
//       }
//     } catch (e, stack) {
//       if (e is DioException) {
//         debugPrint("Dio Error: ${e.message}");
//         debugPrint("Response: ${e.response?.data}");
//       } else {
//         debugPrint("Error: $e");
//         debugPrint("Stack: $stack");
//       }
//       _countries = [];
//       _filtered = [];
//     } finally {
//       if (!_isDisposed) {
//         _isLoading = false;
//         _safeNotify();
//       }
//     }
//   }
//
//   void search(String value) {
//     if (_isDisposed) return;
//     final term = value.trim();
//     if (term.isEmpty) {
//       _filtered = List.from(_countries);
//     } else {
//       _filtered = _countries.where((country) {
//         final name = country.name ?? '';
//         final code = country.phoneCode ?? '';
//         return name.toLowerCase().contains(term.toLowerCase()) ||
//             code.contains(term);
//       }).toList();
//     }
//     _safeNotify();
//   }
//
//   // ✅ FIXED: Removed _countries.contains(country) check which was always
//   // returning false because Dart compares objects by reference, not by value.
//   // Now we match by phoneCode to find the correct country from the list.
//   void selectCountry(CountryModel? country) {
//     if (_isDisposed) return;
//     if (country != null) {
//       final matched = _countries.firstWhere(
//             (c) => c.phoneCode == country.phoneCode,
//         orElse: () => country,
//       );
//       _selectedCountry = matched;
//       _safeNotify();
//     }
//   }
//
//   CountryModel? getCountryById(String id) {
//     if (_isDisposed || id.isEmpty) return null;
//     try {
//       return _countries.firstWhere((c) => c.id == id);
//     } catch (_) {
//       return null;
//     }
//   }
//
//   int get totalCount => _countries.length;
//   int get filteredCount => _filtered.length;
//
//   void reset() {
//     if (_isDisposed) return;
//     _countries = [];
//     _filtered = [];
//     _selectedCountry = null;
//     _isFetched = false;
//     _isLoading = false;
//     _safeNotify();
//   }
//
//   @override
//   void dispose() {
//     _isDisposed = true;
//     _countries = [];
//     _filtered = [];
//     super.dispose();
//   }
// }

// import 'package:dio/dio.dart';
// import 'package:flutter/material.dart';
// import '../../core/config/api_endpoint.dart';
// import '../../core/network/dio_client.dart';
// import '../model/country_model.dart';
//
// class CountryProvider with ChangeNotifier {
//   List<CountryModel> _countries = [];
//   List<CountryModel> _filtered = [];
//   bool _isLoading = false;
//   bool _isFetched = false;
//   bool _isDisposed = false;
//   CountryModel? _selectedCountry;
//
//   List<CountryModel> get countries => List.unmodifiable(_filtered);
//   bool get isLoading => _isLoading;
//   CountryModel? get selectedCountry => _selectedCountry;
//   bool get isFetched => _isFetched;
//
//   void _safeNotify() {
//     if (!_isDisposed && hasListeners) {
//       notifyListeners();
//     }
//   }
//
//   Future<void> fetchCountries() async {
//     if (_isDisposed || _isFetched || _isLoading) return;
//     try {
//       _isLoading = true;
//       _safeNotify();
//
//       final response = await DioClient.instance.get(
//         ApiEndpoints.countries,
//       );
//
//       if (_isDisposed) return;
//
//       if (response.statusCode == 200) {
//         final data = response.data;
//         if (data is Map<String, dynamic> && data['data'] is List) {
//           _countries = (data['data'] as List)
//               .map((item) {
//             try {
//               return CountryModel.fromJson(item as Map<String, dynamic>);
//             } catch (e) {
//               debugPrint("Parse error: $e");
//               return null;
//             }
//           })
//               .whereType<CountryModel>()
//               .toList();
//         } else {
//           _countries = [];
//         }
//
//         _filtered = List.from(_countries);
//         _isFetched = true;
//
//         // ✅ FIX 1: Fetch ke baad selectedCountry null hai toh
//         // list ki PEHLI country set karo — India hardcode NAHI karo
//         if (_selectedCountry == null && _countries.isNotEmpty) {
//           _selectedCountry = _countries.first;
//         }
//
//       } else {
//         _countries = [];
//         _filtered = [];
//       }
//     } catch (e, stack) {
//       if (e is DioException) {
//         debugPrint("Dio Error: ${e.message}");
//         debugPrint("Response: ${e.response?.data}");
//       } else {
//         debugPrint("Error: $e");
//         debugPrint("Stack: $stack");
//       }
//       _countries = [];
//       _filtered = [];
//     } finally {
//       if (!_isDisposed) {
//         _isLoading = false;
//         _safeNotify();
//       }
//     }
//   }
//
//   void search(String value) {
//     if (_isDisposed) return;
//     final term = value.trim();
//     if (term.isEmpty) {
//       _filtered = List.from(_countries);
//     } else {
//       _filtered = _countries.where((country) {
//         final name = country.name ?? '';
//         final code = country.phoneCode ?? '';
//         return name.toLowerCase().contains(term.toLowerCase()) ||
//             code.contains(term);
//       }).toList();
//     }
//     _safeNotify();
//   }
//
//   // ✅ FIX 2: contains() hataya, phoneCode se match karo
//   void selectCountry(CountryModel? country) {
//     if (_isDisposed) return;
//     if (country != null) {
//       final matched = _countries.firstWhere(
//             (c) => c.phoneCode == country.phoneCode,
//         orElse: () => country,
//       );
//       _selectedCountry = matched;
//       _safeNotify();
//     }
//   }
//
//   CountryModel? getCountryById(String id) {
//     if (_isDisposed || id.isEmpty) return null;
//     try {
//       return _countries.firstWhere((c) => c.id == id);
//     } catch (_) {
//       return null;
//     }
//   }
//
//   int get totalCount => _countries.length;
//   int get filteredCount => _filtered.length;
//
//   void reset() {
//     if (_isDisposed) return;
//     _countries = [];
//     _filtered = [];
//     _selectedCountry = null;
//     _isFetched = false;
//     _isLoading = false;
//     _safeNotify();
//   }
//
//   @override
//   void dispose() {
//     _isDisposed = true;
//     _countries = [];
//     _filtered = [];
//     super.dispose();
//   }
// }

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../../core/config/api_endpoint.dart';
import '../../core/network/dio_client.dart';
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
      notifyListeners();
    }
  }

  Future<void> fetchCountries() async {
    if (_isDisposed || _isFetched || _isLoading) return;
    try {
      _isLoading = true;
      _safeNotify();

      final response = await DioClient.instance.get(
        ApiEndpoints.countries,
      );

      if (_isDisposed) return;

      if (response.statusCode == 200) {
        final data = response.data;

        // ✅ FULL API RESPONSE print karo
        debugPrint("==============================");
        debugPrint("📦 API RAW RESPONSE: $data");
        debugPrint("==============================");

        if (data is Map<String, dynamic> && data['data'] is List) {
          final list = data['data'] as List;

          // ✅ Pehle 3 items ka structure print karo
          debugPrint("📋 TOTAL COUNTRIES FROM API: ${list.length}");
          debugPrint("------------------------------");
          for (int i = 0; i < list.length && i < 3; i++) {
            final item = list[i];
            debugPrint("🌍 COUNTRY [$i]: $item");
            debugPrint("   ➤ id:         ${item['id']}");
            debugPrint("   ➤ name:       ${item['name']}");
            debugPrint("   ➤ phone_code: ${item['phone_code']}");
            debugPrint("   ➤ flag:       ${item['flag']}");
            debugPrint("   ➤ currency:   ${item['currency']}");
            debugPrint("   ➤ ALL KEYS:   ${item.keys.toList()}");
            debugPrint("------------------------------");
          }

          _countries = list
              .map((item) {
            try {
              return CountryModel.fromJson(item as Map<String, dynamic>);
            } catch (e) {
              debugPrint("❌ Parse error: $e");
              return null;
            }
          })
              .whereType<CountryModel>()
              .toList();

          // ✅ Parsed model print karo
          if (_countries.isNotEmpty) {
            final first = _countries.first;
            debugPrint("✅ FIRST PARSED CountryModel:");
            debugPrint("   ➤ id:        ${first.id}");
            debugPrint("   ➤ name:      ${first.name}");
            debugPrint("   ➤ phoneCode: ${first.phoneCode}");
            debugPrint("   ➤ flag:      ${first.flag}");
            debugPrint("   ➤ currency:  ${first.currency}");
          }

        } else {
          debugPrint("⚠️ Unexpected data format: ${data.runtimeType}");
          _countries = [];
        }

        _filtered = List.from(_countries);
        _isFetched = true;

        if (_selectedCountry == null && _countries.isNotEmpty) {
          _selectedCountry = _countries.first;
        }

      } else {
        debugPrint("❌ API Error - Status: ${response.statusCode}");
        _countries = [];
        _filtered = [];
      }
    } catch (e, stack) {
      if (e is DioException) {
        debugPrint("❌ Dio Error: ${e.message}");
        debugPrint("❌ Response: ${e.response?.data}");
      } else {
        debugPrint("❌ Error: $e");
        debugPrint("❌ Stack: $stack");
      }
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
        final name = country.name;
        final code = country.phoneCode;
        return name.toLowerCase().contains(term.toLowerCase()) ||
            code.contains(term);
      }).toList();
    }
    _safeNotify();
  }

  void selectCountry(CountryModel? country) {
    if (_isDisposed) return;
    if (country != null) {
      final matched = _countries.firstWhere(
            (c) => c.phoneCode == country.phoneCode,
        orElse: () => country,
      );
      _selectedCountry = matched;
      _safeNotify();
    }
  }

  CountryModel? getCountryById(String id) {
    if (_isDisposed || id.isEmpty) return null;
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
    _countries = [];
    _filtered = [];
    super.dispose();
  }
}
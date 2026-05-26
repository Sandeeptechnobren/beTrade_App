import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../core/config/api_endpoint.dart';
import '../../core/network/dio_client.dart';
import '../model/country_model.dart';
import '../services/local_storage.dart';

/// Country list provider — drives the country picker on LoginScreen +
/// AttachPhoneScreen.
///
/// Two-tier fetch:
///   1. **Disk cache**: on first read, `loadFromCacheIfFresh()` synchronously
///      hydrates from SharedPreferences if a recent cached JSON blob exists.
///      Avoids any spinner on the country picker.
///   2. **Network refresh**: `fetchCountries()` hits `/api/countries`. If
///      the cache was empty (cold first launch), the call blocks the UI.
///      Otherwise it runs in the background and only re-paints if the new
///      list differs.
///
/// The `/api/countries` endpoint takes ~800 ms (Laravel cold-boot) for a
/// payload of 2 rows. The cache turns the second-and-onward launches into
/// instant first paint; the splash pre-fetch hides the first-launch latency
/// behind the splash screen's natural display time.
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

  /// Read the cached countries JSON from disk and hydrate the in-memory
  /// list if it's still within TTL. Safe to call multiple times; idempotent.
  /// Returns true if cache was applied, false if cache was missing/stale.
  bool loadFromCacheIfFresh() {
    if (_isDisposed || _isFetched) return _isFetched;

    final cached = LocalStorage.readCachedCountries();
    if (cached == null) return false;

    try {
      final decoded = jsonDecode(cached);
      if (decoded is Map && decoded['data'] is List) {
        _countries = (decoded['data'] as List)
            .map((item) {
              try {
                return CountryModel.fromJson(item as Map<String, dynamic>);
              } catch (_) {
                return null;
              }
            })
            .whereType<CountryModel>()
            .toList();
        _filtered = List.from(_countries);
        _isFetched = true;
        if (_selectedCountry == null && _countries.isNotEmpty) {
          _selectedCountry = _countries.first;
        }
        _safeNotify();
        return true;
      }
    } catch (e) {
      debugPrint("CountryProvider: cache decode failed: $e");
    }
    return false;
  }

  /// Fetch from `/api/countries`. Skips itself if already loaded for the
  /// current app session — pair with `loadFromCacheIfFresh()` for the
  /// "cold-first-launch only blocks once" effect.
  ///
  /// Pass `force: true` to refetch even when in-memory data is present.
  /// Used by the splash pre-warm path so the in-memory list is always
  /// current after a cold start, even if the cache served the first paint.
  Future<void> fetchCountries({bool force = false}) async {
    if (_isDisposed) return;
    if (!force && (_isFetched || _isLoading)) return;

    try {
      _isLoading = true;
      _safeNotify();

      final response = await DioClient.instance.get(ApiEndpoints.countries);
      if (_isDisposed) return;

      if (response.statusCode == 200 && response.data is Map) {
        final data = response.data as Map;
        if (data['data'] is List) {
          // Persist the raw JSON to disk for next launch. Re-encoding here
          // rather than passing the original response body around keeps the
          // cache shape decoupled from the Dio response object.
          await LocalStorage.cacheCountries(jsonEncode({
            'status': data['status'] ?? true,
            'data': data['data'],
          }));

          _countries = (data['data'] as List)
              .map((item) {
                try {
                  return CountryModel.fromJson(item as Map<String, dynamic>);
                } catch (e) {
                  debugPrint("CountryProvider: parse error on item: $e");
                  return null;
                }
              })
              .whereType<CountryModel>()
              .toList();
          _filtered = List.from(_countries);
          _isFetched = true;

          if (_selectedCountry == null && _countries.isNotEmpty) {
            _selectedCountry = _countries.first;
          }
        }
      }
    } on DioException catch (e) {
      // Network failure on a cold-first-launch leaves the picker empty but
      // is recoverable on retry. Don't blow away an existing cache-hydrated
      // list — keep showing stale data over no data.
      debugPrint("CountryProvider: dio error ${e.message}");
    } catch (e) {
      debugPrint("CountryProvider: unexpected error $e");
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
      final lower = term.toLowerCase();
      _filtered = _countries.where((country) {
        return country.name.toLowerCase().contains(lower) ||
            country.phoneCode.contains(term);
      }).toList();
    }
    _safeNotify();
  }

  /// Compare by `phoneCode` rather than object identity — picker callers
  /// often pass a freshly-built `CountryModel` from the filtered list that
  /// isn't `==` to the canonical entry in `_countries`.
  void selectCountry(CountryModel? country) {
    if (_isDisposed || country == null) return;
    final matched = _countries.firstWhere(
      (c) => c.phoneCode == country.phoneCode,
      orElse: () => country,
    );
    _selectedCountry = matched;
    _safeNotify();
  }

  /// Lookup by primary key. `CountryModel.id` is an int on the wire but
  /// callers (legacy code paths) pass it around as a String — parse defensively
  /// rather than constraining the signature.
  CountryModel? getCountryById(String id) {
    if (_isDisposed || id.isEmpty) return null;
    final parsed = int.tryParse(id);
    if (parsed == null) return null;
    try {
      return _countries.firstWhere((c) => c.id == parsed);
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

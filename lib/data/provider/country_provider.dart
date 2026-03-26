import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../model/country_model.dart';


class CountryProvider with ChangeNotifier {
  List<CountryModel> _countries = [];
  List<CountryModel> _filtered = [];
  bool isLoading = false;

  List<CountryModel> get countries => _filtered;

  CountryModel? selectedCountry;

  bool _isFetched = false;

  Future<void> fetchCountries() async {
    if (_isFetched) return;


    try {
      isLoading = true;
      notifyListeners();

      final url = Uri.parse(
          "https://api.easycoders.in/projects/betrade/public/api/countries");

      final response = await http.get(url);

      if (response.statusCode == 200) {
        _isFetched = true;
        final data = jsonDecode(response.body);

        _countries = (data['data'] as List)
            .map((e) => CountryModel.fromJson(e))
            .toList();

        _filtered = _countries;

        selectedCountry = _countries.isNotEmpty ? _countries.first : null;
      }
    } catch (e) {
      debugPrint("Error: $e");
    }

    isLoading = false;
    notifyListeners();
  }

  void search(String value) {
    if (value.isEmpty) {
      _filtered = _countries;
    } else {
      _filtered = _countries.where((e) {
        return e.name.toLowerCase().contains(value.toLowerCase()) ||
            e.phoneCode.contains(value);
      }).toList();
    }
    notifyListeners();
  }
  void selectCountry(CountryModel country) {
    selectedCountry = country;
    notifyListeners();
  }
}
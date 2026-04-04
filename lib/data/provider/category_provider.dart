import 'package:flutter/material.dart';
import '../model/category_model.dart';
import '../services/category_service.dart';

class CategoryProvider extends ChangeNotifier {
  List<CategoryModel> categories = [];
  bool isLoading = false;
  String error = "";

  Future<void> fetchCategories() async {
    isLoading = true;
    error = "";
    notifyListeners();

    try {
      categories = await CategoryService.getCategories();

      if (categories.isEmpty) {
        error = "No data found";
      }
    } catch (e) {
      error = "Something went wrong";
    }

    isLoading = false;
    notifyListeners();
  }
}
import 'package:flutter/material.dart';

import '../model/trade_model.dart';
import '../services/trade_service.dart';
class ExploreProvider extends ChangeNotifier {
  List<TradeModel> exploreTrades = [];
  bool isLoading = false;
  String error = "";

  Future<void> fetchExploreTrades() async {
    try {
      isLoading = true;
      notifyListeners();

      exploreTrades = await TradeService.getAllTrades();

      isLoading = false;
      notifyListeners();
    } catch (e) {
      isLoading = false;
      error = e.toString();
      notifyListeners();
    }
  }
}
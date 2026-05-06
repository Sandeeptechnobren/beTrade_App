import 'package:flutter/foundation.dart';

import '../model/trade_detail_model.dart';
import '../services/trade_details_service.dart';

/// Holds the currently-viewed trade's detail. Designed for the
/// trade detail bottom sheet — only one trade is "open" at a time, so
/// the provider keeps a single [detail] rather than a per-uuid cache.
///
/// Race protection: if the user quickly closes one trade and opens
/// another, the second [fetch] supersedes the first; results that
/// arrive late for the previous uuid are dropped.
class TradeDetailProvider extends ChangeNotifier {
  TradeDetailModel? _detail;
  bool _isLoading = false;
  String? _error;
  String? _currentUuid;
  bool _isDisposed = false;

  TradeDetailModel? get detail => _detail;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetch(String uuid) async {
    if (_isDisposed) return;
    _currentUuid = uuid;
    _isLoading = true;
    _error = null;
    _detail = null;
    _safeNotify();

    final result = await TradeDetailService.getTradeDetail(uuid);

    if (_isDisposed || _currentUuid != uuid) return;

    _detail = result;
    _isLoading = false;
    _error = result == null ? 'Failed to load trade details' : null;
    _safeNotify();
  }

  void _safeNotify() {
    if (!_isDisposed) notifyListeners();
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }
}

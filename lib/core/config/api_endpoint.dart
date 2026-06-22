import 'env_config.dart';

class ApiEndpoints {
  static String get register => '${EnvConfig.baseUrl}/register';
  static String get login => '${EnvConfig.baseUrl}/login';
  static String get verifyLoginOtp => '${EnvConfig.baseUrl}/verify-otp/login';

  static String get verifyOtp => '${EnvConfig.baseUrl}/verify-otp/register';

  static String get completeProfile => '${EnvConfig.baseUrl}/complete-profile';

  static String get logout => '${EnvConfig.baseUrl}/logout';

  static String get verifyToken => '${EnvConfig.baseUrl}/verify-token';

  static String get chart => '${EnvConfig.baseUrl}/chart';

  static String get profile => '${EnvConfig.baseUrl}/profile';

  static String get editProfile => '${EnvConfig.baseUrl}/edit-profile';

  static String get categories => '${EnvConfig.baseUrl}/trade/categories-list';

  static String searchTrades(String query) =>
      '${EnvConfig.baseUrl}/trade/explore?search=${Uri.encodeQueryComponent(query)}';

  static String tradeList(int page) =>
      '${EnvConfig.baseUrl}/trade/list?page=${Uri.encodeComponent(page.toString())}';

  /// Canonical Explore listing — base list + search + category filter +
  /// pagination + sort, all on one endpoint. All params URL-encoded.
  ///
  /// `sort` is optional. Pass `'trending'` to order by trade volume
  /// (popularity-ranked); omit / pass `'newest'` for the default
  /// newest-first ordering. Backend ignores unknown values gracefully.
  static String tradeExplore({
    int page = 1,
    String? search,
    String? categoryUuid,
    String? sort, // ✅ ADD THIS
  }) {
    final qp = <String, String>{'page': page.toString()};

    final s = search?.trim() ?? '';
    if (s.isNotEmpty) {
      qp['search'] = s;
    }

    if (categoryUuid != null &&
        categoryUuid.isNotEmpty &&
        categoryUuid != 'all') {
      qp['category_uuid'] = categoryUuid;
    }

    if (sort != null && sort.isNotEmpty) {
      qp['sort'] = sort;
    }

    final qs = qp.entries
        .map((e) => '${e.key}=${Uri.encodeQueryComponent(e.value)}')
        .join('&');

    return '${EnvConfig.baseUrl}/trade/list?$qs';
  }

  static String tradeQuote(String uuid) =>
      '${EnvConfig.baseUrl}/trade/$uuid/quote';

  static String tradeBuy(String uuid) => '${EnvConfig.baseUrl}/trade/$uuid/buy';

  // P0-D — sell side. quote-sell is read-only; sell mutates.
  static String tradeQuoteSell(String uuid) =>
      '${EnvConfig.baseUrl}/trade/$uuid/quote-sell';

  static String tradeSell(String uuid) =>
      '${EnvConfig.baseUrl}/trade/$uuid/sell';

  static String tradeView(String uuid) =>
      '${EnvConfig.baseUrl}/trade/view/$uuid';

  static String tradeChart(String uuid) =>
      '${EnvConfig.baseUrl}/trade/$uuid/chart';

  static String get achievementLevels =>
      '${EnvConfig.baseUrl}/achievement-levels';

  static String get positions => '${EnvConfig.baseUrl}/positions';

  static String positionForMarket(String marketUuid) =>
      '${EnvConfig.baseUrl}/positions/$marketUuid';

  static String get wallet => '${EnvConfig.baseUrl}/wallet';

  static String walletTransactions({String? type, int page = 1}) {
    final qp = <String, String>{'page': page.toString()};
    if (type != null && type.isNotEmpty) qp['type'] = type;
    final qs = qp.entries
        .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
        .join('&');
    return '${EnvConfig.baseUrl}/wallet/transactions?$qs';
  }

  static String get walletDeposit => '${EnvConfig.baseUrl}/wallet/deposit';

  static String get walletDepositInitiate =>
      '${EnvConfig.baseUrl}/wallet/deposit/initiate';

  static String get walletWithdraw => '${EnvConfig.baseUrl}/wallet/withdraw';

  static String get languages => '${EnvConfig.baseUrl}/languages';

  static String get kycSubmit => '${EnvConfig.baseUrl}/kyc/submit';

  static String get preferences => '${EnvConfig.baseUrl}/profile/preferences';

  static String get countries => '${EnvConfig.baseUrl}/countries';
  static String get saveFcmToken => '${EnvConfig.baseUrl}/fcm/save-token';

  // TODO(backend): confirm path — could be /social-login or /sign-in/apple.
  static String get socialLogin => '${EnvConfig.baseUrl}/auth/apple';

  static String get loginWithGoogle => '${EnvConfig.baseUrl}/login-with-google';

  static String get attachPhone => '${EnvConfig.baseUrl}/profile/attach-phone';

  static String get verifyAttachPhone =>
      '${EnvConfig.baseUrl}/profile/verify-attach-phone';

  static String get notificationPreferences =>
      '${EnvConfig.baseUrl}/notificationPreferences';

  static String get userDefaultSettingsList =>
      '${EnvConfig.baseUrl}/userDefaultSettings/index';

  static String get updateUserDefaultSettingsList =>
      '${EnvConfig.baseUrl}/userDefaultSettings/update';

  static String tradeDetail(String tradeId) =>
      '${EnvConfig.baseUrl}/trade/tradedetail/$tradeId';

  static String rankings({
    required String category,
    int page = 1,
    int perPage = 25,
  }) {
    final c = Uri.encodeQueryComponent(category);
    return '${EnvConfig.baseUrl}/rankings'
        '?category=$c&page=$page&per_page=$perPage';
  }
}

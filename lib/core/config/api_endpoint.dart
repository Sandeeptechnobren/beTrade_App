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
      '${EnvConfig.baseUrl}/trade/explore?search=$query';

  static String tradeList(int page) =>
      '${EnvConfig.baseUrl}/trade/list?page=${Uri.encodeComponent(page.toString())}';

  static String tradeQuote(String uuid) =>
      '${EnvConfig.baseUrl}/trade/$uuid/quote';

  static String tradeBuy(String uuid) =>
      '${EnvConfig.baseUrl}/trade/$uuid/buy';

  static String tradeView(String uuid) =>
      '${EnvConfig.baseUrl}/trade/view/$uuid';

  static String tradeChart(String uuid) =>
      '${EnvConfig.baseUrl}/trade/$uuid/chart';

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

  static String get walletWithdraw => '${EnvConfig.baseUrl}/wallet/withdraw';

  static String get languages => '${EnvConfig.baseUrl}/languages';

  static String get kycSubmit => '${EnvConfig.baseUrl}/kyc/submit';

  static String get preferences => '${EnvConfig.baseUrl}/profile/preferences';

  static String get countries => '${EnvConfig.baseUrl}/countries';
  static String get saveFcmToken => '${EnvConfig.baseUrl}/fcm/save-token';

  // Social auth (Apple, future: Google). Backend verifies the identity
  // token, creates-or-fetches the user, returns the same JWT envelope as
  // /verify-otp/login.
  // TODO(backend): confirm path — could be /social-login or /sign-in/apple.
  static String get socialLogin => '${EnvConfig.baseUrl}/auth/apple';

  static String get notificationPreferences =>
      '${EnvConfig.baseUrl}/notificationPreferences';

  static String get userDefaultSettingsList =>
      '${EnvConfig.baseUrl}/userDefaultSettings/index';

  static String get updateUserDefaultSettingsList =>
      '${EnvConfig.baseUrl}/userDefaultSettings/update';

  static String  tradeDetail(String tradeId) =>
      '${EnvConfig.baseUrl}/trade/tradedetail/$tradeId';


}

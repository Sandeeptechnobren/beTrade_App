
import 'env_config.dart';

class ApiEndpoints {

  static String get register => '${EnvConfig.baseUrl}/register';

  static String get verifyOtp =>
      '${EnvConfig.baseUrl}/verify-otp/register';

  static String get completeProfile =>
      '${EnvConfig.baseUrl}/complete-profile';

  static String get logout =>
      '${EnvConfig.baseUrl}/logout';

  static String get chart =>
      '${EnvConfig.baseUrl}/chart';

  static String get profile =>
      '${EnvConfig.baseUrl}/profile';

  static String get editProfile =>
      '${EnvConfig.baseUrl}/edit-profile';

  static String get categories =>
      '${EnvConfig.baseUrl}/trade/categories-list';

  static String searchTrades(String query) =>
      '${EnvConfig.baseUrl}/trade/explore?search=$query';

  static String tradeList(int page) =>
      '${EnvConfig.baseUrl}/trade/list?page=${Uri.encodeComponent(page.toString())}';

  static String get languages =>
      '${EnvConfig.baseUrl}/languages';

  static String get kycSubmit =>
      '${EnvConfig.baseUrl}/kyc/submit';

  static String get preferences =>
      '${EnvConfig.baseUrl}/profile/preferences';
}
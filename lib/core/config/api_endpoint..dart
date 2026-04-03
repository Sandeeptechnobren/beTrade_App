// import 'env_config.dart';
//
// class ApiEndpoints {
//   static String get register => '${EnvConfig.baseUrl}/register';
// }

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
}
// // // import 'dart:convert';
// // // import 'package:http/http.dart' as http;
// // // import '../model/trade_model.dart';
// // // import 'local_storage.dart';
// // //
// // // class TradeService {
// // //   static Future<List<TradeModel>> getTrades() async {
// // //     try {
// // //       String? token = LocalStorage.getToken();
// // //
// // //       final response = await http.get(
// // //         Uri.parse("https://api.easycoders.in/projects/betrade/public/api/trade/list"),
// // //         headers: {
// // //           "Authorization": "Bearer $token",
// // //           "Accept": "application/json",
// // //         },
// // //       );
// // //
// // //       print("TRADE API HIT: ${response.statusCode}");
// // //
// // //       if (response.statusCode == 200) {
// // //         final data = jsonDecode(response.body);
// // //
// // //         if (data['status'] == true) {
// // //           List list = data['data'];
// // //
// // //           return list.map((e) => TradeModel.fromJson(e)).toList();
// // //         } else {
// // //           throw Exception("API status false");
// // //         }
// // //       } else {
// // //         throw Exception("Failed to load trades");
// // //       }
// // //     } catch (e) {
// // //       print("ERROR: $e");
// // //       return [];
// // //     }
// // //   }
// // // }
// //
// // import 'dart:convert';
// // import 'package:http/http.dart' as http;
// // import '../model/trade_model.dart';
// // import 'local_storage.dart';
// //
// // class TradeService {
// //   static Future<List<TradeModel>> getTrades() async {
// //     try {
// //       String? token = LocalStorage.getToken();
// //
// //       final response = await http.get(
// //         Uri.parse("https://api.easycoders.in/projects/betrade/public/api/trade/list"),
// //         headers: {
// //           "Authorization": "Bearer $token",
// //           "Accept": "application/json",
// //         },
// //       );
// //
// //       print("TRADE API HIT: ${response.statusCode}");
// //       print("BODY: ${response.body}");
// //
// //       if (response.statusCode == 200) {
// //         final decoded = jsonDecode(response.body);
// //
// //         if (decoded['status'] == true) {
// //           final dynamic rawData = decoded['data'];
// //
// //           // 🔥 HANDLE BOTH CASES
// //           if (rawData is List) {
// //             return rawData
// //                 .map((e) => TradeModel.fromJson(e))
// //                 .toList();
// //           } else if (rawData is Map) {
// //             return [TradeModel.fromJson(rawData)];
// //           } else {
// //             return [];
// //           }
// //         } else {
// //           throw Exception("API status false");
// //         }
// //       } else {
// //         throw Exception("Failed to load trades");
// //       }
// //     } catch (e) {
// //       print("ERROR: $e");
// //       return [];
// //     }
// //   }
// // }
// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import '../model/trade_model.dart';
// import 'local_storage.dart';
//
// class TradeService {
//   static Future<List<TradeModel>> getTrades() async {
//     try {
//       String? token = LocalStorage.getToken();
//
//       final response = await http.get(
//         Uri.parse(
//           "https://api.easycoders.in/projects/betrade/public/api/trade/list",
//         ),
//         headers: {
//           "Authorization": "Bearer $token",
//           "Accept": "application/json",
//         },
//       );
//
//       print("TRADE API HIT: ${response.statusCode}");
//       print("FULL RESPONSE: ${response.body}");
//
//       if (response.statusCode == 200) {
//         final decoded = jsonDecode(response.body);
//
//         print("DECODED TYPE: ${decoded.runtimeType}");
//
//         if (decoded['status'] == true) {
//           final dynamic rawData = decoded['data'];
//
//           print("RAW DATA TYPE: ${rawData.runtimeType}");
//           print("RAW DATA VALUE: $rawData");
//
//           List list = [];
//
//           // 🔥 CASE 1: direct list
//           if (rawData is List) {
//             list = rawData;
//           }
//           else if (rawData is Map && rawData['data'] is List) {
//             list = rawData['data'];
//           }
//           else if (rawData is Map && rawData['trades'] is List) {
//             list = rawData['trades'];
//           }
//           else if (rawData is Map) {
//             list = [rawData];
//           }
//
//           else {
//             print("❌ Unknown data format");
//             return [];
//           }
//           return list.map((e) {
//             try {
//               return TradeModel.fromJson(e);
//             } catch (err) {
//               print("MODEL ERROR: $err");
//               return null;
//             }
//           }).whereType<TradeModel>().toList();
//         } else {
//           throw Exception("API status false");
//         }
//       } else {
//         throw Exception("Failed to load trades");
//       }
//     } catch (e) {
//       print("ERROR: $e");
//       return [];
//     }
//   }
// }
// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import '../model/trade_model.dart';
// import 'local_storage.dart';
//
// class TradeService {
//   static Future<List<TradeModel>> getTrades() async {
//     try {
//       String? token = LocalStorage.getToken();
//       final response = await http.get(
//         Uri.parse(
//           "https://api.easycoders.in/projects/betrade/public/api/trade/list",
//         ),
//         headers: {
//           "Authorization": "Bearer $token",
//           "Accept": "application/json",
//         },
//       );
//       print("TRADE API HIT: ${response.statusCode}");
//       print("BODY: ${response.body}");
//       if (response.statusCode == 200) {
//         final decoded = jsonDecode(response.body);
//         if (decoded['status'] == true) {
//           final List list = decoded['data']['items'];
//           return list.map((e) => TradeModel.fromJson(e)).toList();
//         } else {
//           throw Exception("API status false");
//         }
//       } else {
//         throw Exception("Failed to load trades");
//       }
//     } catch (e) {
//       print("ERROR: $e");
//       return [];
//     }
//   }
// }

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/trade_model.dart';
import 'local_storage.dart';

class TradeService {
  static Future<List<TradeModel>> getTrades() async {
    try {
      String? token = LocalStorage.getToken();
      final response = await http.get(
        Uri.parse(
          "https://api.easycoders.in/projects/betrade/public/api/trade/list",
        ),
        headers: {
          "Authorization": "Bearer $token",
          "Accept": "application/json",
        },
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);

        if (decoded['status'] == true) {
          final List list = decoded['data']['items'];
          return list.map((e) => TradeModel.fromJson(e)).toList();
        } else {
          throw Exception("API status false");
        }
      } else {
        throw Exception("Failed to load trades");
      }
    } catch (e) {
      print("ERROR: $e");
      return [];
    }
  }
  static Future<List<TradeModel>> getAllTrades() async {
    try {
      String? token = LocalStorage.getToken();
      final response = await http.get(
        Uri.parse(
          "https://api.easycoders.in/projects/betrade/public/api/trade/list",
        ),
        headers: {
          "Authorization": "Bearer $token",
          "Accept": "application/json",
        },
      );

      print("EXPLORE API HIT: ${response.statusCode}");

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);

        if (decoded['status'] == true) {
          final List list = decoded['data']['items'];
          return list.map((e) => TradeModel.fromJson(e)).toList();
        } else {
          throw Exception("API status false");
        }
      } else {
        throw Exception("Failed to load trades");
      }
    } catch (e) {
      print("EXPLORE ERROR: $e");
      return [];
    }
  }
}

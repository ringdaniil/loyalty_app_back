import 'dart:convert';
import 'package:shelf/shelf.dart' as shelf;
import '../../data/db.dart';
import '../../utils/utils.dart';

class PhoneService {
  static Future<shelf.Response> getOtp(shelf.Request request) async {
    try {
      final data = jsonDecode(await request.readAsString());
      final String? phoneNumber = data['phoneNumber'];

      if (phoneNumber == null) {
        return Utils.errorResponse(400, 'Phone number is required');
      }

      final otp = generateOtp();
      await sendOtp(phoneNumber, otp);

      await Database.otpCollection
          .insertOne({'phone': phoneNumber, 'otp': otp});

      return shelf.Response.ok(
        jsonEncode({'message': 'OTP sent to your phone'}),
        headers: Utils.jsonHeaders,
      );
    } catch (e, st) {
      print("DANIK: Error$e, Stacktrace:$st");
      return Utils.errorResponse(500, 'Internal server error');
    }
  }

  static Future<void> sendOtp(String phoneNumber, String otp) async {
    // final response = await http.post(
    //   Uri.parse('https://textbelt.com/text'),
    //   headers: {
    //     'Content-Type': 'application/x-www-form-urlencoded',
    //   },
    //   body: {
    //     'phone': phoneNumber,
    //     'message': 'Your OTP is: $otp',
    //     'key': 'textbelt',
    //   },
    // );

    // final result = jsonDecode(response.body);
    // if (result['success'] != true) {
    //   throw Exception('Failed to send OTP: ${result['error']}');
    // }
  }

  static Future<shelf.Response> verifyOtp(shelf.Request request) async {
    try {
      final data = jsonDecode(await request.readAsString());
      final String? phoneNumber = data['phoneNumber'];
      final String? otp = data['otp'];

      if (phoneNumber == null || otp == null) {
        return Utils.errorResponse(400, 'Phone number and OTP are required');
      }

      final otpRecord = await Database.otpCollection
          .findOne({'phone': phoneNumber, 'otp': otp});
      if (otpRecord == null) {
        return Utils.errorResponse(400, 'Invalid OTP');
      }

      await Database.otpCollection.deleteOne({'phone': phoneNumber});
      await Database.usersCollection.updateOne(
        {'phone': phoneNumber},
        {
          r'$set': {'isPhoneConfirmed': true}
        },
      );

      return shelf.Response.ok(
        jsonEncode({'message': 'Phone number verified successfully'}),
        headers: Utils.jsonHeaders,
      );
    } catch (e) {
      return Utils.errorResponse(500, 'Internal server error');
    }
  }

  static String generateOtp({int length = 6}) {
    return "000000";
  }
}

import 'dart:convert';

import 'package:shelf/shelf.dart';

import '../../core/jwt.dart';
import '../../utils/utils.dart';

class UserService {
  static Future<Response> calculateAuthType(Request request) async {
    final accessTokenValue = request.headers['Authorization'];
    final refreshTokenValue = request.headers['Authorization-Refresh'];

    final accessToken = accessTokenValue?.substring(7);
    final refreshToken = refreshTokenValue?.substring(7);

    final userId = verifyAccessToken(accessToken ?? "");

    if (userId == null) {
      final payload = verifyRefreshToken(refreshToken);
      if (payload != null) {
        return Response.ok(
          jsonEncode({
            'authType': 'authedOnline',
            'accessToken': generateAccessToken(payload),
            'refreshToken': generateRefreshToken(payload),
          }),
          headers: Utils.jsonHeaders,
        );
      } else
        return Response.ok(
          jsonEncode({
            'authType': 'registration',
          }),
          headers: Utils.jsonHeaders,
        );
    } else {
      return Response.ok(
        jsonEncode({'authType': 'authedOnline'}),
        headers: Utils.jsonHeaders,
      );
    }
  }
}

import 'dart:convert';

import 'package:shelf/shelf.dart';
import 'jwt.dart';

Middleware checkAuthorization() {
  return (Handler handler) {
    return (Request request) async {
      final authHeader = request.headers['Authorization'];
      final refreshHeader = request.headers['Authorization-Refresh'];

      final accessToken = authHeader?.substring(7);
      final refreshToken = refreshHeader?.substring(7);

      final userId = verifyAccessToken(accessToken ?? "");

      if (userId != null) {
        final updatedRequest = request.change(context: {'userId': userId});
        return handler(updatedRequest);
      }

      final refreshUserId = verifyRefreshToken(refreshToken);
      if (refreshUserId != null) {
        final newAccess = generateAccessToken(refreshUserId);
        final newRefresh = generateRefreshToken(refreshUserId);

        final updatedRequest = request.change(context: {
          'userId': refreshUserId,
          'newAccessToken': newAccess,
          'newRefreshToken': newRefresh,
        });

        final response = await handler(updatedRequest);

        return response.change(headers: {
          ...response.headers,
          'x-new-access-token': newAccess,
          'x-new-refresh-token': newRefresh,
        });
      }

      return Response(
        401,
        body: jsonEncode({'error': 'Invalid or expired tokens'}),
        headers: {'Content-Type': 'application/json'},
      );
    };
  };
}

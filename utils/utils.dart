import 'dart:convert';

import 'package:shelf/shelf.dart';

class Utils {
  static const jsonHeaders = {'Content-Type': 'application/json'};

  static String? getTokenFromHeader(Request request) {
    final authHeader = request.headers['Authorization'];
    if (authHeader == null || !authHeader.startsWith('Bearer ')) return null;
    return authHeader.substring(7);
  }

  static Response errorResponse(int statusCode, String message) {
    return Response(
      statusCode,
      body: jsonEncode({'error': message}),
      headers: jsonHeaders,
    );
  }
}

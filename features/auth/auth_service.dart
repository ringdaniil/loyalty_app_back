import 'dart:convert';

import 'package:bcrypt/bcrypt.dart';
import 'package:shelf/shelf.dart';
import 'package:uuid/uuid.dart';

import '../../core/jwt.dart';
import '../../utils/utils.dart';
import '../cards/cards_service.dart';
import '../users/user_model.dart';
import '../../data/db.dart';

class AuthService {
  static final _uuid = Uuid();

  static Future<Response> register(Request request) async {
    try {
      final data = jsonDecode(await request.readAsString());

      final String? phone = data['phone'];
      final String? password = data['password'];
      final String? customerType = data['customerType'];

      if (phone == null || password == null || customerType == null) {
        return Utils.errorResponse(
            400, 'Phone, password and customer type are required');
      }

      final existingUser =
          await Database.usersCollection.findOne({'phone': phone});
      if (existingUser != null) {
        return Utils.errorResponse(404, 'User already exists');
      }

      final user = User(
        id: _uuid.v4(),
        phone: phone,
        password: password,
        customerType: CustomerType.fromName(customerType),
        isPhoneConfirmed: false,
      );

      await Database.usersCollection.insertOne(user.toJson());

      await CardService.createInitialCardForUser(user);

      return _authSuccessResponse(user);
    } catch (e) {
      return Utils.errorResponse(500, 'Internal server error');
    }
  }

  static Future<Response> login(Request request) async {
    try {
      final data = jsonDecode(await request.readAsString());

      final String? phone = data['phone'];
      final String? password = data['password'];

      if (phone == null || password == null) {
        return Utils.errorResponse(400, 'Phone and password are required');
      }

      final userMap = await Database.usersCollection.findOne({'phone': phone});
      if (userMap == null) {
        return Utils.errorResponse(400, 'Invalid credentials');
      }

      final user = User.fromJson(userMap);

      if (!BCrypt.checkpw(password, user.password)) {
        return Utils.errorResponse(400, 'Invalid credentials');
      }

      return _authSuccessResponse(user);
    } catch (e) {
      return Utils.errorResponse(500, 'Internal server error');
    }
  }

  static Future<Response> verify(Request request) async {
    try {
      final token = Utils.getTokenFromHeader(request);
      if (token == null) {
        return Utils.errorResponse(
            401, 'Missing or invalid Authorization header');
      }

      final userId = verifyAccessToken(token);
      if (userId == null) {
        return Utils.errorResponse(403, 'Invalid or expired token');
      }

      final userExists =
          await Database.usersCollection.findOne({'_id': userId});
      if (userExists == null) {
        return Utils.errorResponse(404, 'User not found');
      }

      return Response.ok(jsonEncode({'userId': userId}),
          headers: Utils.jsonHeaders);
    } catch (e) {
      return Utils.errorResponse(500, 'Internal server error');
    }
  }

  static Future<Response> refresh(Request request) async {
    try {
      final token = Utils.getTokenFromHeader(request);

      final userId = verifyRefreshToken(token);
      if (userId == null) {
        return Response.ok(
          jsonEncode({}),
          headers: Utils.jsonHeaders,
        );
      }

      final newAccessToken = generateAccessToken(userId);
      return Response.ok(
        jsonEncode({
          'accessToken': newAccessToken,
          'refreshToken': token,
        }),
        headers: Utils.jsonHeaders,
      );
    } catch (e) {
      return Utils.errorResponse(500, 'Internal server error');
    }
  }

  static Response _authSuccessResponse(User user) {
    final accessToken = generateAccessToken(user.id);
    final refreshToken = generateRefreshToken(user.id);

    return Response.ok(
      jsonEncode({
        'accessToken': accessToken,
        'refreshToken': refreshToken,
        'userInfo': user.toJson(),
      }),
      headers: Utils.jsonHeaders,
    );
  }
}

import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:intl/intl.dart';
import 'config.dart';

void logWithTimestamp(String message) {
  final now = DateTime.now();
  final formatter = DateFormat('yyyy-MM-dd HH:mm:ss');
  final formatted = formatter.format(now);
  print('[$formatted] $message');
}

String? generateAccessToken(String userId) {
  final jwt = JWT({'id': userId});
  return jwt.sign(SecretKey(Config.accessTokenSecret),
      expiresIn: Duration(minutes: 1));
}

String generateRefreshToken(String userId) {
  final jwt = JWT({'id': userId});
  return jwt.sign(SecretKey(Config.refreshTokenSecret),
      expiresIn: Duration(days: 1));
}

String? verifyAccessToken(String accessToken) {
  logWithTimestamp("Токен который пришел на проверку $accessToken");
  try {
    final token = JWT.verify(accessToken, SecretKey(Config.accessTokenSecret));
    print("id из токена: ${token.payload['id']}");
    return token.payload['id'];
  } catch (e) {
    logWithTimestamp("Ошибка верификации access токена: $e");
    return null;
  }
}

String? verifyRefreshToken(String? refreshToken) {
  try {
    final token =
        JWT.verify(refreshToken ?? "", SecretKey(Config.refreshTokenSecret));
    return token.payload['id'];
  } catch (e) {
    return null;
  }
}

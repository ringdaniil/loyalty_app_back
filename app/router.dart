import 'package:shelf_router/shelf_router.dart';
import 'package:shelf/shelf.dart';

import '../core/jwt_middleware.dart';
import '../features/cards/cards_controller.dart';
import '../features/auth/auth_controller.dart';
import '../features/phone/phone_controller.dart';
import '../features/scan/scan_controller.dart';
import '../features/users/users_controller.dart';

Handler createRouter() {
  final router = Router();

  final protectedCardsRoute = const Pipeline()
      .addMiddleware(checkAuthorization())
      .addHandler(getCardRouter());

  final protectedPhoneRoute = const Pipeline()
      .addMiddleware(checkAuthorization())
      .addHandler(getPhoneRouter());

  router.mount('/auth/', getAuthRouter());
  router.mount('/user/', getUserRouter());
  router.mount('/cards/', protectedCardsRoute);
  router.mount('/phone/', protectedPhoneRoute);
  router.mount('/scan/', getScanRouter());
  return router;
}

import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

import 'auth_service.dart';

Router getAuthRouter() {
  final router = Router();
  router.post('/register', (Request request) => AuthService.register(request));
  router.post('/login', (Request request) => AuthService.login(request));
  router.post('/refresh', (Request request) => AuthService.refresh(request));
  return router;
}

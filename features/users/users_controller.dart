import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

import 'users_service.dart';

Router getUserRouter() {
  final router = Router();
  router.post('/getAuthType',
      (Request request) => UserService.calculateAuthType(request));
  return router;
}

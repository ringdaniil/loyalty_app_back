import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

import 'phone_service.dart';

Router getPhoneRouter() {
  final router = Router();
  router.post('/getOtp', (Request request) => PhoneService.getOtp(request));
  router.post('/confirm', (Request request) => PhoneService.verifyOtp(request));

  return router;
}

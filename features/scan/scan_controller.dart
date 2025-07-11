import 'package:shelf_router/shelf_router.dart';

import 'scan_service.dart';

Router getScanRouter() {
  final router = Router();
  router.get(
    '/<cardId>',
    ScanService.scanCard,
  );

  return router;
}

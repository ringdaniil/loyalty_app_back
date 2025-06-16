import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

import 'cards_service.dart';

Router getCardRouter() {
  final router = Router();
  router.post('/create', (Request request) => CardService.createCard(request));
  router.post('/checkCardScanned',
      (Request request) => CardService.checkCardScanned(request));
  router.get('/fetchUserCards',
      (Request request) => CardService.fetchUserCards(request));
  return router;
}

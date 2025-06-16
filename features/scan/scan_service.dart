import 'dart:convert';

import 'package:shelf/shelf.dart';

import '../../data/db.dart';
import '../../utils/utils.dart';
import '../cards/card_model.dart';
import '../cards/cards_service.dart';

class ScanService {
  static Future<Response> scanCard(Request request, String cardId) async {
    try {
      final cardJson =
          await Database.db.collection("cards").findOne({'cardId': cardId});

      if (cardJson == null) {
        return Utils.errorResponse(404, "Card not found");
      }

      final card = LoyalCard.fromJson(cardJson);
      final progress = card.cardProgressDetails;

      final newProgressDone = progress.progressDone + 1;

      final bool shouldUpgrade = newProgressDone >= progress.amountToUpgrade;

      if (shouldUpgrade) {
        await CardService.upgradeCardLevel(cardId);

        return Response.ok(
          jsonEncode({
            'message': 'Card upgraded to next level',
            'isCardScanned': true,
            'upgraded': true,
          }),
          headers: Utils.jsonHeaders,
        );
      }

      final newProgressDetails = CardProgressDetails(
        progressDone: newProgressDone,
        progressLevel: newProgressDone / progress.amountToUpgrade,
        amountToUpgrade: progress.amountToUpgrade,
        description: progress.description,
      );

      await Database.db.collection("cards").update(
        {'cardId': cardId},
        {
          r'$set': {
            'cardProgressDetails': newProgressDetails.toJson(),
          }
        },
      );

      return Response.ok(
        jsonEncode({
          'message': 'Card scanned successfully',
          'isCardScanned': true,
          'upgraded': false,
        }),
        headers: Utils.jsonHeaders,
      );
    } catch (e, s) {
      print("Error in scanCard: $e\n$s");
      return Utils.errorResponse(500, "Internal server error");
    }
  }
}

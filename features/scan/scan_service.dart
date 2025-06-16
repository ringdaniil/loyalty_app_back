import 'dart:convert';

import 'package:shelf/shelf.dart';

import '../../data/db.dart';
import '../../utils/utils.dart';
import '../cards/card_model.dart';

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
      final newProgressLevel = newProgressDone / progress.amountToUpgrade;

      var newLevel = card.loyalCardLevel;
      var upgraded = false;

      if (newProgressDone >= progress.amountToUpgrade &&
          card.loyalCardLevel.index < LoyalCardLevel.values.length - 1) {
        newLevel = LoyalCardLevel.values[card.loyalCardLevel.index + 1];
        upgraded = true;
      }

      final newProgressDetails = CardProgressDetails(
        progressDone: upgraded ? 0 : newProgressDone,
        progressLevel: upgraded ? 0 : newProgressLevel,
        amountToUpgrade: upgraded
            ? CardProgressDetails.amountToUpgradeFromLoyalCardValues(newLevel)
            : progress.amountToUpgrade,
        description: upgraded
            ? CardProgressDetails.descriptionFromLoyalCardValues(
                newLevel,
                CardProgressDetails.amountToUpgradeFromLoyalCardValues(
                    newLevel),
              )
            : progress.description,
      );

      await Database.db.collection("cards").update(
        {'cardId': cardId},
        {
          r'$set': {
            'cardLevel': newLevel.name,
            'cardProgressDetails': newProgressDetails.toJson(),
          }
        },
      );

      return Response.ok(
        jsonEncode({
          'message': 'Card scanned successfully',
        }),
        headers: Utils.jsonHeaders,
      );
    } catch (e, s) {
      print("Error in scanCard: $e\n$s");
      return Utils.errorResponse(500, "Internal server error");
    }
  }
}

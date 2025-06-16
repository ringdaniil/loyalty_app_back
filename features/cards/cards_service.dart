import 'dart:convert';
import 'dart:math';
import 'package:shelf/shelf.dart';

import '../../data/db.dart';
import '../../utils/utils.dart';
import '../users/user_model.dart';
import 'card_model.dart';

class CardService {
  static const _baseQrUrl = "http://loyalty-app-back.onrender.com/cards/scan/";

  static Future<Response> createCard(Request request) async {
    try {
      final data = jsonDecode(await request.readAsString());
      final String? id = request.context['userId'] as String?;
      final String? cardType = data['cardType'];

      if (id == null || cardType == null) {
        return Utils.errorResponse(400, 'userId and cardType are required');
      }

      final userInfo = await Database.usersCollection.findOne({'id': id});
      if (userInfo == null) {
        return Utils.errorResponse(404, 'User not found');
      }

      final user = User.fromJson(userInfo);
      final userType = user.customerType;

      final isUserAbleToGetCard = userType.isAbleToGetCard(
        LoyalCardType.fromName(cardType),
      );

      if (isUserAbleToGetCard != true) {
        return Utils.errorResponse(403, 'You cannot have this type of card');
      }

      final uniqueCardNumber = await _generateUniqueCardId();
      final saveStatus = await _saveCardToDb(
        LoyalCard(
          cardId: uniqueCardNumber,
          loyalCardType: LoyalCardType.fromName(cardType),
          loyalCardLevel: LoyalCardLevel.bronze,
          cardProgressDetails: CardProgressDetails(
            progressLevel: 0,
            description:
                "You need to scan you QR-code 10 times to upgrade to silver level",
            amountToUpgrade: 10,
            progressDone: 0,
          ),
          ownerId: user.id,
          qrUrl: "$_baseQrUrl$uniqueCardNumber",
        ),
      );

      if (saveStatus == Status.success) {
        return Response.ok(jsonEncode({}), headers: Utils.jsonHeaders);
      } else {
        return Utils.errorResponse(400, 'Error while creating a new card');
      }
    } catch (e, s) {
      print('Error in createCard: $e\n$s');
      return Utils.errorResponse(500, 'Internal server error');
    }
  }

  static Future<Response> fetchUserCards(Request request) async {
    try {
      final String? id = request.url.queryParameters['userId'];

      if (id == null) {
        return Utils.errorResponse(400, 'userId is required');
      }

      final cardsInfoList =
          await Database.db.collection('cards').find({'ownerId': id}).toList();

      final userCards = cardsInfoList
          .map((cardInfo) => LoyalCard.fromJson(cardInfo))
          .toList();

      return Response.ok(
        jsonEncode({'cards': userCards.map((c) => c.toJson()).toList()}),
        headers: Utils.jsonHeaders,
      );
    } catch (e, s) {
      print('Error in fetchUserCards: $e\n$s');
      return Utils.errorResponse(500, 'Failed to fetch cards');
    }
  }

  static Future<Status> _saveCardToDb(LoyalCard card) async {
    try {
      await Database.db.collection("cards").insert(card.toJson());
      return Status.success;
    } catch (e) {
      return Status.failure;
    }
  }

  static Future<void> createInitialCardForUser(User user) async {
    final uniqueCardNumber = await _generateUniqueCardId();

    final card = LoyalCard(
      cardId: uniqueCardNumber,
      loyalCardType: LoyalCardType.fromCustomerType(user.customerType),
      loyalCardLevel: LoyalCardLevel.bronze,
      cardProgressDetails: CardProgressDetails(
        progressLevel: 0,
        description:
            "You need to scan you QR-code 10 times to upgrade to silver level",
        amountToUpgrade: 10,
        progressDone: 0,
      ),
      ownerId: user.id,
      qrUrl: "$_baseQrUrl$uniqueCardNumber",
    );

    try {
      await _saveCardToDb(card);
    } catch (e, s) {
      print("Error creating initial card for user: $e\n$s");
    }
  }

  static Future<Response> checkCardScanned(Request request) async {
    try {
      final data = jsonDecode(await request.readAsString());
      final String? cardId = data['cardId'] as String?;

      final cardProgressDetails = CardProgressDetails.fromJson(
          data['cardProgressDetails'] as Map<String, dynamic>);

      final cardToCompareWith = await Database.db.collection("cards").findOne({
        'cardId': cardId,
      });
      final card = LoyalCard.fromJson(cardToCompareWith ?? {});
      final isEqual = jsonEncode(card.cardProgressDetails.toJson()) ==
          jsonEncode(cardProgressDetails.toJson());

      if (isEqual) {
        return Response.ok(
          jsonEncode({'isCardScanned': false}),
          headers: Utils.jsonHeaders,
        );
      } else {
        return Response.ok(
          jsonEncode({'isCardScanned': true}),
          headers: Utils.jsonHeaders,
        );
      }
    } catch (error) {
      print(error.toString());
      return Utils.errorResponse(500, "Internal server error");
    }
  }
}

Future<String> _generateUniqueCardId() async {
  String? cardNumber;
  Map<String, dynamic>? existingCardWithThisNumber;

  do {
    cardNumber = _generateCardNumber();
    existingCardWithThisNumber =
        await Database.db.collection("cards").findOne({'cardId': cardNumber});
  } while (existingCardWithThisNumber != null);

  return cardNumber;
}

String _generateCardNumber() {
  final random = Random();
  String generateBlock() => (1000 + random.nextInt(9000)).toString();
  return "${generateBlock()}${generateBlock()}${generateBlock()}${generateBlock()}";
}

enum Status {
  success,
  failure,
}

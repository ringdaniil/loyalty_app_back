import '../users/user_model.dart';

enum LoyalCardLevel {
  bronze,
  silver,
  gold;

  String toBeautifulString() {
    switch (this) {
      case LoyalCardLevel.gold:
        return "gold level";
      case LoyalCardLevel.silver:
        return "silver level";
      case LoyalCardLevel.bronze:
        return "bronze level";
    }
  }

  static LoyalCardLevel fromName(String? name) {
    switch (name) {
      case "gold":
        return LoyalCardLevel.gold;
      case "silver":
        return LoyalCardLevel.silver;
      case "bronze":
        return LoyalCardLevel.bronze;
      default:
        throw ArgumentError("Unknown LoyalCardLevel: $name");
    }
  }
}

enum LoyalCardType {
  groceryCustomerCard,
  cafeCustomerCard,
  workerCard;

  static LoyalCardType fromName(String? name) {
    switch (name) {
      case "groceryCustomerCard":
        return LoyalCardType.groceryCustomerCard;
      case "cafeCustomerCard":
        return LoyalCardType.cafeCustomerCard;
      case "workerCard":
        return LoyalCardType.workerCard;
      default:
        throw ArgumentError("Unknown LoyalCardType: $name");
    }
  }

  static LoyalCardType fromCustomerType(CustomerType customerType) {
    switch (customerType) {
      case CustomerType.groceryCustomer:
        return LoyalCardType.groceryCustomerCard;
      case CustomerType.cafeCustomer:
        return LoyalCardType.cafeCustomerCard;
      case CustomerType.worker:
        return LoyalCardType.workerCard;
    }
  }
}

class LoyalCard {
  final String cardId;
  final LoyalCardType loyalCardType;
  final LoyalCardLevel loyalCardLevel;
  final CardProgressDetails cardProgressDetails;
  final String ownerId;
  final String qrUrl;

  LoyalCard({
    required this.cardId,
    required this.loyalCardType,
    required this.loyalCardLevel,
    required this.cardProgressDetails,
    required this.ownerId,
    required this.qrUrl,
  });

  String getName() {
    final typeMap = {
      LoyalCardType.groceryCustomerCard: "grocery card",
      LoyalCardType.cafeCustomerCard: "cafe card",
      LoyalCardType.workerCard: "worker card"
    };

    final levelMap = {
      LoyalCardLevel.gold: "Golden",
      LoyalCardLevel.silver: "Silver",
      LoyalCardLevel.bronze: "Bronze"
    };

    return "${levelMap[loyalCardLevel]} ${typeMap[loyalCardType]}";
  }

  Map<String, dynamic> toJson() => {
        'cardId': cardId,
        'cardType': loyalCardType.name,
        'cardLevel': loyalCardLevel.name,
        'cardProgressDetails': cardProgressDetails.toJson(),
        'ownerId': ownerId,
        'qrUrl': qrUrl,
      };

  static LoyalCard fromJson(Map<String, dynamic> json) => LoyalCard(
        cardId: json['cardId'],
        loyalCardType: LoyalCardType.fromName(json['cardType']),
        loyalCardLevel: LoyalCardLevel.fromName(json['cardLevel']),
        cardProgressDetails:
            CardProgressDetails.fromJson(json['cardProgressDetails']),
        ownerId: json['ownerId'],
        qrUrl: json['qrUrl'],
      );
}

class CardProgressDetails {
  final double progressLevel;
  final String description;
  final double? amountToUpgrade;
  final double? progressDone;

  CardProgressDetails({
    required this.progressLevel,
    required this.description,
    required this.amountToUpgrade,
    required this.progressDone,
  });

  Map<String, dynamic> toJson() => {
        'progressLevel': progressLevel,
        'description': description,
        'amountToUpgrade': amountToUpgrade,
        'progressDone': progressDone,
      };

  static CardProgressDetails fromJson(Map<String, dynamic> json) =>
      CardProgressDetails(
        progressLevel: json['progressLevel'] != null
            ? (json['progressLevel']).toDouble()
            : null,
        description: json['description'],
        amountToUpgrade: json['amountToUpgrade'] != null
            ? (json['amountToUpgrade']).toDouble()
            : null,
        progressDone: json['progressDone'] != null
            ? (json['progressDone']).toDouble()
            : null,
      );

  static String descriptionFromLoyalCardValues(
      LoyalCardLevel loyalCardLevel, double? amountToUpgrade) {
    if (loyalCardLevel == LoyalCardLevel.gold) {
      return "Congratulations, you have the max available card level!}";
    } else {
      final nextLevel = LoyalCardLevel.values[loyalCardLevel.index + 1];
      return "You need to scan your QR-code at our shops or cafes $amountToUpgrade times to upgrade to ${nextLevel.toBeautifulString()}";
    }
  }

  static double? amountToUpgradeFromLoyalCardValues(
      LoyalCardLevel loyalCardLevel) {
    if (loyalCardLevel == LoyalCardLevel.gold) {
      return null;
    }
    final nextLevel = LoyalCardLevel.values[loyalCardLevel.index + 1];
    return switch (nextLevel) {
      LoyalCardLevel.gold => 30,
      LoyalCardLevel.silver => 10,
      LoyalCardLevel.bronze => 0,
    };
  }
}

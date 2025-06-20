import 'package:bcrypt/bcrypt.dart';

import '../cards/card_model.dart';

class User {
  final String id;
  final String phone;
  final String password;
  final CustomerType customerType;
  final bool isPhoneConfirmed;

  User({
    required this.id,
    required this.phone,
    required this.password,
    required this.customerType,
    required this.isPhoneConfirmed,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'phone': phone,
        'password': BCrypt.hashpw(
          password,
          BCrypt.gensalt(),
        ),
        'customerType': customerType.getName(),
        'isPhoneConfirmed': isPhoneConfirmed,
      };

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      phone: json['phone'],
      password: json['password'],
      customerType: CustomerType.fromName(json['customerType']),
      isPhoneConfirmed: json['isPhoneConfirmed'],
    );
  }
}

enum AuthType {
  authedOnline,
  authedOffline,
  authRequired,
  registration;
}

enum CustomerType {
  groceryCustomer,
  cafeCustomer,
  worker;

  static fromName(String? name) {
    CustomerType? customerType;
    switch (name) {
      case "Grocery customer":
        customerType = CustomerType.groceryCustomer;
      case "Cafe customer":
        customerType = CustomerType.cafeCustomer;
      case "Worker":
        customerType = CustomerType.worker;
    }
    return customerType;
  }

  String? getName() {
    String? name;
    switch (this) {
      case CustomerType.groceryCustomer:
        name = "Grocery customer";
      case CustomerType.cafeCustomer:
        name = "Cafe customer";
      case CustomerType.worker:
        name = "Worker";
    }
    return name;
  }

  bool isAbleToGetCard(LoyalCardType loyalCardType) {
    bool isAbleToGetCard = false;
    switch (loyalCardType) {
      case LoyalCardType.groceryCustomerCard:
        isAbleToGetCard = true;
        break;
      case LoyalCardType.workerCard:
        if (this == CustomerType.worker) {
          isAbleToGetCard = true;
        }
        break;
      case LoyalCardType.cafeCustomerCard:
        isAbleToGetCard = true;
        break;
    }
    return isAbleToGetCard;
  }
}

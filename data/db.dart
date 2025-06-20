import 'package:mongo_dart/mongo_dart.dart';

class Database {
  static late Db db;
  static late DbCollection usersCollection;
  static late DbCollection otpCollection;

  static Future<void> init() async {
    db = await Db.create(
        'mongodb+srv://ringdanya:123321oksana@loyaltyapp.5umcg2e.mongodb.net/database?retryWrites=true&w=majority');
    await db.open();
    usersCollection = db.collection('users');
    otpCollection = db.collection('otp');
  }

  static Future<String> getRefreshToken(String? uid) async {
    final user = await usersCollection.findOne({"_id": uid});
    return user?["refresh_token"];
  }
}

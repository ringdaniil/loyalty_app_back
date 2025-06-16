import 'app/server.dart';
import 'data/db.dart';

void main() async {
  final server = Server();
  await Database.init();
  await server.start();
}

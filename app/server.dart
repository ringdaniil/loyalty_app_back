import '../core/config.dart';
import '../data/db.dart';
import 'router.dart';

import 'package:shelf/shelf_io.dart' as shelf_io;

class Server {
  Future<void> start() async {
    await Database.init();
    final handler = createRouter();
    final server = await  shelf_io.serve(handler, Config.host, Config.port);
    print('✅ Server running on http://${server.address.host}:${server.port}');
  }
}
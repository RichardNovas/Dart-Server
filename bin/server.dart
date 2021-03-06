import 'dart:io';

import 'package:mongo_dart/mongo_dart.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart';
import 'package:shelf_hotreload/shelf_hotreload.dart';
import 'package:shelf_router/shelf_router.dart';

import '../api/helpers.dart';
import '../api/rest_api.dart';
import '../api/socket_api.dart';

void main(List<String> arguments) async {
  // Connect and load collection
  final db = await Db.create(
      'mongodb+srv://chatapp:qbCQz0AJGwSAEVDT@cluster0.wejpe.mongodb.net/?retryWrites=true&w=majority').catchError(print);
  await db.open();
  final coll = db.collection('users');
  print('Database opened');

  // Create server
  final port = int.parse(Platform.environment['PORT'] ?? '8081');
  final app = Router();

  // Create routes
  app.mount('/user/', UsersRestApi(coll).router);

  app.mount('/user-ws/', UserSocketApi(coll).routerWs);

  // Listen for incoming connections
  final handler = Pipeline()
      .addMiddleware(logRequests())
      .addMiddleware(handleCors())
      .addHandler(app);

  withHotreload(() => serve(handler, InternetAddress.anyIPv4, port));
}

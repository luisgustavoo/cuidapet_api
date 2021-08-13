import 'dart:io';

import 'package:args/args.dart';
import 'package:cuidapet_api/application/config/application_config.dart';
import 'package:cuidapet_api/application/middlewares/cors/cors_middleware.dart';
import 'package:cuidapet_api/application/middlewares/default_content_type/default_content_type.dart';
import 'package:cuidapet_api/application/middlewares/security/security_middleware.dart';
import 'package:get_it/get_it.dart';
import 'package:shelf/shelf.dart' as shelf;
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_router/shelf_router.dart';

// For Google Cloud Run, set _hostname to '0.0.0.0'.
const _hostname = '0.0.0.0';

Future<void> main(List<String> args) async {
  final parser = ArgParser()..addOption('port', abbr: 'p');
  final result = parser.parse(args);

  // For Google Cloud Run, we respect the PORT environment variable
  final portStr = int.tryParse(result['port'].toString()) ??
      int.tryParse(Platform.environment['PORT'].toString()) ??
      '8080';
  final port = int.tryParse(portStr.toString());

  if (port == null) {
    stdout.writeln('Could not parse port value "$portStr" into a number.');
    // 64: command line usage error
    exitCode = 64;
    return;
  }

  final router = Router();
  final appConfig = ApplicationConfig();
  await appConfig.loadConfigApplication(router);

  final getIt = GetIt.I;

  final handler = const shelf.Pipeline()
      .addMiddleware(CorsMiddleware().handler)
      .addMiddleware(
          DefaultContentType('application/json;charset=utf-8').handler)
      .addMiddleware(SecurityMiddleware(getIt.get()).handler)
      .addMiddleware(shelf.logRequests())
      .addHandler(router);

  final server = await io.serve(handler, _hostname, port);
  print('Serving at http://${server.address.host}:${server.port}');
}

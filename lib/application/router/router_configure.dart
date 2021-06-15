import 'package:cuidapet_api/application/router/i_router.dart';
import 'package:shelf_router/shelf_router.dart';

class RouterConfigure {
  RouterConfigure(this._router);

  final Router _router;
  final List<IRouter> _routers = [

  ];

  void configure() => _routers.forEach((r) => r.configure(_router));
}

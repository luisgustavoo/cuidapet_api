import 'package:cuidapet_api/application/router/i_router.dart';
import 'package:cuidapet_api/modules/users/user_router.dart';
import 'package:shelf_router/shelf_router.dart';

class RouterConfigure {
  RouterConfigure(this._router);

  final Router _router;
  final List<IRouter> _routers = [UserRouter()];

  void configure() => _routers.forEach((r) => r.configure(_router));
}

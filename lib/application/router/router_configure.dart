import 'package:shelf_router/shelf_router.dart';

import '../../modules/categories/categories_router.dart';
import '../../modules/users/user_router.dart';
import 'i_router.dart';

class RouterConfigure {
  RouterConfigure(this._router);

  final Router _router;
  final List<IRouter> _routers = [UserRouter(), CategoriesRouter()];

  void configure() {
    for (final r in _routers) {
      r.configure(_router);
    }
  }

//void configure() => _routers.forEach((r) => r.configure(_router));
}

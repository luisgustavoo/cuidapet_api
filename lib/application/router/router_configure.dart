import 'package:cuidapet_api/application/router/i_router.dart';
import 'package:cuidapet_api/modules/categories/categories_router.dart';
import 'package:cuidapet_api/modules/chat/chat_router.dart';
import 'package:cuidapet_api/modules/schedule/schedule_router.dart';
import 'package:cuidapet_api/modules/supplier/supplier_router.dart';
import 'package:cuidapet_api/modules/users/user_router.dart';
import 'package:shelf_router/shelf_router.dart';

class RouterConfigure {
  RouterConfigure(this._router);

  final Router _router;
  final List<IRouter> _routers = [
    UserRouter(),
    CategoriesRouter(),
    SupplierRouter(),
    ScheduleRouter(),
    ChatRouter()
  ];

  void configure() {
    for (final r in _routers) {
      r.configure(_router);
    }
  }

//void configure() => _routers.forEach((r) => r.configure(_router));
}

import 'package:get_it/get_it.dart';
import 'package:shelf_router/shelf_router.dart';

import '../../application/router/i_router.dart';
import 'controllers/auth_controller.dart';
import 'controllers/user_controller.dart';


class UserRouter implements IRouter {
  @override
  void configure(Router router) {
    final authController = GetIt.I.get<AuthController>();
    final userController = GetIt.I.get<UserController>();
    router
      ..mount('/auth/', authController.router)
      ..mount('/user/', userController.router);

  }
}



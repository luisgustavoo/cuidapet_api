import 'package:get_it/get_it.dart';
import 'package:shelf_router/shelf_router.dart';

import '../../application/router/i_router.dart';
import 'controller/categories_controller.dart';

class CategoriesRouter implements IRouter {
  @override
  void configure(Router router) {
    final categoryController = GetIt.I.get<CategoriesController>();
    router.mount('/categories/', categoryController.router);
  }
}

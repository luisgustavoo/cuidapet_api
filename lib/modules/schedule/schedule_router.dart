import 'package:cuidapet_api/application/router/i_router.dart';
import 'package:cuidapet_api/modules/schedule/controller/schedule_controller.dart';
import 'package:get_it/get_it.dart';
import 'package:shelf_router/shelf_router.dart';

class ScheduleRouter implements IRouter {
  @override
  void configure(Router router) {
    final scheduleController = GetIt.I.get<ScheduleController>();
    router.mount('/schedules/', scheduleController.router);
  }
}

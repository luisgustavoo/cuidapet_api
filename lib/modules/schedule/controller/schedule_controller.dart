import 'dart:async';
import 'dart:convert';
import 'package:cuidapet_api/application/logs/i_logger.dart';
import 'package:cuidapet_api/modules/schedule/view_models/schedule_save_input_model.dart';
import 'package:cuidapet_api/modules/schedule/service/i_schedule_service.dart';
import 'package:injectable/injectable.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

part 'schedule_controller.g.dart';

@Injectable()
class ScheduleController {
  ScheduleController({required this.service, required this.log});

  final IScheduleService service;
  final ILogger log;

  @Route.post('/')
  Future<Response> scheduleServices(Request request) async {
    try {
      final userId = int.parse(request.headers['user']!);

      final inputModel = ScheduleSaveInputModel(
          userId: userId, dataRequest: await request.readAsString());
      await service.scheduleService(inputModel);
      return Response.ok(jsonEncode(<String, dynamic>{}));
    } on Exception catch (e, s) {
      log.error('Erro ao salvar agendamento', e, s);
      return Response.internalServerError();
    }
  }

  Router get router => _$ScheduleControllerRouter(this);
}

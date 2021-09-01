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

  @Route.put('/<scheduleId|[0-9]+>/status/<status>')
  Future<Response> changeStatus(
      Request request, String scheduleId, String status) async {
    try {
      await service.changeStatus(status, int.parse(scheduleId));
      return Response.ok(jsonEncode(<String, dynamic>{}));
    } on Exception catch (e, s) {
      log.error('Erro ao alterar status do agendamento', e, s);
      return Response.internalServerError();
    }
  }

  @Route.get('/')
  Future<Response> findAllSchedulesByUser(Request request) async {
    final userId = int.parse(request.headers['user'].toString());
    try {
      final scheduleResult = await service.findAllScheduleByUser(userId);

      final response = scheduleResult
          .map((s) => {
                'id': s.id,
                'schedule_date': s.scheduleDate.toIso8601String(),
                'status': s.status,
                'name': s.name,
                'pet_name': s.petName,
                'supplier': {
                  'id': s.supplier.id,
                  'name': s.supplier.name,
                  'logo': s.supplier.logo
                },
                'services': s.service
                    .map((e) => {
                          'id': e.service.id,
                          'name': e.service.name,
                          'price': e.service.price
                        })
                    .toList()
              })
          .toList();

      return Response.ok(jsonEncode(response));
    } on Exception catch (e, s) {
      log.error('Erro ao buscar agendamentos do usuario id [$userId]', e, s);
      return Response.internalServerError();
    }
  }

  @Route.get('/supplier')
  Future<Response> findAllSchedulesBySupplier(Request request) async {
    final userId = int.parse(request.headers['user'].toString());
    try {
      final scheduleResult = await service.findAllScheduleByUserSupplier(userId);

      final response = scheduleResult
          .map((s) => {
        'id': s.id,
        'schedule_date': s.scheduleDate.toIso8601String(),
        'status': s.status,
        'name': s.name,
        'pet_name': s.petName,
        'supplier': {
          'id': s.supplier.id,
          'name': s.supplier.name,
          'logo': s.supplier.logo
        },
        'services': s.service
            .map((e) => {
          'id': e.service.id,
          'name': e.service.name,
          'price': e.service.price
        })
            .toList()
      })
          .toList();

      return Response.ok(jsonEncode(response));
    } on Exception catch (e, s) {
      log.error('Erro ao buscar agendamentos do usuario fornecedor id [$userId]', e, s);
      return Response.internalServerError();
    }
  }

  Router get router => _$ScheduleControllerRouter(this);
}

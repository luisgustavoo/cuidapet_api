import 'dart:async';
import 'dart:convert';
import 'package:cuidapet_api/application/logs/i_logger.dart';
import 'package:cuidapet_api/modules/chat/service/i_chat_service.dart';
import 'package:cuidapet_api/modules/chat/view_model/chat_notify_view_model.dart';
import 'package:injectable/injectable.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

part 'chat_controller.g.dart';

@Injectable()
class ChatController {
  ChatController({required this.service, required this.log});

  final IChatService service;
  final ILogger log;

  @Route.post('/schedule/<scheduleId>/start-chat')
  Future<Response> startChatByScheduleId(
      Request request, String scheduleId) async {
    try {
      final chatId = await service.starChat(int.parse(scheduleId));

      return Response.ok(jsonEncode({'chat_id': chatId}));
    } on Exception catch (e, s) {
      log.error('Erro ao iniciar chat', e, s);
      return Response.internalServerError();
    }
  }

  @Route.post('/notify')
  Future<Response> notifyUser(Request request) async {
    try {
      final model = ChatNotifyViewModel(await request.readAsString());
      await service.notifyChat(model);
      return Response.ok(jsonEncode(<String, dynamic>{}));
    } on Exception catch (e, s) {
      log.error('Erro ao enviar notificação', e, s);
      return Response.internalServerError(
        body: jsonEncode(
          {'message': 'Erro ao enviar notificação'},
        ),
      );
    }
  }

  Router get router => _$ChatControllerRouter(this);
}
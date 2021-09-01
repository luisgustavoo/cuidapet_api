import 'package:cuidapet_api/application/router/i_router.dart';
import 'package:cuidapet_api/modules/chat/controller/chat_controller.dart';
import 'package:get_it/get_it.dart';
import 'package:shelf_router/shelf_router.dart';

class ChatRouter implements IRouter {
  @override
  void configure(Router router) {
    final chatController = GetIt.I.get<ChatController>();
    router.mount('/chats/', chatController.router);
  }
}

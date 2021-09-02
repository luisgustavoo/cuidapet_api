import 'package:cuidapet_api/application/facades/push_notification_facades.dart';
import 'package:cuidapet_api/entities/chat.dart';
import 'package:cuidapet_api/modules/chat/data/i_chat_repository.dart';
import 'package:cuidapet_api/modules/chat/service/i_chat_service.dart';
import 'package:cuidapet_api/modules/chat/view_model/chat_notify_view_model.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: IChatService)
class ChatService implements IChatService {
  ChatService(
      {required this.repository, required this.pushNotificationFacades});

  final IChatRepository repository;
  final PushNotificationFacades pushNotificationFacades;

  @override
  Future<int> starChat(int scheduleId) => repository.startChat(scheduleId);

  @override
  Future<void> notifyChat(ChatNotifyViewModel model) async {
    final chat = await repository.findChatById(model.chat);

    if (chat != null) {
      switch (model.notificationUserType) {
        case NotificationUserType.user:
          _notifyUser(chat.userDeviceToken?.tokens, model, chat);
          break;
        case NotificationUserType.supplier:
          _notifyUser(chat.supplierDeviceToken?.tokens, model, chat);
          break;
        default:
          throw Exception('Tipo de notificação não encontrada');
      }
    }
  }

  void _notifyUser(
      List<String?>? tokens, ChatNotifyViewModel model, Chat chat) {
    final payload = <String, dynamic>{
      'type': 'CHAT_MESSAGE',
      'chat': {
        'id': chat.id,
        'name': chat.name,
        'supplier': {'name': chat.supplier.name, 'logo': chat.supplier.logo}
      }
    };

    pushNotificationFacades.sendMessage(
        devices: tokens ?? [],
        title: 'Nova Mensagem',
        body: model.message,
        payload: payload);
  }
}

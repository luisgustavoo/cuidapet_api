import 'package:cuidapet_api/entities/chat.dart';
import 'package:cuidapet_api/modules/chat/view_model/chat_notify_view_model.dart';

abstract class IChatService {
  Future<int> starChat(int scheduleId);


  Future<void> notifyChat(ChatNotifyViewModel model);

  Future<List<Chat>> getChatsByUser(int user);

  Future<List<Chat>> getChatsBySupplier(int supplier);

  Future<void> endChat(int chatId);
}

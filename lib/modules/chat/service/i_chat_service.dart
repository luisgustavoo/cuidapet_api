import 'package:cuidapet_api/modules/chat/view_model/chat_notify_view_model.dart';

abstract class IChatService {
  Future<int> starChat(int scheduleId);
  Future<void> notifyChat(ChatNotifyViewModel model);
}
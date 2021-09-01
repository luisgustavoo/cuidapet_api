import 'package:cuidapet_api/modules/chat/data/i_chat_repository.dart';
import 'package:cuidapet_api/modules/chat/service/i_chat_service.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: IChatService)
class ChatService implements IChatService {
  ChatService({required this.repository});

  final IChatRepository repository;

  @override
  Future<int> starChat(int scheduleId) => repository.startChat(scheduleId);
}

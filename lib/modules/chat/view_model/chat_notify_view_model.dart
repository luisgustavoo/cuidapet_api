import 'package:cuidapet_api/application/helpers/request_mapping.dart';

enum NotificationUserType { user, supplier }

class ChatNotifyViewModel extends RequestMapping {
  ChatNotifyViewModel(String dataRequest) : super(dataRequest);

  late int chat;
  late String message;
  late NotificationUserType notificationUserType;

  @override
  void map() {
    chat = int.parse(data['chat'].toString());
    message = data['message'].toString();
    final notificationTypeRq = data['to'].toString();
    notificationUserType = notificationTypeRq.toLowerCase() == 'u'
        ? NotificationUserType.user
        : NotificationUserType.supplier;
  }
}

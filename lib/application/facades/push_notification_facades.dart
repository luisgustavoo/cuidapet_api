import 'dart:convert';

import 'package:cuidapet_api/application/logs/i_logger.dart';
import 'package:dotenv/dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:injectable/injectable.dart';

@LazySingleton()
class PushNotificationFacades {
  PushNotificationFacades({required this.log});

  final ILogger log;

  Future<void> sendMessage(
      {required List<String?> devices,
      required String title,
      required String body,
      required Map<String, dynamic> payload}) async {
    try {
      final request = {
        'notification': {'body': body, 'title': title},
        'priority': 'high',
        'data': {
          'click_action': 'FLUTTER_NOTIFICATION_CLICK',
          'id': '1',
          'status': 'done',
          'payload': payload
        }
      };
      final firebasePushKey =
          env['FIREBASE_PUSH_KEY'] ?? env['firebasePushKey'];

      if (firebasePushKey == null) {
        return;
      }

      for (final device in devices) {
        if (device != null) {
          request['to'] = device;
          log.info('Enviando mensagem para: $device');
          final result = await http.post(
              Uri.parse('https://fcm.googleapis.com/fcm/send'),
              body: jsonEncode(request),
              headers: {
                'Authorization': 'key=$firebasePushKey',
                'Content-Type': 'application/json'
              });

          final responseData = jsonDecode(result.body) as Map<String, dynamic>;

          if (int.parse(responseData['failure'].toString()) == 1) {
            log.error(
                'Erro ao enviar mensagem para $device erro: ${responseData['results']?[0]}');
          } else {
            log.info('Notificação enviada com sucesso $device');
          }
        }
      }
    } on Exception catch (e, s) {
      log.error('Erro ao enviar notificação', e, s);
    }
  }
}

import '../../../application/helpers/request_mapping.dart';

class UserConfirmInputModel extends RequestMapping {
  UserConfirmInputModel(
      {required this.userId, required this.accessToken, required String data})
      : super(data);

  final int userId;
  final String accessToken;
  late final String iosDeviceToken;
  late final String androidDeviceToken;

  @override
  void map() {
    iosDeviceToken = data['ios_token']?.toString() ?? '';
    androidDeviceToken = data['android_token']?.toString() ?? '';
  }
}

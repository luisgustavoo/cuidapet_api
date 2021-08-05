import 'package:cuidapet_api/application/helpers/request_mapping.dart';
import 'package:cuidapet_api/modules/users/view_models/platform.dart';

class UserUpdateDeviceInputModel extends RequestMapping {
  UserUpdateDeviceInputModel(
      {required String dataRequest, required this.userId})
      : super(dataRequest);

  int userId;
  late String token;
  late Platform platform;

  @override
  void map() {
    token = data['token'].toString();
    platform = data['platform'].toString().toLowerCase() == 'ios'
        ? Platform.ios
        : Platform.android;
  }
}

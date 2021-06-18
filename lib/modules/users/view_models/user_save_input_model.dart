import 'package:cuidapet_api/application/helpers/request_mapping.dart';

class UserSaveInputModel extends RequestMapping {
  UserSaveInputModel(String dataRequest) : super(dataRequest);

  late final String email;
  late final String password;
  int? supplierId;

  @override
  void map() {
    email = data['email'] as String;
    password = data['password'] as String;
  }
}


import 'package:cuidapet_api/application/helpers/request_mapping.dart';

class LoginViewModel extends RequestMapping {
  LoginViewModel(String dataRequest) : super(dataRequest);

  late final String login;
  late final String password;
  late final bool socialLogin;
  late final bool supplierUser;
  late final String avatar;
  late final String socialType;
  late final String socialKey;

  @override
  void map() {
    login = data['email'].toString();
    password = data['password'].toString();
    socialLogin = data['social_login'] as bool;
    supplierUser = data['supplier_user'] as bool;
    avatar = data['avatar'].toString();
    socialType = data['social_type'].toString();
    socialKey = data['social_key'].toString();
  }
}

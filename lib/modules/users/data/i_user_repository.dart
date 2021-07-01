import 'package:cuidapet_api/entities/user.dart';

abstract class IUserRepository {
  Future<User> createUser(User user);

  Future<User> loginWithEmailPassword(String email, String password,
      {bool supplierUser = false});

  Future<User> loginByEmailSocialKey(
      String email, String socialKey, String socialType);
}

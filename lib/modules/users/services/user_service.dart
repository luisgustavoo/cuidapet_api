import 'package:cuidapet_api/application/exceptions/user_notfound_exception.dart';
import 'package:cuidapet_api/application/logs/i_logger.dart';
import 'package:cuidapet_api/entities/user.dart';
import 'package:cuidapet_api/modules/users/data/i_user_repository.dart';
import 'package:cuidapet_api/modules/users/services/i_user_service.dart';
import 'package:cuidapet_api/modules/users/view_models/user_save_input_model.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: IUserService)
class UserService implements IUserService {
  UserService({required this.repository, required this.log});

  IUserRepository repository;
  ILogger log;

  @override
  Future<User> createUser(UserSaveInputModel user) {
    final userEntity = User(
        email: user.email,
        password: user.password,
        registerType: 'App',
        supplierId: user.supplierId);

    return repository.createUser(userEntity);
  }

  @override
  Future<User> loginWithEmailPassword(String email, String password,
          {bool supplierUser = false}) =>
      repository.loginWithEmailPassword(email, password);

  @override
  Future<User> loginWithSocial(
      String email, String avatar, String socialType, String socialKey) async {
    try {
      return await repository.loginByEmailSocialKey(
          email, socialKey, socialType);
    } on UserNotFoundException catch (error) {
      log.error('Usuário não encontrado', error);
      final user = User(
          email: email,
          imageAvatar: avatar,
          socialKey: socialKey,
          registerType: socialType,
          password: DateTime.now().toString());
      return repository.createUser(user);
    }
  }
}

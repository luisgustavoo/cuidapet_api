import 'package:cuidapet_api/application/exceptions/user_notfound_exception.dart';
import 'package:cuidapet_api/application/helpers/jwt_helper.dart';
import 'package:cuidapet_api/application/logs/i_logger.dart';
import 'package:cuidapet_api/entities/user.dart';
import 'package:cuidapet_api/modules/users/data/i_user_repository.dart';
import 'package:cuidapet_api/modules/users/services/i_user_service.dart';
import 'package:cuidapet_api/modules/users/view_models/user_confirm_input_model.dart';
import 'package:cuidapet_api/modules/users/view_models/user_save_input_model.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: IUserService)
class UserService implements IUserService {
  UserService({required this.userRepository, required this.log});

  IUserRepository userRepository;
  ILogger log;

  @override
  Future<User> createUser(UserSaveInputModel user) {
    final userEntity = User(
        email: user.email,
        password: user.password,
        registerType: 'App',
        supplierId: user.supplierId);

    return userRepository.createUser(userEntity);
  }

  @override
  Future<User> loginWithEmailPassword(String email, String password,
          {bool supplierUser = false}) =>
      userRepository.loginWithEmailPassword(email, password);

  @override
  Future<User> loginWithSocial(
      String email, String avatar, String socialType, String socialKey) async {
    try {
      return await userRepository.loginByEmailSocialKey(
          email, socialKey, socialType);
    } on UserNotFoundException catch (error) {
      log.error('Usuário não encontrado', error);
      final user = User(
          email: email,
          imageAvatar: avatar,
          socialKey: socialKey,
          registerType: socialType,
          password: DateTime.now().toString());
      return userRepository.createUser(user);
    }
  }

  @override
  Future<String> confirmLogin(UserConfirmInputModel inputModel) async {
    final refreshToken = JwtHelper.refreshToken(inputModel.accessToken);
    final user = User(
        id: inputModel.userId,
        refreshToken: refreshToken,
        iosToken: inputModel.iosDeviceToken,
        androidToken: inputModel.androidDeviceToken);

    await userRepository.updateUserDeviceTokenAndRefreshToken(user);
    return refreshToken;
  }
}

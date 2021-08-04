import 'package:cuidapet_api/application/exceptions/service_exception.dart';
import 'package:cuidapet_api/application/exceptions/user_notfound_exception.dart';
import 'package:cuidapet_api/application/helpers/jwt_helper.dart';
import 'package:cuidapet_api/application/logs/i_logger.dart';
import 'package:cuidapet_api/entities/user.dart';
import 'package:cuidapet_api/modules/users/data/i_user_repository.dart';
import 'package:cuidapet_api/modules/users/services/i_user_service.dart';
import 'package:cuidapet_api/modules/users/view_models/refresh_token_view_model.dart';
import 'package:cuidapet_api/modules/users/view_models/user_confirm_input_model.dart';
import 'package:cuidapet_api/modules/users/view_models/user_refresh_token_input_model.dart';
import 'package:cuidapet_api/modules/users/view_models/user_save_input_model.dart';
import 'package:injectable/injectable.dart';
import 'package:jaguar_jwt/jaguar_jwt.dart';

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

  @override
  Future<RefreshTokenViewModel> refreshToken(
      UserRefreshTokenInputModel model) async {
    _validateRefreshToken(model);
    final newAccessToken = JwtHelper.generateJWT(model.user, model.supplier);
    final newRefreshToken =
        JwtHelper.refreshToken(newAccessToken.replaceAll('Bearer', ''));
    final user = User(id: model.user, refreshToken: model.refreshToken);
    await userRepository.updateRefreshToken(user);
    return RefreshTokenViewModel(
        accessToken: newAccessToken, refreshToken: newRefreshToken);
  }

  void _validateRefreshToken(UserRefreshTokenInputModel model) {
    try {
      final refreshToken = model.refreshToken.split(' ');

      if (refreshToken.length != 2 || refreshToken.first != 'Bearer') {
        throw const ServiceException('Refresh Token invalido');
      }

      JwtHelper.getClaims(refreshToken.last)
          .validate(issuer: model.accessToken);
    } on ServiceException {
      rethrow;
    } on JwtException {
      log.error('Refresh token invalido');
      throw const ServiceException('Erro ao validar refresh token');
    } on Exception {
      throw const ServiceException('Erro ao validar refresh token');
    }
  }

  @override
  Future<User> findById(int id) => userRepository.findById(id);
}

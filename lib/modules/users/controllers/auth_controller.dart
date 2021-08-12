import 'dart:convert';

import 'package:injectable/injectable.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

import '../../../application/exceptions/user_exists_exception.dart';
import '../../../application/exceptions/user_notfound_exception.dart';
import '../../../application/helpers/jwt_helper.dart';
import '../../../application/logs/i_logger.dart';
import '../../../entities/user.dart';
import '../services/i_user_service.dart';
import '../view_models/login_view_model.dart';
import '../view_models/user_confirm_input_model.dart';
import '../view_models/user_refresh_token_input_model.dart';
import '../view_models/user_save_input_model.dart';

part 'auth_controller.g.dart';

@Injectable()
class AuthController {
  AuthController({required this.userService, required this.log});

  IUserService userService;
  ILogger log;

  @Route.post('/register')
  Future<Response> createUser(Request request) async {
    try {
      final userModel = UserSaveInputModel(await request.readAsString());
      await userService.createUser(userModel);
      return Response.ok(
          jsonEncode({'message': 'Cadastro realizado com sucesso!'}));
    } on UserExistsException {
      return Response(400,
          body: jsonEncode({'message': 'Usuário já cadasatrado'}));
    } on Exception catch (e) {
      log.error('Erro ao cadastrar usuário', e);
      return Response.internalServerError();
    }
  }

  @Route.post('/')
  Future<Response> login(Request request) async {
    try {
      final loginViewModel = LoginViewModel(await request.readAsString());

      User user;

      if (!loginViewModel.socialLogin) {
        user = await userService.loginWithEmailPassword(
            loginViewModel.login, loginViewModel.password,
            supplierUser: loginViewModel.supplierUser);
      } else {
        user = await userService.loginWithSocial(
            loginViewModel.login,
            loginViewModel.avatar,
            loginViewModel.socialType,
            loginViewModel.socialKey);
      }

      return Response.ok(jsonEncode(
          {'access_token': JwtHelper.generateJWT(user.id!, user.supplierId)}));
    } on UserNotFoundException {
      return Response.forbidden(
          jsonEncode({'message': 'Usuário ou senha inválidos'}));
    } on Exception catch (e, s) {
      log.error('Erro ao fazer login', e, s);
      return Response.internalServerError(
          body: jsonEncode({'message': 'Erro ao realizar login'}));
    }
  }

  @Route('PATCH', '/confirm')
  Future<Response> confirmLogin(Request request) async {
    final user = int.parse(request.headers['user']!);
    final supplier = int.tryParse(request.headers['supplier']!);
    final token =
        JwtHelper.generateJWT(user, supplier).replaceAll('Bearer ', '');
    final inputModel = UserConfirmInputModel(
        userId: user, accessToken: token, data: await request.readAsString());
    final refreshToken = await userService.confirmLogin(inputModel);
    return Response.ok(jsonEncode(
        {'access_token': 'Bearer $token', 'refresh_token': refreshToken}));
  }

  @Route.get('/refresh')
  Future<Response> refreshToken(Request request) async {
    try {
      final user = int.parse(request.headers['user']!);
      final supplier = int.tryParse(request.headers['supplier'] ?? '0') ?? 0;
      final accessToken = request.headers['access_token']!;

      final model = UserRefreshTokenInputModel(await request.readAsString(),
          user: user, supplier: supplier, accessToken: accessToken);

      final userRefreshToken = await userService.refreshToken(model);

      return Response.ok(jsonEncode(<String, dynamic>{
        'access_token': userRefreshToken.accessToken,
        'refresh_token': userRefreshToken.refreshToken
      }));
    } on Exception {
      return Response.internalServerError(
          body: jsonEncode({'message': 'Erro ao atualizar access token'}));
    }
  }

  Router get router => _$AuthControllerRouter(this);
}

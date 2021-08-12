import 'dart:convert';

import 'package:injectable/injectable.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

import '../../../application/exceptions/user_notfound_exception.dart';
import '../../../application/logs/i_logger.dart';
import '../services/i_user_service.dart';
import '../view_models/update_url_avatar_view_model.dart';
import '../view_models/user_update_token_device_input_model.dart';

part 'user_controller.g.dart';

@Injectable()
class UserController {
  UserController({required this.userService, required this.log});

  IUserService userService;
  ILogger log;

  @Route.get('/')
  Future<Response> findByToken(Request request) async {
    try {
      final user = int.parse(request.headers['user']!);
      final userData = await userService.findById(user);

      return Response.ok(jsonEncode({
        'email': userData.email,
        'register_type': userData.registerType,
        'img_avatar': userData.imageAvatar
      }));
    } on UserNotFoundException {
      return Response(204);
    } on Exception catch (e, s) {
      log.error('Erro ao buscar usuario', e, s);
      return Response.internalServerError(
          body: jsonEncode({'message': 'Erro ao buscar usuário'}));
    }
  }

  @Route.put('/avatar')
  Future<Response> updateAvatar(Request request) async {
    try {
      final userId = int.parse(request.headers['user']!);
      final updateUrlAvatarViewModel = UpdateUrlAvatarViewModel(
          dataRequest: await request.readAsString(), userId: userId);

      final user = await userService.updateAvatar(updateUrlAvatarViewModel);

      return Response.ok(jsonEncode({
        'email': user.email,
        'register_type': user.registerType,
        'img_avatar': user.imageAvatar
      }));
    } on Exception catch (e, s) {
      log.error('Erro ao atualizar avatar', e, s);
      return Response.internalServerError(
          body: jsonEncode({'message': 'Erro ao atualizar avatar'}));
    }
  }

  @Route.put('/device')
  Future<Response> updateDeviceToken(Request request) async {
    try {
      final userId = int.parse(request.headers['user']!);
      final updateDeviceToken = UserUpdateDeviceInputModel(
          dataRequest: await request.readAsString(), userId: userId);
      await userService.updateDeviceToken(updateDeviceToken);
      return Response.ok(jsonEncode(<String, dynamic>{}));
    } on Exception catch (e, s) {
      log.error('Erro ao atualizar device token', e, s);
      return Response.internalServerError(
          body: jsonEncode({'message': 'Erro ao atualizar device token'}));
    }
  }

  Router get router => _$UserControllerRouter(this);
}

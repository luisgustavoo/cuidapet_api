import 'dart:convert';

import 'package:cuidapet_api/application/exceptions/user_exists_exception.dart';
import 'package:cuidapet_api/application/logs/i_logger.dart';
import 'package:cuidapet_api/modules/users/services/i_user_service.dart';
import 'package:cuidapet_api/modules/users/view_models/user_save_input_model.dart';
import 'package:injectable/injectable.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

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
    } on Exception catch (e, s) {
      log.error('Erro ao cadastrar usuário', e);
      return Response.internalServerError();
    }
  }

  Router get router => _$AuthControllerRouter(this);
}

import 'package:cuidapet_api/entities/user.dart';
import 'package:cuidapet_api/modules/users/data/i_user_repository.dart';
import 'package:cuidapet_api/modules/users/services/i_user_service.dart';
import 'package:cuidapet_api/modules/users/view_models/user_save_input_model.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: IUserService)
class UserService implements IUserService {
  UserService({required this.repository});

  IUserRepository repository;

  @override
  Future<User> createUser(UserSaveInputModel user) {
    final userEntity = User(
        email: user.email,
        password: user.password,
        registerType: 'App',
        supplierId: user.supplierId);

    return repository.createUser(userEntity);
  }
}

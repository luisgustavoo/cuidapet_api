import 'package:cuidapet_api/application/database/i_database_connection.dart';
import 'package:cuidapet_api/application/exceptions/database_exception.dart';
import 'package:cuidapet_api/application/exceptions/user_exists_exception.dart';
import 'package:cuidapet_api/application/helpers/cripty_helper.dart';
import 'package:cuidapet_api/application/logs/i_logger.dart';
import 'package:cuidapet_api/entities/user.dart';
import 'package:cuidapet_api/modules/users/data/i_user_repository.dart';
import 'package:injectable/injectable.dart';
import 'package:mysql1/mysql1.dart';

@LazySingleton(as: IUserRepository)
class UserRepository implements IUserRepository {
  UserRepository({required this.connection, required this.log});

  final IDatabaseConnection connection;
  final ILogger log;

  @override
  Future<User> createUser(User user) async {
    late final MySqlConnection? conn;

    try {
      conn = await connection.openConnection();

      const query =
          'insert into usuario (email, senha, tipo_cadastro, img_avatar, social_id, fornecedor_id) values (?,?,?,?,?,?)';

      final result = await conn.query(query, [
        user.email,
        CriptyHelper.generateSha256Hash(user.password ?? ''),
        user.registerType,
        user.imageAvatar,
        user.socialKey,
        user.supplierId
      ]);

      final userId = result.insertId;

      return user.copyWith(id: userId, password: null);
    } on MySqlException catch (e, s) {
      if (e.message.contains('usuario.email_UNIQUE')) {
        log.error('Usuario já cdastrado na base de dados', e, s);
        throw UserExistsException();
      }
      log.error('Erro ao criar usuario', e, s);
      throw DatabaseException(message: 'Erro ao criar usuario', exception: e);
    } finally {
      await conn?.close();
    }
  }
}

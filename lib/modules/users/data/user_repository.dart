import 'package:cuidapet_api/application/database/i_database_connection.dart';
import 'package:cuidapet_api/application/exceptions/database_exception.dart';
import 'package:cuidapet_api/application/exceptions/user_exists_exception.dart';
import 'package:cuidapet_api/application/exceptions/user_notfound_exception.dart';
import 'package:cuidapet_api/application/helpers/cripty_helper.dart';
import 'package:cuidapet_api/application/logs/i_logger.dart';
import 'package:cuidapet_api/entities/user.dart';
import 'package:cuidapet_api/modules/users/data/i_user_repository.dart';
import 'package:cuidapet_api/modules/users/view_models/platform.dart';
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

      const query = '''
                    insert into usuario (email, senha, tipo_cadastro, img_avatar, social_id, fornecedor_id) values (?,?,?,?,?,?)
                    ''';

      final result = await conn.query(query, [
        user.email,
        CriptyHelper.generateSha256Hash(user.password ?? ''),
        user.registerType,
        user.imageAvatar,
        user.socialKey,
        user.supplierId
      ]);

      final userId = result.insertId;

      return user.copyWith(id: userId);
    } on MySqlException catch (e, s) {
      if (e.message.contains('usuario.email_UNIQUE')) {
        log.error('Usuario já cadastrado na base de dados', e, s);
        throw UserExistsException();
      }
      log.error('Erro ao criar usuario', e, s);
      throw DatabaseException(message: 'Erro ao criar usuario', exception: e);
    } finally {
      await conn?.close();
    }
  }

  @override
  Future<User> loginWithEmailPassword(String email, String password,
      {bool supplierUser = false}) async {
    late final MySqlConnection? conn;

    try {
      conn = await connection.openConnection();
      var query = 'select * from usuario where email = ? and senha = ?';

      if (supplierUser) {
        query += ' and fornecedor_id is not null';
      } else {
        query += ' and fornecedor_id is null';
      }

      final result = await conn.query(query, [
        email,
        CriptyHelper.generateSha256Hash(password),
      ]);

      if (result.isEmpty) {
        log.error('usuario ou senha invalidos');
        throw UserNotFoundException(message: 'Usuário ou senha inválidos');
      } else {
        final userData = result.first;
        return User(
            id: userData['id'] as int,
            email: userData['email'] as String,
            registerType: userData['tipo_cadastro'] as String,
            iosToken: (userData['ios_token'] as Blob?)?.toString(),
            androidToken: (userData['android_token'] as Blob?)?.toString(),
            refreshToken: (userData['refresh_token'] as Blob?)?.toString(),
            imageAvatar: (userData['img_avatar'] as Blob?)?.toString(),
            supplierId: int.tryParse(userData['fornecedor_id'].toString()));
      }
    } on MySqlException catch (e, s) {
      log.error('Erro ao relaizar login', e, s);
      throw DatabaseException(message: e.message);
    } finally {
      await conn?.close();
    }
  }

  @override
  Future<User> loginByEmailSocialKey(
      String email, String socialKey, String socialType) async {
    MySqlConnection? conn;
    try {
      conn = await connection.openConnection();
      final result =
          await conn.query('select * from usuario where email = ?', [email]);

      if (result.isEmpty) {
        throw UserNotFoundException(message: 'Usuário não encontrado');
      } else {
        final dataMysql = result.first;

        if (dataMysql['social_id'] == null ||
            dataMysql['social_id'] != socialKey) {
          await conn.query('''
                            update usuario set social_id = ?, tipo_cadastro = ? where id = ?
                           ''', [socialKey, socialType, dataMysql['id']]);
        }

        return User(
            id: dataMysql['id'] as int,
            email: dataMysql['email'] as String,
            registerType: dataMysql['tipo_cadastro'] as String,
            iosToken: (dataMysql['ios_token'] as Blob?)?.toString(),
            androidToken: (dataMysql['android_token'] as Blob?)?.toString(),
            refreshToken: (dataMysql['refresh_token'] as Blob?)?.toString(),
            imageAvatar: (dataMysql['img_avatar'] as Blob?)?.toString(),
            supplierId: int.tryParse(dataMysql['fornecedor_id'].toString()));
      }
    } on MySqlException catch (e, s) {
      log.error('Erro ao realizar login com rede social', e, s);
      throw DatabaseException();
    } finally {
      await conn?.close();
    }
  }

  @override
  Future<void> updateUserDeviceTokenAndRefreshToken(User user) async {
    MySqlConnection? conn;
    try {
      conn = await connection.openConnection();

      final setParams = <String, dynamic>{};

      if (user.iosToken != null && user.iosToken.toString().isNotEmpty) {
        setParams.putIfAbsent('ios_token', () => user.iosToken);
      } else {
        setParams.putIfAbsent('android_token', () => user.androidToken);
      }

      final query = '''
          update usuario 
            set ${setParams.keys.elementAt(0)} = ?, refresh_token = ? 
          where id = ?                   
         ''';
      await conn.query(
          query, [setParams.values.elementAt(0), user.refreshToken, user.id]);
    } on MySqlException catch (e, s) {
      log.error('Erro ao confirmar login', e, s);
      throw DatabaseException();
    } finally {
      await conn?.close();
    }
  }

  @override
  Future<void> updateRefreshToken(User user) async {
    MySqlConnection? conn;

    try {
      conn = await connection.openConnection();
      await conn.query('update usuario set refresh_token = ? where id = ?',
          [user.refreshToken, user.id]);
    } on MySqlException catch (e, s) {
      log.error('Erro ao atualizar refresh token', e, s);
      throw DatabaseException();
    } finally {
      await conn?.close();
    }
  }

  @override
  Future<User> findById(int id) async {
    MySqlConnection? conn;

    try {
      conn = await connection.openConnection();
      final result = await conn.query('''
                                        select id, email, tipo_cadastro, ios_token, refresh_token, img_avatar, fornecedor_id 
                                         from usuario 
                                        where id = ?
                                      ''', [id]);

      if (result.isEmpty) {
        throw UserNotFoundException(message: 'Usuário não encontrado');
      } else {
        final dataMysql = result.first;

        return User(
            id: dataMysql['id'] as int,
            email: dataMysql['email'] as String,
            registerType: dataMysql['tipo_cadastro'] as String,
            iosToken: (dataMysql['ios_token'] as Blob?)?.toString(),
            androidToken: (dataMysql['android_token'] as Blob?)?.toString(),
            refreshToken: (dataMysql['refresh_token'] as Blob?)?.toString(),
            imageAvatar: (dataMysql['img_avatar'] as Blob?)?.toString(),
            supplierId: int.tryParse(dataMysql['fornecedor_id'].toString()));

/*        return User(
            id: dataMysql['id'] as int,
            email: dataMysql['email'] as String,
            registerType: dataMysql['tipo_cadastro'] as String,
            iosToken: dataMysql['ios_token'] .toString(),
            androidToken: dataMysql['android_token'].toString(),
            refreshToken: dataMysql['refresh_token'].toString(),
            imageAvatar: dataMysql['img_avatar'].toString(),
            supplierId: int.tryParse(dataMysql['fornecedor_id'].toString()));*/

      }
    } on MySqlException catch (e, s) {
      log.error('Erro ao buscar usuario por id', e, s);
      throw DatabaseException();
    } finally {
      await conn?.close();
    }
  }

  @override
  Future<void> updateUrlAvatar(int userId, String urlAvatar) async {
    MySqlConnection? conn;

    try {
      conn = await connection.openConnection();
      await conn.query('update usuario set img_avatar = ? where id = ?',
          [urlAvatar, userId]);
    } on MySqlException catch (e, s) {
      log.error('Erro ao atualizar avatar', e, s);
      throw DatabaseException();
    } finally {
      await conn?.close();
    }
  }

  @override
  Future<void> updateDeviceToken(
      int userId, String token, Platform platform) async {
    MySqlConnection? conn;

    try {
      conn = await connection.openConnection();

      final setParams = <String, dynamic>{};

      if (platform == Platform.ios) {
        setParams.putIfAbsent('ios_token', () => token);
      } else {
        setParams.putIfAbsent('android_token', () => token);
      }

      await conn.query('''
          update usuario 
            set ${setParams.keys.elementAt(0)} = ? 
          where id = ?                   
         ''', [setParams.values.elementAt(0), userId]);
    } on MySqlException catch (e, s) {
      log.error('Erro ao atualizar device token', e, s);
      throw DatabaseException();
    } finally {
      await conn?.close();
    }
  }
}

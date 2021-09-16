import 'dart:convert';

import 'package:cuidapet_api/application/database/i_database_connection.dart';
import 'package:cuidapet_api/application/exceptions/database_exception.dart';
import 'package:cuidapet_api/application/exceptions/user_exists_exception.dart';
import 'package:cuidapet_api/application/exceptions/user_notfound_exception.dart';
import 'package:cuidapet_api/application/helpers/cripty_helper.dart';
import 'package:cuidapet_api/application/logs/i_logger.dart';
import 'package:cuidapet_api/entities/user.dart';
import 'package:cuidapet_api/modules/users/data/i_user_repository.dart';
import 'package:cuidapet_api/modules/users/data/user_repository.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mysql1/mysql1.dart';
import 'package:test/test.dart';

import '../../../core/fixture/fixture_reader.dart';
import '../../../core/log/mock_logger.dart';
import '../../../core/mysql/mock_database_connection.dart';

import '../../../core/mysql/mock_mysql_exception.dart';
import '../../../core/mysql/mock_results.dart';

void main() {
  late MockDatabaseConnection database;
  late ILogger log;
  late UserRepository userRepository;

  setUp(() {
    database = MockDatabaseConnection();
    log = MockLogger();
    userRepository = UserRepository(connection: database, log: log);
  });

  group('Group test findById', () {
    test('Should return user by id', () async {
      // Arrange
      const userId = 1;
      final userFixtureDb = FixtureReader.getJsonData(
          'modules/user/data/fixture/find_by_id_success_fixture.json');

      final mockResults = MockResults(userFixtureDb, [
        'ios_token',
        'android_token',
        'refresh_token',
        'img_avatar',
      ]);

      (database as MockDatabaseConnection).mockQuery(mockResults);

      final userMap = jsonDecode(userFixtureDb) as Map<String, dynamic>;

      //final userMap = Map<String, dynamic>.from(userJson);

      final userExpected = User(
          id: int.parse(userMap['id'].toString()),
          email: userMap['email'].toString(),
          registerType: userMap['tipo_cadastro'].toString(),
          iosToken: userMap['ios_token'].toString(),
          androidToken: userMap['android_token'].toString(),
          refreshToken: userMap['refresh_token'].toString(),
          imageAvatar: userMap['img_avatar'].toString(),
          supplierId: int.tryParse(userMap['fornecedor_id'].toString()));

      //Act
      final user = await userRepository.findById(userId);

      //Assert
      expect(user, isA<User>());
      expect(user, userExpected);
      database.verifyConnectionClose();
    });

    test('Should return exception UserNotFoundException option 1', () async {
      // Arrange
      const id = 1;
      final mockResults = MockResults();
      database.mockQuery(mockResults, [id]);
      //Act
      final call = userRepository.findById;
      //Assert
      expect(call(id), throwsA(isA<UserNotFoundException>()));
      await Future<dynamic>.delayed(const Duration(seconds: 1));
      database.verifyConnectionClose();
    });

    test('Should return exception UserNotFoundException option 2', () async {
      // Arrange
      const id = 1;
      final mockResults = MockResults();
      (database as MockDatabaseConnection).mockQuery(mockResults, [id]);
      //Act
      try {
        await userRepository.findById(id);
      } on UserNotFoundException {
        //rethrow;
      } on Exception {
        fail('Exception errada deveria retorna um UserNotFoundException');
      }

      (database as MockDatabaseConnection).verifyConnectionClose();
    });
  });

  group('Group test create user', () {
    test('Should create user with success', () async {
      // Arrange
      const userId = 1;
      final userInsert = User(
          email: 'luisgustavovieirasantos@gmail.com',
          registerType: 'APP',
          imageAvatar: '',
          password: '123123');
      final userExpected = User(
          id: userId,
          email: 'luisgustavovieirasantos@gmail.com',
          registerType: 'APP',
          imageAvatar: '',
          password: '123123');
      final mockResults = MockResults();
      when(() => mockResults.insertId).thenReturn(userId);
      database.mockQuery(mockResults);
      //Act
      final user = await userRepository.createUser(userInsert);
      //Assert
      expect(user, userExpected);
    });

    test('Should throw DatabaseException', () async {
      // Arrange
      database.mockQueryException();

      //Act
      final call = userRepository.createUser;
      //Assert
      expect(call(User()), throwsA(isA<DatabaseException>()));
    });

    test('Should throw UserExistsException', () async {
      // Arrange
      final exception = MockMysqlException();
      when(() => exception.message).thenReturn('usuario.email_UNIQUE');
      database.mockQueryException(exception);

      //Act
      final call = userRepository.createUser;
      //Assert
      expect(call(User()), throwsA(isA<UserExistsException>()));
    });
  });
}

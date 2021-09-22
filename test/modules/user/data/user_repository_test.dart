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

      database.mockQuery(mockResults);

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
      await Future<dynamic>.delayed(const Duration(milliseconds: 200));
      database.verifyConnectionClose();
    });

    test('Should return exception UserNotFoundException option 2', () async {
      // Arrange
      const id = 1;
      final mockResults = MockResults();
      database.mockQuery(mockResults, [id]);
      //Act
      try {
        await userRepository.findById(id);
      } on UserNotFoundException {
        //rethrow;
      } on Exception {
        fail('Exception errada deveria retorna um UserNotFoundException');
      }

      database.verifyConnectionClose();
    });
  });

  group('Group test createUser', () {
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
      database.verifyConnectionClose();
    });

    test('Should throw DatabaseException', () async {
      // Arrange
      database.mockQueryException();

      //Act
      final call = userRepository.createUser;
      //Assert
      expect(call(User()), throwsA(isA<DatabaseException>()));
      await Future<dynamic>.delayed(const Duration(milliseconds: 200));
      database.verifyConnectionClose();
    });

    test('Should throw UserExistsException', () async {
      // Arrange
      final exception = MockMysqlException();
      when(() => exception.message).thenReturn('usuario.email_UNIQUE');
      database.mockQueryException(mockException: exception);

      //Act
      final call = userRepository.createUser;
      //Assert
      expect(call(User()), throwsA(isA<UserExistsException>()));
      await Future<dynamic>.delayed(const Duration(milliseconds: 200));
      database.verifyConnectionClose();
    });
  });

  group('Group test loginWithEmailPassword', () {
    test('Should login with email and password', () async {
      // Arrange
      final userFixtureDB = FixtureReader.getJsonData(
          'modules/user/data/fixture/login_with_email_password_success.json');
      final mockResults = MockResults(userFixtureDB, [
        'ios_token',
        'android_token',
        'refresh_token',
        'img_avatar',
      ]);
      const email = 'luisgustavovieirasantos@gmail.com';
      const password = '123123';
      database.mockQuery(
          mockResults, [email, CriptyHelper.generateSha256Hash(password)]);

      final userMap = jsonDecode(userFixtureDB) as Map<String, dynamic>;

      final userExpected = User(
          id: int.tryParse(userMap['id'].toString()) ?? 0,
          email: userMap['email'].toString(),
          registerType: userMap['tipo_cadastro'].toString(),
          iosToken: userMap['ios_token'].toString(),
          androidToken: userMap['android_token'].toString(),
          refreshToken: userMap['refresh_token'].toString(),
          imageAvatar: userMap['img_avatar'].toString(),
          supplierId: int.tryParse(userMap['fornecedor_id'].toString()) ?? 0);

      //Act
      final user = await userRepository.loginWithEmailPassword(email, password);

      //Assert
      expect(user, userExpected);
    });

    test(
        'Should login with email and password and return exception UserNotFoundException',
        () async {
      // Arrange
      const email = 'luisgustavovieirasantos@gmail.com';
      const password = '123123';
      database.mockQueryException(params: [email, CriptyHelper.generateSha256Hash(password)]);
      //Act
      final call = userRepository.loginWithEmailPassword;

      //Assert
      expect(call(email, password), throwsA(isA<DatabaseException>()));
      await Future<dynamic>.delayed(const Duration(milliseconds: 200));
      database.verifyConnectionClose();
    });

    test(
        'Should login with email and password and return exception DatabaseException',
            () async {
          // Arrange
          final userFixtureDB = FixtureReader.getJsonData(
              'modules/user/data/fixture/login_with_email_password_success.json');
          final mockResults = MockResults();
          const email = 'luisgustavovieirasantos@gmail.com';
          const password = '123123';
          database.mockQuery(
              mockResults, [email, CriptyHelper.generateSha256Hash(password)]);
          //Act
          final call = userRepository.loginWithEmailPassword;

          //Assert
          expect(call(email, password), throwsA(isA<UserNotFoundException>()));
          await Future<dynamic>.delayed(const Duration(milliseconds: 200));
          database.verifyConnectionClose();
        });
  });
}

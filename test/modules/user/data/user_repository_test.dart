import 'dart:convert';

import 'package:cuidapet_api/application/database/i_database_connection.dart';
import 'package:cuidapet_api/application/exceptions/user_notfound_exception.dart';
import 'package:cuidapet_api/application/logs/i_logger.dart';
import 'package:cuidapet_api/entities/user.dart';
import 'package:cuidapet_api/modules/users/data/user_repository.dart';
import 'package:test/test.dart';

import '../../../core/fixture/fixture_reader.dart';
import '../../../core/log/mock_logger.dart';
import '../../../core/mysql/mock_database_connection.dart';

import '../../../core/mysql/mock_results.dart';

void main() {
  late IDatabaseConnection database;
  late ILogger log;

  setUp(() {
    database = MockDatabaseConnection();
    log = MockLogger();
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
      final userRepository = UserRepository(connection: database, log: log);
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
      (database as MockDatabaseConnection).verifyConnectionClose();
    });

    test('Should return exception UserNotFoundException option 1', () async {
      // Arrange
      const id = 1;
      final mockResults = MockResults();
      (database as MockDatabaseConnection).mockQuery(mockResults, [id]);
      final userRepository = UserRepository(connection: database, log: log);
      //Act
      final call = userRepository.findById;
      //Assert
      expect(call(id), throwsA(isA<UserNotFoundException>()));
      await Future<dynamic>.delayed(const Duration(seconds: 1));
      (database as MockDatabaseConnection).verifyConnectionClose();
    });

    test('Should return exception UserNotFoundException option 2', () async {
      // Arrange
      const id = 1;
      final mockResults = MockResults();
      (database as MockDatabaseConnection).mockQuery(mockResults, [id]);
      final userRepository = UserRepository(connection: database, log: log);
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
}

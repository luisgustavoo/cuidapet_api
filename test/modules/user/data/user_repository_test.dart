import 'package:cuidapet_api/application/database/i_database_connection.dart';
import 'package:cuidapet_api/application/logs/i_logger.dart';
import 'package:cuidapet_api/entities/user.dart';
import 'package:cuidapet_api/modules/users/data/user_repository.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mysql1/mysql1.dart';
import 'package:test/test.dart';

import '../../../core/log/mock_logger.dart';
import '../../../core/mysql/mock_database_connection.dart';
import '../../../core/mysql/mock_mysql_connection.dart';
import '../../../core/mysql/mock_result_row.dart';
import '../../../core/mysql/mock_results.dart';

void main() {
  late IDatabaseConnection database;
  late ILogger log;
  late MySqlConnection mySqlConnection;
  late Results mysqlResults;
  late ResultRow mysqlResultRow;

  setUp(() {
    database = MockDatabaseConnection();
    log = MockLogger();
    mySqlConnection = MockMysqlConnection();
    mysqlResults = MockResults();
    mysqlResultRow = MockResultRow();
  });

  group('Group test findById', () {
    test('Should return user by id', () async {
      // Arrange
      const userId = 1;
      final userRepository = UserRepository(connection: database, log: log);
      when(() => mySqlConnection.close()).thenAnswer((_) async => _);
      when(() => database.openConnection())
          .thenAnswer((_) async => mySqlConnection);
      when(() => mySqlConnection.query(any(), any()))
          .thenAnswer((_) async => mysqlResults);
      when(
        () => mysqlResults.isEmpty,
      ).thenReturn(false);
      when(() => mysqlResults.first).thenAnswer((_) => mysqlResultRow);
      when(() => int.tryParse(mysqlResultRow['id'].toString()))
          .thenAnswer((_) => 1);
      when(() => mysqlResultRow['email'].toString()).thenAnswer((_) => '');
      when(() => mysqlResultRow['tipo_cadastro'].toString())
          .thenAnswer((_) => '');
      when(() => mysqlResultRow['ios_token'].toString()).thenAnswer((_) => '');
      when(() => mysqlResultRow['android_token'].toString())
          .thenAnswer((_) => '');
      when(() => mysqlResultRow['refresh_token'].toString())
          .thenAnswer((_) => '');
      when(() => mysqlResultRow['img_avatar'].toString()).thenAnswer((_) => '');
      when(() => int.tryParse(mysqlResultRow['fornecedor_id'].toString()))
          .thenAnswer((_) => 1);

      //Act
      final user = await userRepository.findById(userId);
      //Assert
      expect(user, isA<User>());
      expect(user.id, 1);
    });
  });
}

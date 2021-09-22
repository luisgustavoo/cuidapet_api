import 'package:cuidapet_api/application/database/i_database_connection.dart';
import 'package:mocktail/mocktail.dart';

import 'mock_mysql_connection.dart';
import 'mock_mysql_exception.dart';
import 'mock_results.dart';

class MockDatabaseConnection extends Mock implements IDatabaseConnection {
  MockDatabaseConnection() {
    when(openConnection).thenAnswer((_) async => mySqlConnection);
  }

  final mySqlConnection = MockMysqlConnection();

  void mockQuery(MockResults mockResults, [List<Object>? params]) {
    when(() => mySqlConnection.query(any(), params ?? any()))
        .thenAnswer((_) async => mockResults);
  }

  void mockQueryException(
      {MockMysqlException? mockException, List<Object>? params}) {
    var exception = mockException;

    if (mockException == null) {
      exception = MockMysqlException();
      when(() => exception!.message).thenReturn('Erro Mysql generico');
    }

    when(() => mySqlConnection.query(any(), params ?? any()))
        .thenThrow(exception!);
  }

  void verifyConnectionClose() {
    verify(mySqlConnection.close).called(1);
  }
}

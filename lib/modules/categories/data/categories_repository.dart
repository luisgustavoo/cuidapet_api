import 'package:cuidapet_api/application/database/i_database_connection.dart';
import 'package:cuidapet_api/application/exceptions/database_exception.dart';
import 'package:cuidapet_api/application/logs/i_logger.dart';
import 'package:cuidapet_api/entities/category.dart';
import 'package:cuidapet_api/modules/categories/data/i_categories_repository.dart';
import 'package:injectable/injectable.dart';
import 'package:mysql1/mysql1.dart';

@LazySingleton(as: ICategoriesRepository)
class CategoriesRepository implements ICategoriesRepository {
  CategoriesRepository({required this.connection, required this.log});

  IDatabaseConnection connection;
  ILogger log;

  @override
  Future<List<Category>> findAll() async {
    MySqlConnection? conn;

    try {
      conn = await connection.openConnection();
      final result = await conn.query('select * from categorias_fornecedor');

      if (result.isNotEmpty) {
        return result
            .map((e) => Category(
                id: e['id'] as int,
                name: e['nome_categoria'].toString(),
                type: e['tipo_categoria'].toString()))
            .toList();
      }
    } on MySqlException catch (e, s) {
      log.error('Erro ao buscar as categorias do fornecedor', e, s);
      throw DatabaseException();
    } finally {
      await conn?.close();
    }

    return <Category>[];
  }
}

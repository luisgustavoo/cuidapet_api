import 'package:cuidapet_api/application/database/i_database_connection.dart';
import 'package:cuidapet_api/application/exceptions/database_exception.dart';
import 'package:cuidapet_api/application/logs/i_logger.dart';
import 'package:cuidapet_api/dtos/supplier_nearby_me_dto.dart';
import 'package:cuidapet_api/modules/supplier/data/i_supplier_repository.dart';
import 'package:injectable/injectable.dart';
import 'package:mysql1/mysql1.dart';

@LazySingleton(as: ISupplierRepository)
class SupplierRepository implements ISupplierRepository {
  SupplierRepository({required this.connection, required this.log});

  final IDatabaseConnection connection;
  final ILogger log;

  @override
  Future<List<SupplierNearByMeDto>> findNearByPosition(
      double lat, double lng, int distance) async {
    MySqlConnection? conn;

    try {
      conn = await connection.openConnection();
      final result = await conn.query('''
              SELECT f.id, f.nome, f.logo, f.categorias_fornecedor_id,
              (6371 *
                acos(
                                cos(radians($lat)) *
                                cos(radians(ST_X(f.latlng))) *
                                cos(radians($lng) - radians(ST_Y(f.latlng))) +
                                sin(radians($lat)) *
                                sin(radians(ST_X(f.latlng)))
                    )) AS distancia
                FROM fornecedor f
                HAVING distancia <= $distance;
          ''');

      return result
          .map((f) => SupplierNearByMeDto(
              id: f['id'] as int,
              name: f['nome'].toString(),
              logo: (f['logo'] as Blob?)?.toString(),
              distance: f['distancia'] as double,
              categoryId: f['categorias_fornecedor_id'] as int))
          .toList();
    } on MySqlException catch (e, s) {
      log.error('Erro ao buscar fornecedores perto de mim', e, s);
      throw DatabaseException();
    } finally {
      await conn?.close();
    }
  }
}

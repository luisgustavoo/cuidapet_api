import 'dart:async';

import 'package:cuidapet_api/application/database/i_database_connection.dart';
import 'package:cuidapet_api/application/exceptions/database_exception.dart';
import 'package:cuidapet_api/application/logs/i_logger.dart';
import 'package:cuidapet_api/dtos/supplier_nearby_me_dto.dart';
import 'package:cuidapet_api/entities/category.dart';
import 'package:cuidapet_api/entities/supplier.dart';
import 'package:cuidapet_api/entities/supplier_service.dart';
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
                HAVING distancia <= $distance
               ORDER BY distancia
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

  @override
  Future<Supplier?> findById(int id) async {
    MySqlConnection? conn;

    try {
      conn = await connection.openConnection();
      final result = await conn.query('''
            SELECT 
                f.id,
                f.nome,
                f.logo,
                f.endereco,
                f.telefone,
                ST_X(f.latlng) AS lat,
                ST_Y(f.latlng) AS lng,
                f.categorias_fornecedor_id,
                c.nome_categoria,
                c.tipo_categoria
            FROM
                fornecedor f
                    INNER JOIN
                categorias_fornecedor c ON (f.categorias_fornecedor_id = c.id)
            where f.id = ? 
         ''', [id]);

      if (result.isNotEmpty) {
        final dataMysql = result.first;
        return Supplier(
            id: dataMysql['id'] as int,
            name: dataMysql['nome'].toString(),
            address: dataMysql['endereco'].toString(),
            lat: dataMysql['lat'] as double,
            lng: dataMysql['lng'] as double,
            logo: (dataMysql['logo'] as Blob?).toString(),
            phone: dataMysql['telefone'].toString(),
            category: Category(
              id: dataMysql['categorias_fornecedor_id'] as int,
              name: dataMysql['nome_categoria'].toString(),
              type: dataMysql['tipo_categoria'].toString(),
            ));
      }
    } on MySqlException catch (e, s) {
      log.error('Erro ao fornecedor por id', e, s);
      throw DatabaseException();
    } finally {
      await conn?.close();
    }
  }

  @override
  Future<List<SupplierService>> findServicesBySupplierId(int supplierId) async {
    MySqlConnection? conn;

    try {
      conn = await connection.openConnection();
      final result = await conn.query('''
        SELECT 
            id, fornecedor_id, nome_servico, valor_servico
        FROM
            fornecedor_servicos
        WHERE
            fornecedor_id = ?
      ''', [supplierId]);

      if (result.isNotEmpty) {
        return result
            .map((s) => SupplierService(
                id: s['id'] as int,
                supplierId: s['fornecedor_id'] as int,
                name: s['nome_servico'].toString(),
                price: s['valor_servico'] as double))
            .toList();
      }

      return <SupplierService>[];
    } on MySqlException catch (e, s) {
      log.error('Erro ao buscar servicos de um fornecedor', e, s);
      throw DatabaseException();
    } finally {
      await conn?.close();
    }
  }

  @override
  Future<bool> checkUserEmailExists(String email) async {
    MySqlConnection? conn;

    try {
      conn = await connection.openConnection();
      final result = await conn.query('''
          SELECT 
              COUNT(*)
          FROM
              usuario
          WHERE
              email = ?
    ''', [email]);

      final dataMysql = result.first;

      return int.parse(dataMysql[0].toString()) > 0;
    } on MySqlException catch (e, s) {
      log.error('Erro ao verificar se email existe', e, s);
      throw DatabaseException();
    } finally {
      await conn?.close();
    }
  }

  @override
  Future<int> saveSupplier(Supplier supplier) async {
    MySqlConnection? conn;

    try {
      conn = await connection.openConnection();
      final result = await conn.query('''
      INSERT INTO 
         fornecedor (nome, logo, endereco, telefone, latlng, categorias_fornecedor_id) 
      VALUES (?,?,?,?,ST_GeomFromText(?),?)''', <Object?>[
        supplier.name,
        supplier.logo,
        supplier.address,
        supplier.phone,
        'POINT(${supplier.lat ?? 0} ${supplier.lng ?? 0})',
        supplier.category?.id
      ]);

      return result.insertId ?? -1;
    } on MySqlException catch (e, s) {
      log.error('Erro ao cadastrar novo fornecedor', e, s);
      throw DatabaseException();
    } finally {
      await conn?.close();
    }
  }

  @override
  Future<Supplier> update(Supplier supplier) async {
    MySqlConnection? conn;

    try {
      conn = await connection.openConnection();
      await conn.query('''
      UPDATE fornecedor 
         SET 
          nome = ?, 
          logo = ?, 
          endereco = ?, 
          telefone = ?, 
          latlng = ST_GeomFromText(?), 
          categorias_fornecedor_id = ? 
      WHERE id = ?''', <Object?>[
        supplier.name,
        supplier.logo,
        supplier.address,
        supplier.phone,
        'POINT(${supplier.lat} ${supplier.lng})',
        supplier.category?.id,
        supplier.id
      ]);

      Category? category;
      final categoryId = supplier.category?.id;
      if (categoryId != null) {
        final resultCategory = await conn.query('''
        SELECT 
            *
        FROM
            categorias_fornecedor
        WHERE
            id = ?
        ''', [categoryId]);

        final categoryData = resultCategory.first;

        category = Category(
            id: int.parse(categoryData['id'].toString()),
            name: categoryData['nome_categoria'].toString(),
            type: categoryData['tipo_categoria'].toString());
      }

      return supplier.copyWith(category: category);
    } on MySqlException catch (e, s) {
      log.error('Erro ao atualizar dados do fornecedor', e, s);
      throw DatabaseException();
    } finally {
      await conn?.close();
    }
  }
}

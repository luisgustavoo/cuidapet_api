import 'package:cuidapet_api/application/database/i_database_connection.dart';
import 'package:cuidapet_api/application/exceptions/database_exception.dart';
import 'package:cuidapet_api/application/logs/i_logger.dart';
import 'package:cuidapet_api/entities/schedule.dart';
import 'package:cuidapet_api/entities/schedule_supplier_service.dart';
import 'package:cuidapet_api/entities/supplier.dart';
import 'package:cuidapet_api/entities/supplier_service.dart';
import 'package:cuidapet_api/modules/schedule/data/i_schedule_repository.dart';
import 'package:injectable/injectable.dart';
import 'package:mysql1/mysql1.dart';

@LazySingleton(as: IScheduleRepository)
class ScheduleRepository implements IScheduleRepository {
  ScheduleRepository({required this.connection, required this.log});

  final IDatabaseConnection connection;
  final ILogger log;

  @override
  Future<void> save(Schedule schedule) async {
    MySqlConnection? conn;

    try {
      conn = await connection.openConnection();
      await conn.transaction((dynamic _) async {

        final result = await conn!.query('''
                           
           INSERT INTO agendamento(
              data_agendamento,
              usuario_id,
              fornecedor_id,
              status,
              nome,
              nome_pet
            )VALUES(
              ?,
              ?,
              ?,
              ?,
              ?,
              ?
            )
            
        ''', [
          schedule.scheduleDate.toIso8601String(),
          schedule.userId,
          schedule.supplier.id,
          schedule.status,
          schedule.name,
          schedule.petName
        ]);

        final scheduleId = result.insertId;

        if (scheduleId != null) {
          await conn.queryMulti('''
              INSERT INTO agendamento_servicos(
                agendamento_id,
                fornecedor_servicos_id
              )VALUES(
                ?,
                ?
              )
          ''', schedule.service.map((s) => [scheduleId, s.service.id]));
        }
      });
    } on MySqlException catch (e, s) {
      log.error('Erro ao agendar serviço', e, s);
      throw DatabaseException();
    } finally {
      await conn?.close();
    }
  }

  @override
  Future<void> changeStatus(String status, int scheduleId) async {
    MySqlConnection? conn;

    try {
      conn = await connection.openConnection();
      await conn.query('''
      UPDATE Agendamento
        SET
          status = ?
        WHERE id = ?
       ''', [status, scheduleId]);
    } on MySqlException catch (e, s) {
      log.error('Erro ao alterar status de um agendamento', e, s);
      throw DatabaseException();
    } finally {
      await conn?.close();
    }
  }

  @override
  Future<List<Schedule>> findAllScheduleByUser(int userId) async {
    MySqlConnection? conn;

    try {
      conn = await connection.openConnection();
      final result = await conn.query('''
           SELECT 
              a.id,
              a.data_agendamento,
              a.status,
              a.nome,
              a.nome_pet,
              f.id AS fornec_id,
              f.nome AS fornec_nome,
              f.logo
          FROM
              agendamento a
                  INNER JOIN
              fornecedor f ON f.id = a.fornecedor_id
          WHERE
              a.usuario_id = ?    
          ORDER BY data_agendamento DESC    
      ''', [userId]);

      final scheduleResult = result
          .map((s) async => Schedule(
              id: int.parse(s['id'].toString()),
              scheduleDate: DateTime.parse(s['data_agendamento'].toString()),
              status: s['status'].toString(),
              name: s['nome'].toString(),
              petName: s['nome_pet'].toString(),
              userId: userId,
              supplier: Supplier(
                  id: int.parse(s['fornec_id'].toString()),
                  name: s['fornec_nome'].toString(),
                  logo: s['logo'].toString()),
              service: await findAllServicesBySchedule(
                  int.parse(s['id'].toString()))))
          .toList();

      return Future.wait(scheduleResult);
    } on MySqlException catch (e, s) {
      log.error('Erro ao buscar agendamentos de um usuário', e, s);
      throw DatabaseException();
    } finally {
      await conn?.close();
    }
  }

  Future<List<ScheduleSupplierService>> findAllServicesBySchedule(
      int scheduleId) async {
    MySqlConnection? conn;

    try {
      conn = await connection.openConnection();
      final result = await conn.query('''
          SELECT 
              fs.id,
              fs.nome_servico,
              fs.valor_servico,
              fs.fornecedor_id
          FROM
              agendamento_servicos ags
                  INNER JOIN
              fornecedor_servicos fs ON ags.fornecedor_servicos_id = fs.id
          where ags.agendamento_id = ?      
      ''', [scheduleId]);

      return result
          .map((s) => ScheduleSupplierService(
              service: SupplierService(
                  id: int.parse(s['id'].toString()),
                  name: s['nome_servico'].toString(),
                  price: double.parse(s['valor_servico'].toString()),
                  supplierId: int.parse(s['fornecedor_id'].toString()))))
          .toList();
    } on MySqlException catch (e, s) {
      log.error('Erro ao buscar servicos de uma agendamento', e, s);
      throw DatabaseException();
    } finally {
      await conn?.close();
    }
  }

  @override
  Future<List<Schedule>> findAllScheduleByUserSupplier(int userId) async {
    MySqlConnection? conn;

    try {
      conn = await connection.openConnection();
      final result = await conn.query('''
           SELECT 
              a.id,
              a.data_agendamento,
              a.status,
              a.nome,
              a.nome_pet,
              f.id AS fornec_id,
              f.nome AS fornec_nome,
              f.logo
          FROM
              agendamento a
                  INNER JOIN
              fornecedor f ON f.id = a.fornecedor_id
                  INNER JOIN
              usuario u ON u.fornecedor_id = f.id          
          WHERE
              u.id = ?    
          ORDER BY data_agendamento DESC    
      ''', [userId]);

      final scheduleResult = result
          .map((s) async => Schedule(
              id: int.parse(s['id'].toString()),
              scheduleDate: DateTime.parse(s['data_agendamento'].toString()),
              status: s['status'].toString(),
              name: s['nome'].toString(),
              petName: s['nome_pet'].toString(),
              userId: userId,
              supplier: Supplier(
                  id: int.parse(s['fornec_id'].toString()),
                  name: s['fornec_nome'].toString(),
                  logo: s['logo'].toString()),
              service: await findAllServicesBySchedule(
                  int.parse(s['id'].toString()))))
          .toList();

      return Future.wait(scheduleResult);
    } on MySqlException catch (e, s) {
      log.error('Erro ao buscar agendamentos de um usuário', e, s);
      throw DatabaseException();
    } finally {
      await conn?.close();
    }
  }
}

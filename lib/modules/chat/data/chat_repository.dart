import 'package:cuidapet_api/application/database/i_database_connection.dart';
import 'package:cuidapet_api/application/exceptions/database_exception.dart';
import 'package:cuidapet_api/application/logs/i_logger.dart';
import 'package:cuidapet_api/entities/chat.dart';
import 'package:cuidapet_api/entities/device_token.dart';
import 'package:cuidapet_api/entities/supplier.dart';
import 'package:cuidapet_api/modules/chat/data/i_chat_repository.dart';
import 'package:injectable/injectable.dart';
import 'package:mysql1/mysql1.dart';

@LazySingleton(as: IChatRepository)
class ChatRepository implements IChatRepository {
  ChatRepository({required this.connection, required this.log});

  final ILogger log;
  final IDatabaseConnection connection;

  @override
  Future<int> startChat(int scheduleId) async {
    MySqlConnection? conn;

    try {
      conn = await connection.openConnection();
      final result = await conn.query('''
      
        INSERT INTO chats(agendamento_id, status, data_criacao) VALUES (?,?,?)
      
      ''', [scheduleId, 'A', DateTime.now().toIso8601String()]);

      return result.insertId!;
    } on MySqlException catch (e, s) {
      log.error('Erro ao iniciar chat', e, s);
      throw DatabaseException();
    } finally {
      await conn?.close();
    }
  }

  @override
  Future<Chat?> findChatById(int chatId) async {
    MySqlConnection? conn;

    try {
      conn = await connection.openConnection();
      final result = await conn.query('''
          SELECT 
              c.id,
              c.data_criacao,
              c.status,
              a.nome as agendamento_nome,
              a.nome_pet as agendamento_nome_pet,
              a.fornecedor_id,
              a.usuario_id,
              f.nome as fornec_nome,
              f.logo,
              u.android_token as user_android_token,
              u.ios_token as user_ios_token,
              uf.android_token as fornec_android_token,
              uf.ios_token as fornec_ios_token
          FROM
              chats c
                  INNER JOIN
              agendamento a ON a.id = c.agendamento_id
                  INNER JOIN
              fornecedor f ON f.id = a.fornecedor_id
                  INNER JOIN
              usuario u ON u.id = a.usuario_id
                  INNER JOIN
              usuario uf ON uf.fornecedor_id = f.id
          WHERE
              c.id = ?   
      ''', [chatId]);

      if (result.isNotEmpty) {
        final resultMysql = result.first;
        return Chat(
            id: int.parse(resultMysql['id'].toString()),
            name: resultMysql['agendamento_nome'].toString(),
            status: resultMysql['status'].toString(),
            petName: resultMysql['agendamento_nome_pet'].toString(),
            supplier: Supplier(
              id: int.parse(resultMysql['fornecedor_id'].toString()),
              name: resultMysql['fornec_nome'].toString(),
            ),
            user: int.parse(resultMysql['usuario_id'].toString()),
            userDeviceToken: DeviceToken(
                android: resultMysql['user_android_token'].toString(),
                ios: resultMysql['user_ios_token'].toString()),
            supplierDeviceToken: DeviceToken(
                android: resultMysql['fornec_android_token'].toString(),
                ios: resultMysql['fornec_ios_token'].toString()));
      }
    } on MySqlException catch (e, s) {
      log.error('Erro ao buscar chart por id', e, s);
      throw DatabaseException();
    } finally {
      await conn?.close();
    }
  }

  @override
  Future<List<Chat>> getChatsByUser(int user) async {
    MySqlConnection? conn;

    try {
      conn = await connection.openConnection();
      final result = await conn.query('''
          SELECT 
              c.id,
              c.data_criacao,
              c.status,
              a.nome,
              a.nome_pet,
              a.fornecedor_id,
              a.usuario_id,
              f.nome AS fornec_nome,
              f.logo
          FROM
              chats c
                  INNER JOIN
              agendamento a ON a.id = c.agendamento_id
                  INNER JOIN
              fornecedor f ON f.id = a.fornecedor_id
          WHERE
              a.usuario_id = ? AND a.status = 'A'
          ORDER BY c.data_criacao    
      ''', [user]);

      return result
          .map((c) => Chat(
                id: int.parse(c['id'].toString()),
                user: int.parse(c['usuario_id'].toString()),
                name: c['nome'].toString(),
                supplier: Supplier(
                    id: int.parse(c['fornecedor_id'].toString()),
                    name: c['fornec_nome'].toString(),
                    logo: c['logo'].toString()),
                status: c['status'].toString(),
                petName: c['nome_pet'].toString(),
              ))
          .toList();
    } on MySqlException catch (e, s) {
      log.error('Erro ao buscar chats de um usuario', e, s);
      throw DatabaseException();
    } finally {
      await conn?.close();
    }
  }

  @override
  Future<List<Chat>> getChatsBySupplier(int supplier) async {
    MySqlConnection? conn;

    try {
      conn = await connection.openConnection();
      final result = await conn.query('''
          SELECT 
              c.id,
              c.data_criacao,
              c.status,
              a.nome,
              a.nome_pet,
              a.fornecedor_id,
              a.usuario_id,
              f.nome AS fornec_nome,
              f.logo
          FROM
              chats c
                  INNER JOIN
              agendamento a ON a.id = c.agendamento_id
                  INNER JOIN
              fornecedor f ON f.id = a.fornecedor_id
          WHERE
              a.fornecedor_id = ? AND a.status = 'A'
          ORDER BY c.data_criacao          
      ''', [supplier  ]);


      return result
          .map((c) => Chat(
        id: int.parse(c['id'].toString()),
        user: int.parse(c['usuario_id'].toString()),
        name: c['nome'].toString(),
        supplier: Supplier(
            id: int.parse(c['fornecedor_id'].toString()),
            name: c['fornec_nome'].toString(),
            logo: c['logo'].toString()),
        status: c['status'].toString(),
        petName: c['nome_pet'].toString(),
      ))
          .toList();

    } on MySqlException catch (e, s) {
      log.error('Erro ao buscar os chats do fornecedor', e, s);
      throw DatabaseException();
    } finally {
      await conn?.close();
    }
  }
}

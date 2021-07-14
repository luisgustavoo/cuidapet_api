import 'dart:convert';

import 'package:cuidapet_api/application/helpers/jwt_helper.dart';
import 'package:cuidapet_api/application/logs/i_logger.dart';
import 'package:cuidapet_api/application/middlewares/middlewares.dart';
import 'package:cuidapet_api/application/middlewares/security/security_skip_url.dart';
import 'package:jaguar_jwt/jaguar_jwt.dart';
import 'package:shelf/shelf.dart';

class SecurityMiddleware extends Middlewares {
  SecurityMiddleware(this.log);

  final skipUrl = <SecuritySkipUrl>[
    const SecuritySkipUrl(url: '/auth/register', method: 'POST'),
    const SecuritySkipUrl(url: '/auth/', method: 'POST')
  ];
  final ILogger log;

  @override
  Future<Response> execute(Request request) async {
    try {
      if (skipUrl.contains(
          SecuritySkipUrl(url: '/${request.url}', method: request.method))) {
        return innerHandler(request);
      }

      final authHeader = request.headers['Authorization'];

      if (authHeader == null || authHeader.isEmpty) {
        throw JwtException.invalidToken;
      }

      final authHeaderContent = authHeader.split(' ');

      if (authHeaderContent[0] != 'Bearer') {
        throw JwtException.invalidToken;
      }

      final authorizationToken = authHeaderContent[1];

      final claims = JwtHelper.getClaims(authorizationToken);

      if (request.method != '/auth/refresh') {
        claims.validate();
      }

      final claimsMap = claims.toJson();

      final userId = claimsMap['sub'].toString();
      final supplierId = claimsMap['supplier'].toString();

      if (userId.isEmpty) {
        throw JwtException.invalidToken;
      }

      final securityHeaders = <String, dynamic>{
        'user': userId,
        'access_token': authorizationToken,
        'supplier': supplierId
      };

      return innerHandler(request.change(headers: securityHeaders));
    } on JwtException catch (e, s) {
      log.error('Erro ao validar token JWT', e, s);
      return Response.forbidden(jsonEncode(<String, dynamic>{}));
    } on Exception catch (e, s) {
      log.error('Internal server error', e, s);
      return Response.forbidden(jsonEncode(<String, dynamic>{}));
    }
  }
}

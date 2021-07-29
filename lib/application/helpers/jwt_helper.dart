import 'package:dotenv/dotenv.dart';
import 'package:jaguar_jwt/jaguar_jwt.dart';

class JwtHelper {
  JwtHelper._();

  static final String _jwtSecret = env['jwt_secret'] ?? env['jwt_dev_secret']!;

  static String generateJWT(int userId, int? supplierId) {
    final claimSet = JwtClaim(
        issuer: 'cuidapet',
        subject: userId.toString(),
        expiry: DateTime.now().add(const Duration(days: 1)),
        //expiry: DateTime.now().add(const Duration(seconds: 20)),
        notBefore: DateTime.now(),
        issuedAt: DateTime.now(),
        otherClaims: <String, dynamic>{'supplier': supplierId},
        maxAge: const Duration(days: 1));

    return 'Bearer ${issueJwtHS256(claimSet, _jwtSecret)}';
  }

  static JwtClaim getClaims(String token) {
    return verifyJwtHS256Signature(token, _jwtSecret);
  }

  static String refreshToken(String accessToken) {
    final claimSet = JwtClaim(
      issuer: accessToken,
      subject: 'RefreshToken',
      expiry: DateTime.now().add(const Duration(days: 10)),
      notBefore: DateTime.now(),
      otherClaims: <String, dynamic>{},
    );

    return 'Bearer ${issueJwtHS256(claimSet, _jwtSecret)}';
  }
}

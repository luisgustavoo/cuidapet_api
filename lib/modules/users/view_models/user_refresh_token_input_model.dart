import '../../../application/helpers/request_mapping.dart';

class UserRefreshTokenInputModel extends RequestMapping {
  UserRefreshTokenInputModel(String dataRequest,
      {required this.user, required this.supplier, required this.accessToken})
      : super(dataRequest);

  final int user;
  final int supplier;
  final String accessToken;
  late String refreshToken;

  @override
  void map() {
    refreshToken = data['refresh_token']?.toString() ?? '';
  }
}

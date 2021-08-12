import '../../../application/helpers/request_mapping.dart';

class UpdateUrlAvatarViewModel extends RequestMapping {
  UpdateUrlAvatarViewModel({required String dataRequest, required this.userId})
      : super(dataRequest);

  late int userId;
  late String urlAvatar;

  @override
  void map() {
    urlAvatar = data['url_avatar'].toString();
  }
}

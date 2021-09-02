class DeviceToken {
  DeviceToken({this.android, this.ios});

  final String? android;
  final String? ios;

  List<String?> get tokens => [android, ios];
}

import 'package:cuidapet_api/application/helpers/request_mapping.dart';

class SupplierUpdateInputModel extends RequestMapping {
  SupplierUpdateInputModel(
      {required String dataRequest, required this.supplierId})
      : super(dataRequest);

  int supplierId;
  late String name;
  late String logo;
  late String address;
  late String phone;
  late double lat;
  late double lng;
  late int categoryId;

  @override
  void map() {
    name = data['name'].toString();
    logo = data['logo'].toString();
    address = data['address'].toString();
    phone = data['phone'].toString();
    lat = double.parse(data['lat'].toString());
    lng = double.parse(data['lng'].toString());
    categoryId = int.parse(data['category'].toString());
  }
}

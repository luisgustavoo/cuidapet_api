import 'package:cuidapet_api/application/helpers/request_mapping.dart';

class CreateSupplierUserViewModel extends RequestMapping {
  CreateSupplierUserViewModel(String dataRequest) : super(dataRequest);

  late String supplierName;
  late String email;
  late String password;
  late int category;

  @override
  void map() {
    supplierName = data['supplier_name'].toString();
    email = data['email'].toString();
    password = data['password'].toString();
    category = int.parse(data['category_id'].toString());
  }
}

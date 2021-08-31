import 'package:cuidapet_api/application/helpers/request_mapping.dart';

class ScheduleSaveInputModel extends RequestMapping {
  ScheduleSaveInputModel({required this.userId, required String dataRequest})
      : super(dataRequest);

  int userId;
  late DateTime scheduleDate;
  late String name;
  late String petName;
  late int supplierId;
  late List<int> services;

  @override
  void map() {
    scheduleDate = DateTime.parse(data['schedule_date'].toString());
    name = data['name'].toString();
    petName = data['pet_name'].toString();
    supplierId = int.parse(data['supplier_id'].toString());
    services = List.castFrom<dynamic, int>(data['services'] as List);
  }
}

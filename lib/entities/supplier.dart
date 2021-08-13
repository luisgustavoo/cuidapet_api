import 'package:cuidapet_api/entities/category.dart';

class Supplier {
  Supplier(
      {this.id,
      this.name,
      this.logo,
      this.address,
      this.phone,
      this.lat,
      this.lng,
      this.category});

  final int? id;
  final String? name;
  final String? logo;
  final String? address;
  final String? phone;
  final double? lat;
  final double? lng;
  final Category? category;
}

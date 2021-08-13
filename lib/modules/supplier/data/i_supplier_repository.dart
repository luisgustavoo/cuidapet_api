import 'package:cuidapet_api/dtos/supplier_nearby_me_dto.dart';

abstract class ISupplierRepository {
  Future<List<SupplierNearByMeDto>> findNearByPosition(
      double lat, double lng, int distance);
}

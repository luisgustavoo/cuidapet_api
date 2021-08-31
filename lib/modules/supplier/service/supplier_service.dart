import 'package:cuidapet_api/dtos/supplier_nearby_me_dto.dart';
import 'package:cuidapet_api/entities/supplier.dart';
import 'package:cuidapet_api/entities/supplier_service.dart' as entity;
import 'package:cuidapet_api/modules/supplier/data/i_supplier_repository.dart';
import 'package:cuidapet_api/modules/supplier/service/i_supplier_service.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: ISupplierService)
class SupplierService implements ISupplierService {
  SupplierService({required this.repository});

  final ISupplierRepository repository;

  static const distance = 5;

  @override
  Future<List<SupplierNearByMeDto>> findNearByMe(double lat, double lng) =>
      repository.findNearByPosition(lat, lng, distance);

  @override
  Future<Supplier?> findById(int id) => repository.findById(id);

  @override
  Future<List<entity.SupplierService>> findServicesBySupplier(int supplierId) =>
      repository.findServicesBySupplierId(supplierId);

  @override
  Future<bool> checkUserEmailExists(String email) =>
      repository.checkUserEmailExists(email);
}

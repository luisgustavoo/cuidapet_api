import 'package:cuidapet_api/dtos/supplier_nearby_me_dto.dart';
import 'package:cuidapet_api/entities/supplier.dart';
import 'package:cuidapet_api/entities/supplier_service.dart';
import 'package:cuidapet_api/modules/supplier/view_models/create_supplier_user_view_model.dart';
import 'package:cuidapet_api/modules/supplier/view_models/supplier_update_input_model.dart';

abstract class ISupplierService {
  Future<List<SupplierNearByMeDto>> findNearByMe(double lat, double lng);

  Future<Supplier?> findById(int id);

  Future<List<SupplierService>> findServicesBySupplier(int supplierId);

  Future<bool> checkUserEmailExists(String email);

  Future<void> createUserSupplier(CreateSupplierUserViewModel viewModel);

  Future<Supplier> update(SupplierUpdateInputModel model);
}

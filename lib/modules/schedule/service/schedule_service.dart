import 'package:cuidapet_api/entities/schedule.dart';
import 'package:cuidapet_api/entities/schedule_supplier_service.dart';
import 'package:cuidapet_api/entities/supplier.dart';
import 'package:cuidapet_api/entities/supplier_service.dart';
import 'package:cuidapet_api/modules/schedule/view_models/schedule_save_input_model.dart';
import 'package:cuidapet_api/modules/schedule/data/i_schedule_repository.dart';
import 'package:cuidapet_api/modules/schedule/service/i_schedule_service.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: IScheduleService)
class ScheduleService implements IScheduleService {
  ScheduleService({required this.repository});

  final IScheduleRepository repository;

  @override
  Future<void> scheduleService(ScheduleSaveInputModel model) async {
    final schedule = Schedule(
        scheduleDate: model.scheduleDate,
        name: model.name,
        petName: model.petName,
        supplier: Supplier(id: model.supplierId),
        status: 'P',
        userId: model.userId,
        service: model.services
            .map(
                (e) => ScheduleSupplierService(service: SupplierService(id: e)))
            .toList());

    await repository.save(schedule);
  }

  @override
  Future<void> changeStatus(String status, int scheduleId) =>
      repository.changeStatus(status, scheduleId);

  @override
  Future<List<Schedule>> findAllScheduleByUser(int userId) =>
      repository.findAllScheduleByUser(userId);

  @override
  Future<List<Schedule>> findAllScheduleByUserSupplier(int userId) =>
      repository.findAllScheduleByUserSupplier(userId);
}

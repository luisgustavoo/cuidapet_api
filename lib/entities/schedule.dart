import 'package:cuidapet_api/entities/schedule_supplier_service.dart';
import 'package:cuidapet_api/entities/supplier.dart';

class Schedule {
  Schedule(
      {required this.scheduleDate,
      required this.status,
      required this.name,
      required this.petName,
      required this.userId,
      required this.supplier,
      required this.service,
      this.id});

  final int? id;
  final DateTime scheduleDate;
  final String status;
  final String name;
  final String petName;
  final int userId;
  final Supplier supplier;
  final List<ScheduleSupplierService> service;
}

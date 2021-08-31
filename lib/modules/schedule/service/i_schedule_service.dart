import 'package:cuidapet_api/modules/schedule/view_models/schedule_save_input_model.dart';

abstract class IScheduleService {
  Future<void> scheduleService(ScheduleSaveInputModel model);
}
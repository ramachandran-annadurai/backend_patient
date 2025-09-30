import '../services/patient_service/save_sleep_log_service.dart';
import '../models/sleep_log.dart';
import '../models/save_sleep_log_response.dart';

class SleepLogRepository {
  final SaveSleepLogService _saveSleepLog = SaveSleepLogService();

  Future<SaveSleepLogResponseModel> saveSleepLog(SleepLogModel sleepLog) async {
    return await _saveSleepLog.call(sleepLog);
  }
}

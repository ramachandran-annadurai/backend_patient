import '../services/patient_service/save_kick_session_service.dart';
import '../services/patient_service/get_kick_history_service.dart';
import '../models/kick_counter_request.dart';
import '../models/kick_counter_response.dart';

class KickRepository {
  final SaveKickSessionService _save = SaveKickSessionService();
  final GetKickHistoryService _history = GetKickHistoryService();

  Future<KickCounterResponseModel> saveSession(KickCounterRequestModel data) =>
      _save.call(data);

  Future<Map<String, dynamic>> getHistory(String userId) =>
      _history.call(userId);
}

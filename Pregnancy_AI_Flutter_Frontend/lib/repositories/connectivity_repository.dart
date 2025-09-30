import '../services/patient_service/check_network_connectivity_service.dart';
import '../services/patient_service/check_backend_accessibility_service.dart';
import '../services/patient_service/test_backend_connectivity_service.dart';

class ConnectivityRepository {
  final CheckNetworkConnectivityService _checkNetwork = CheckNetworkConnectivityService();
  final CheckBackendAccessibilityService _checkBackend = CheckBackendAccessibilityService();
  final TestBackendConnectivityService _testBackend = TestBackendConnectivityService();

  Future<bool> checkNetwork() => _checkNetwork.call();
  Future<bool> checkBackend() => _checkBackend.call();
  Future<Map<String, dynamic>> testBackend() => _testBackend.call();
}



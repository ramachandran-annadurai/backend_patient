import 'package:flutter/material.dart';
import '../services/patient_service/check_network_connectivity_service.dart';
import '../services/patient_service/check_backend_accessibility_service.dart';
import '../services/patient_service/test_backend_connectivity_service.dart';
import '../services/patient_service/api_login_service.dart';
import '../services/patient_service/signup_service.dart';
import '../utils/constants.dart';

class NetworkDiagnosticScreen extends StatefulWidget {
  const NetworkDiagnosticScreen({Key? key}) : super(key: key);

  @override
  State<NetworkDiagnosticScreen> createState() =>
      _NetworkDiagnosticScreenState();
}

class _NetworkDiagnosticScreenState extends State<NetworkDiagnosticScreen> {
  bool _isLoading = false;
  Map<String, dynamic> _diagnosticResults = {};
  String _statusMessage = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Network Diagnostics'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Network Status',
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _statusMessage.isEmpty
                          ? 'Tap "Run Diagnostics" to check network connectivity'
                          : _statusMessage,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _runDiagnostics,
              icon: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.network_check),
              label: Text(
                  _isLoading ? 'Running Diagnostics...' : 'Run Diagnostics'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
            const SizedBox(height: 16),
            if (_diagnosticResults.isNotEmpty) ...[
              Expanded(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Diagnostic Results',
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 16),
                        Expanded(
                          child: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: _buildDiagnosticResults(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  List<Widget> _buildDiagnosticResults() {
    List<Widget> widgets = [];

    // Network connectivity
    if (_diagnosticResults.containsKey('network_connected')) {
      widgets.add(_buildResultItem(
        'Internet Connection',
        _diagnosticResults['network_connected'] ? 'Connected' : 'Disconnected',
        _diagnosticResults['network_connected'] ? Colors.green : Colors.red,
      ));
    }

    // Backend accessibility
    if (_diagnosticResults.containsKey('backend_accessible')) {
      widgets.add(_buildResultItem(
        'Backend Server',
        _diagnosticResults['backend_accessible']
            ? 'Accessible'
            : 'Not Accessible',
        _diagnosticResults['backend_accessible'] ? Colors.green : Colors.red,
      ));
    }

    // Backend connectivity test
    if (_diagnosticResults.containsKey('backend_connectivity')) {
      final connectivity = _diagnosticResults['backend_connectivity'];
      widgets.add(_buildResultItem(
        'Backend Connectivity Test',
        connectivity['success'] ? 'Success' : 'Failed',
        connectivity['success'] ? Colors.green : Colors.red,
      ));

      if (connectivity['best_url'] != null) {
        widgets.add(_buildResultItem(
          'Best URL',
          connectivity['best_url'],
          Colors.blue,
        ));
      }
    }

    // API endpoints test
    if (_diagnosticResults.containsKey('api_endpoints')) {
      final endpoints = _diagnosticResults['api_endpoints'];
      widgets.add(_buildResultItem(
        'API Endpoints Test',
        'Completed',
        Colors.blue,
      ));

      endpoints.forEach((endpoint, status) {
        widgets.add(_buildResultItem(
          '  $endpoint',
          status ? 'OK' : 'Failed',
          status ? Colors.green : Colors.red,
        ));
      });
    }

    return widgets;
  }

  Widget _buildResultItem(String title, String status, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: color.withOpacity(0.3)),
            ),
            child: Text(
              status,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _runDiagnostics() async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Running network diagnostics...';
      _diagnosticResults.clear();
    });

    try {
      // Test 1: Basic network connectivity
      setState(() {
        _statusMessage = 'Checking internet connection...';
      });
      final networkConnected = await CheckNetworkConnectivityService().call();
      _diagnosticResults['network_connected'] = networkConnected;

      if (!networkConnected) {
        setState(() {
          _statusMessage = '❌ No internet connection detected';
          _isLoading = false;
        });
        return;
      }

      // Test 2: Backend accessibility
      setState(() {
        _statusMessage = 'Checking backend server accessibility...';
      });
      final backendAccessible = await CheckBackendAccessibilityService().call();
      _diagnosticResults['backend_accessible'] = backendAccessible;

      // Test 3: Backend connectivity test
      setState(() {
        _statusMessage = 'Testing backend connectivity...';
      });
      final connectivityTest = await TestBackendConnectivityService().call();
      _diagnosticResults['backend_connectivity'] = connectivityTest;

      // Test 4: Test specific API endpoints
      setState(() {
        _statusMessage = 'Testing API endpoints...';
      });
      final endpointResults = await _testApiEndpoints();
      _diagnosticResults['api_endpoints'] = endpointResults;

      setState(() {
        _statusMessage = '✅ Diagnostics completed';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _statusMessage = '❌ Diagnostic error: $e';
        _isLoading = false;
      });
    }
  }

  Future<Map<String, bool>> _testApiEndpoints() async {
    final results = <String, bool>{};

    // Test login endpoint
    try {
      final response = await ApiLoginService().call(
        loginIdentifier: 'test@example.com',
        password: 'testpassword',
        role: 'patient',
      );
      results['Login Endpoint'] = !response.containsKey('error');
    } catch (e) {
      results['Login Endpoint'] = false;
    }

    // Test signup endpoint
    try {
      final response = await SignupService().call(
          username: 'testuser',
          email: 'test@example.com',
          mobile: '1234567890',
          password: 'testpassword',
          role: 'patient',
          firstName: 'Test',
          lastName: 'User',
          isPregnant: false);
      results['Signup Endpoint'] = response.status == 'otp_sent';
    } catch (e) {
      results['Signup Endpoint'] = false;
    }

    return results;
  }
}

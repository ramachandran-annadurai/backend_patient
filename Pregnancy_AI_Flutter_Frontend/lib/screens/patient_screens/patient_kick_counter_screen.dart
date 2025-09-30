import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/kick_counter_provider.dart';
import '../../models/kick_counter_request.dart';
import '../../widgets/app_background.dart';
import '../../widgets/gradient_button.dart';
import '../../theme/app_theme.dart';

class PatientKickCounterScreen extends StatefulWidget {
  final String userId;
  final String userRole;
  final String username;
  final String email;

  const PatientKickCounterScreen({
    Key? key,
    required this.userId,
    required this.userRole,
    required this.username,
    required this.email,
  }) : super(key: key);

  @override
  State<PatientKickCounterScreen> createState() =>
      _PatientKickCounterScreenState();
}

class _PatientKickCounterScreenState extends State<PatientKickCounterScreen> {
  int _kickCount = 0;
  DateTime? _sessionStartTime;
  bool _isSessionActive = false;
  List<Map<String, dynamic>> _kickLogs = [];

  @override
  void initState() {
    super.initState();
    _loadKickHistory();
  }

  void _startSession() {
    setState(() {
      _isSessionActive = true;
      _sessionStartTime = DateTime.now();
      _kickCount = 0;
    });
  }

  void _stopSession() {
    if (_isSessionActive && _kickCount > 0) {
      _saveKickSession();
    }
    setState(() {
      _isSessionActive = false;
      _sessionStartTime = null;
    });
  }

  void _logKick() {
    if (_isSessionActive) {
      setState(() {
        _kickCount++;
      });
    }
  }

  void _resetSession() {
    setState(() {
      _kickCount = 0;
      _sessionStartTime = null;
      _isSessionActive = false;
    });
  }

  // Removed unused _formatDuration helper

  Duration _getSessionDuration() {
    if (_sessionStartTime == null) return Duration.zero;
    return DateTime.now().difference(_sessionStartTime!);
  }

  Future<void> _saveKickSession() async {
    if (_kickCount == 0) return;

    try {
      // Get Patient ID from user info for precise patient linking
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final userInfo = await authProvider.getCurrentUserInfo();

      final String? patientId = userInfo['userId'];
      if (patientId == null) {
        throw Exception(
            'Patient ID not found. Please ensure you are logged in.');
      }

      final kickData = KickCounterRequestModel(
        userId: patientId,
        userRole: widget.userRole,
        username: widget.username,
        kickCount: _kickCount,
        sessionDuration: _getSessionDuration().inSeconds,
        sessionStartTime: _sessionStartTime?.toIso8601String(),
        sessionEndTime: DateTime.now().toIso8601String(),
        averageKicksPerMinute: _kickCount /
            (_getSessionDuration().inMinutes > 0
                ? _getSessionDuration().inMinutes
                : 1),
        notes: 'Kick counting session',
        timestamp: DateTime.now().toIso8601String(),
      );

      // Save kick session data via provider
      final vm = Provider.of<KickCounterProvider>(context, listen: false);
      final success = await vm.saveSession(kickData);

      if (success) {
        // Add to local kick logs
        setState(() {
          _kickLogs.add({
            'kickCount': _kickCount,
            'sessionDuration': _getSessionDuration().inSeconds,
            'timestamp': DateTime.now().toIso8601String(),
          });
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Kick session saved successfully!'),
            backgroundColor: Colors.green,
          ),
        );

        // Reset for next session
        _resetSession();
      } else {
        throw Exception(vm.error ?? 'Failed to save kick session');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving kick session: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _loadKickHistory() async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final userInfo = await authProvider.getCurrentUserInfo();

      final String? patientId = userInfo['userId'];
      if (patientId != null) {
        // Load kick history via provider
        final vm = Provider.of<KickCounterProvider>(context, listen: false);
        await vm.loadHistory(patientId);
        setState(() {
          _kickLogs = vm.kickLogs;
        });
      }
    } catch (e) {
      print('Error loading kick history: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final sessionDuration = _getSessionDuration();

    return AppScaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              const SizedBox(height: 20),

              // Header with back button and title (like symptoms page)
              Container(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back,
                          color: AppTheme.textGray),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          const Text(
                            'Kick Count',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: AppTheme.textGray,
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            'October 26, 2023', // You can make this dynamic
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: AppTheme.textGray.withOpacity(0.7),
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 48), // Balance the back button
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // Kick Count Circle
              Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '$_kickCount',
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.brightPink,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'kicks',
                      style: TextStyle(
                        fontSize: 16,
                        color: AppTheme.textGray,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // Session Timer
              Column(
                children: [
                  Text(
                    'Session Timer',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppTheme.textGray,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${sessionDuration.inHours.toString().padLeft(2, '0')}:${sessionDuration.inMinutes.remainder(60).toString().padLeft(2, '0')}:${sessionDuration.inSeconds.remainder(60).toString().padLeft(2, '0')}',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.darkGray,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 40),

              // Weekly Trend Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 20,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Weekly Trend Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Expanded(
                          child: Text(
                            'Weekly Trend',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.darkGray,
                            ),
                          ),
                        ),
                        Flexible(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Icon(
                                Icons.chevron_left,
                                color: AppTheme.textGray,
                                size: 20,
                              ),
                              SizedBox(width: 6),
                              Flexible(
                                child: Text(
                                  'Oct 22 - Oct 28',
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: AppTheme.textGray,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              SizedBox(width: 6),
                              Icon(
                                Icons.chevron_right,
                                color: AppTheme.textGray,
                                size: 20,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Chart area with actual data
                    Container(
                      height: 120,
                      decoration: BoxDecoration(
                        color: AppTheme.lightGray.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: _kickLogs.isNotEmpty
                          ? _buildSimpleChart()
                          : Center(
                              child: Text(
                                'No data available',
                                style: TextStyle(
                                  color: AppTheme.textGray.withOpacity(0.6),
                                  fontSize: 14,
                                ),
                              ),
                            ),
                    ),

                    const SizedBox(height: 20),

                    // Days of week
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: ['S', 'M', 'Tu', 'W', 'Th', 'F', 'S']
                          .asMap()
                          .entries
                          .map((entry) {
                        final index = entry.key;
                        final day = entry.value;
                        final isHighlighted = index == 4; // Thursday

                        return Text(
                          day,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: isHighlighted
                                ? AppTheme.brightPink
                                : AppTheme.textGray,
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Action Buttons
              Column(
                children: [
                  // Log Kick Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: GradientButton(
                      text: 'Log Kick',
                      onPressed: _isSessionActive ? _logKick : null,
                      startColor: AppTheme.brightBlue,
                      endColor: AppTheme.brightPink,
                      width: double.infinity,
                      height: 56,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Start and End Session Buttons
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 48,
                          child: GradientButton(
                            text: 'Start',
                            onPressed: !_isSessionActive ? _startSession : null,
                            startColor: AppTheme.brightBlue,
                            endColor: Colors.purple,
                            height: 48,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: SizedBox(
                          height: 48,
                          child: GradientButton(
                            text: 'End Session',
                            onPressed: _isSessionActive ? _stopSession : null,
                            startColor: Colors.purple,
                            endColor: AppTheme.brightBlue,
                            height: 48,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 40),

              // Kick History Section
              if (_kickLogs.isNotEmpty) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 20,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Recent Sessions',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.darkGray,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ...(_kickLogs.take(5).map((log) {
                        final timestamp =
                            DateTime.tryParse(log['timestamp'] ?? '');
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppTheme.lightGray.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.child_care,
                                color: AppTheme.brightPink,
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${log['kickCount']} kicks',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: AppTheme.darkGray,
                                      ),
                                    ),
                                    if (timestamp != null)
                                      Text(
                                        '${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')} - ${log['sessionDuration']} seconds',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: AppTheme.textGray,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              Icon(
                                Icons.check_circle,
                                color: Colors.green,
                                size: 16,
                              ),
                            ],
                          ),
                        );
                      }).toList()),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSimpleChart() {
    if (_kickLogs.isEmpty) return const SizedBox.shrink();

    final maxKicks = _kickLogs
        .map((log) => log['kickCount'] as int)
        .reduce((a, b) => a > b ? a : b);
    final chartHeight = 80.0;

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: _kickLogs.take(7).map((log) {
          final kickCount = log['kickCount'] as int;
          final height =
              maxKicks > 0 ? (kickCount / maxKicks) * chartHeight : 0.0;

          return Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                width: 16,
                height: height.clamp(4.0, chartHeight),
                decoration: BoxDecoration(
                  color: AppTheme.brightPink,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                kickCount.toString(),
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textGray,
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}

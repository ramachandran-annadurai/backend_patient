import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/sleep_log_provider.dart';
import '../../models/sleep_log.dart';
import '../../widgets/app_background.dart';
import '../../widgets/gradient_button.dart';
import '../../theme/app_theme.dart';

class PatientSleepLogScreen extends StatefulWidget {
  final String userId;
  final String userRole;
  final String username;
  final String email;

  const PatientSleepLogScreen({
    Key? key,
    required this.userId,
    required this.userRole,
    required this.username,
    required this.email,
  }) : super(key: key);

  @override
  State<PatientSleepLogScreen> createState() => _PatientSleepLogScreenState();
}

class _PatientSleepLogScreenState extends State<PatientSleepLogScreen> {
  TimeOfDay _startTime = TimeOfDay(hour: 22, minute: 0); // 10:00 PM
  TimeOfDay _endTime = TimeOfDay(hour: 6, minute: 0); // 6:00 AM
  bool _smartAlarmEnabled = false;
  String? _selectedSleepRating;

  @override
  void initState() {
    super.initState();
    _calculateTotalSleep();

    // Debug logging to see what arguments were received
    print('🔍 Sleep Log Screen Debug - Received Arguments:');
    print('  Email: ${widget.email}');
    print('  Username: ${widget.username}');
    print('  UserId: ${widget.userId}');
    print('  UserRole: ${widget.userRole}');
  }

  void _calculateTotalSleep() {
    setState(() {});
  }

  Duration get _totalSleepDuration {
    final start = DateTime(2024, 1, 1, _startTime.hour, _startTime.minute);
    final end = DateTime(2024, 1, 1, _startTime.hour, _startTime.minute);

    Duration duration;
    if (_endTime.hour < _startTime.hour) {
      // Sleep crosses midnight
      final nextDay = DateTime(2024, 1, 2, _endTime.hour, _endTime.minute);
      duration = nextDay.difference(start);
    } else {
      duration = end.difference(start);
    }

    return duration;
  }

  String get _totalSleepText {
    final hours = _totalSleepDuration.inHours;
    final minutes = _totalSleepDuration.inMinutes % 60;
    if (minutes == 0) {
      return '$hours hours';
    }
    return '$hours hours $minutes minutes';
  }

  TimeOfDay get _optimalWakeUpTime {
    // Simple calculation: wake up 15 minutes after end time
    final optimalHour = _endTime.hour;
    final optimalMinute = (_endTime.minute + 15) % 60;
    return TimeOfDay(hour: optimalHour, minute: optimalMinute);
  }

  Future<void> _selectTime(BuildContext context, bool isStartTime) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isStartTime ? _startTime : _endTime,
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.purple,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        if (isStartTime) {
          _startTime = picked;
        } else {
          _endTime = picked;
        }
        _calculateTotalSleep();
      });
    }
  }

  Future<void> _saveSleepLog() async {
    if (_selectedSleepRating == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a sleep rating'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      // Get Patient ID from user info for precise patient linking
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final userInfo = await authProvider.getCurrentUserInfo();

      final String? patientId = userInfo['userId'];
      if (patientId == null) {
        throw Exception(
            'Patient ID not found. Please ensure you are logged in.');
      }

      // Create SleepLogModel following MVVM pattern
      final sleepLog = SleepLogModel(
        userId: patientId,
        userRole: widget.userRole,
        username: widget.username,
        startTime:
            '${_startTime.hour.toString().padLeft(2, '0')}:${_startTime.minute.toString().padLeft(2, '0')}',
        endTime:
            '${_endTime.hour.toString().padLeft(2, '0')}:${_endTime.minute.toString().padLeft(2, '0')}',
        totalSleep: _totalSleepText,
        smartAlarmEnabled: _smartAlarmEnabled,
        optimalWakeUpTime:
            '${_optimalWakeUpTime.hour.toString().padLeft(2, '0')}:${_optimalWakeUpTime.minute.toString().padLeft(2, '0')}',
        sleepRating: _selectedSleepRating!,
        notes: null, // No notes in simplified design
        timestamp: DateTime.now().toIso8601String(),
      );

      // Use SleepLogProvider following MVVM pattern
      final sleepLogProvider =
          Provider.of<SleepLogProvider>(context, listen: false);
      final success = await sleepLogProvider.saveSleepLog(sleepLog);

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(sleepLogProvider.successMessage ??
                'Sleep log saved successfully!'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 4),
          ),
        );

        // Show additional success details if available
        if (sleepLogProvider.response != null) {
          final response = sleepLogProvider.response!;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Total sleep logs: ${response.sleepLogsCount}'),
              backgroundColor: Colors.blue,
              duration: const Duration(seconds: 2),
            ),
          );
        }

        // Navigate back to daily log page
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                sleepLogProvider.errorMessage ?? 'Failed to save sleep log'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height -
                  MediaQuery.of(context).padding.top -
                  MediaQuery.of(context).padding.bottom,
            ),
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
                              'Sleep',
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

                // Track Your Sleep Card
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
                      // Track Your Sleep Header
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppTheme.brightBlue.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.nightlight_round,
                              color: AppTheme.brightBlue,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Track Your Sleep',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.darkGray,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // When did you go to sleep?
                      _buildTimeInputCard(
                        label: 'When did you go to sleep?',
                        time: _startTime,
                        onTap: () => _selectTime(context, true),
                      ),

                      const SizedBox(height: 20),

                      // When did you wake up?
                      _buildTimeInputCard(
                        label: 'When did you wake up?',
                        time: _endTime,
                        onTap: () => _selectTime(context, false),
                      ),

                      const SizedBox(height: 24),

                      // How was your sleep? - Good/Bad buttons like in image
                      Text(
                        'How was your sleep?',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.darkGray,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _buildSleepRatingButton(
                              'Good',
                              Icons.sentiment_very_satisfied,
                              _selectedSleepRating == 'Good',
                              Colors.green,
                              () =>
                                  setState(() => _selectedSleepRating = 'Good'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildSleepRatingButton(
                              'Bad',
                              Icons.sentiment_very_dissatisfied,
                              _selectedSleepRating == 'Bad',
                              Colors.red,
                              () =>
                                  setState(() => _selectedSleepRating = 'Bad'),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 32),

                      // Save Sleep Data Button
                      Consumer<SleepLogProvider>(
                        builder: (context, sleepLogProvider, child) {
                          return GradientButton(
                            text: 'Save Sleep Data',
                            onPressed: sleepLogProvider.isSaving
                                ? null
                                : _saveSleepLog,
                            startColor: AppTheme.brightBlue,
                            endColor: AppTheme.brightPink,
                            width: double.infinity,
                            height: 56,
                          );
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Sleep Trends Card (like in the image)
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              'Sleep Trends',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.darkGray,
                              ),
                            ),
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _buildTrendToggle('Weekly', true),
                              const SizedBox(width: 8),
                              _buildTrendToggle('Monthly', false),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      // Simple bar chart representation
                      _buildSimpleBarChart(),
                    ],
                  ),
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTimeInputCard({
    required String label,
    required TimeOfDay time,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: AppTheme.darkGray,
          ),
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            decoration: BoxDecoration(
              color: AppTheme.lightGray,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.lightGray),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.access_time,
                  color: AppTheme.textGray,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Text(
                  time.format(context),
                  style: TextStyle(
                    fontSize: 16,
                    color: AppTheme.darkGray,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                Icon(
                  Icons.access_time,
                  color: AppTheme.textGray,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSleepRatingButton(
    String text,
    IconData icon,
    bool isSelected,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : color.withOpacity(0.3),
            width: 2,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : color,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              text,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrendToggle(String text, bool isSelected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? AppTheme.brightBlue : Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isSelected ? AppTheme.brightBlue : AppTheme.textGray,
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: isSelected ? Colors.white : AppTheme.textGray,
        ),
      ),
    );
  }

  Widget _buildSimpleBarChart() {
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final heights = [0.6, 0.7, 0.5, 1.0, 0.8, 0.9, 0.7]; // Relative heights
    final screenWidth = MediaQuery.of(context).size.width;
    final maxHeight = 100.0; // Reduced to accommodate tooltip and text
    final barWidth = (screenWidth - 80) / 7; // Responsive bar width

    return Container(
      height: 180, // Increased height to accommodate tooltip
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: days.asMap().entries.map((entry) {
          final index = entry.key;
          final day = entry.value;
          final height = heights[index] * maxHeight;
          final isHighlighted =
              day == 'Thu'; // Highlight Thursday like in image

          return Flexible(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (isHighlighted)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppTheme.brightBlue,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '8h 15m',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                if (isHighlighted) const SizedBox(height: 4),
                Container(
                  width: barWidth.clamp(16.0, 32.0), // Min 16, Max 32
                  height: height,
                  decoration: BoxDecoration(
                    color: isHighlighted
                        ? AppTheme.brightBlue
                        : AppTheme.brightBlue.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  day,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.textGray,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/app_background.dart';
import '../../theme/app_theme.dart';

class PatientDailyLogScreen extends StatefulWidget {
  const PatientDailyLogScreen({super.key});

  @override
  State<PatientDailyLogScreen> createState() => _PatientDailyLogScreenState();
}

class _PatientDailyLogScreenState extends State<PatientDailyLogScreen> {
  final TextEditingController _dateController = TextEditingController();
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _dateController.text =
        "${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}";

    // Ensure user data is loaded when the screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      authProvider.checkLoginStatus();
    });
  }

  @override
  void dispose() {
    _dateController.dispose();
    super.dispose();
  }

  void _navigateToCategory(String category) {
    // Navigate to specific category tracking screen
    switch (category) {
      case 'food':
        Navigator.pushNamed(context, '/patient-food-tracking', arguments: {
          'date':
              "${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}",
        });
        break;
      case 'medication':
        Navigator.pushNamed(context, '/patient-medication-tracking',
            arguments: {
              'date':
                  "${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}",
            });
        break;
      case 'symptoms':
        Navigator.pushNamed(context, '/patient-symptoms-tracking', arguments: {
          'date':
              "${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}",
        });
        break;
      case 'sleep':
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        // Use the async method to get user info
        authProvider.getCurrentUserInfo().then((userInfo) {
          print('🔍 Daily Log Debug - User Info:');
          print('  Email: ${userInfo['email']}');
          print('  Username: ${userInfo['username']}');
          print('  UserId: ${userInfo['userId']}');
          print('  UserRole: ${userInfo['userRole']}');

          Navigator.pushNamed(context, '/patient-sleep-log', arguments: {
            'userId': userInfo['userId'] ?? 'unknown',
            'userRole': userInfo['userRole'] ?? 'patient',
            'username': userInfo['username'] ?? 'unknown',
            'email': userInfo['email'] ?? 'unknown',
          });
        });
        break;
      case 'mental_health':
        Navigator.pushNamed(context, '/mental-health', arguments: {
          'selectedDate':
              "${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}",
        });
        break;
      case 'kick_count':
        print('🔍 Kick Count button clicked!');
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        // Use the async method to get user info
        authProvider.getCurrentUserInfo().then((userInfo) {
          print('🔍 Daily Log Debug - User Info:');
          print('  Email: ${userInfo['email']}');
          print('  Username: ${userInfo['username']}');
          print('  UserId: ${userInfo['userId']}');
          print('  UserRole: ${userInfo['userRole']}');

          print('🔍 Navigating to Kick Counter...');
          Navigator.pushNamed(context, '/patient-kick-counter', arguments: {
            'userId': userInfo['userId'] ?? 'unknown',
            'userRole': userInfo['userRole'] ?? 'patient',
            'username': userInfo['username'] ?? 'unknown',
            'email': userInfo['email'] ?? 'unknown',
          }).then((result) {
            print('🔍 Navigation result: $result');
          }).catchError((error) {
            print('❌ Navigation error: $error');
          });
        }).catchError((error) {
          print('❌ Error getting user info: $error');
        });
        break;
      case 'activity':
        Navigator.pushNamed(context, '/activity-tracker');
        break;
      case 'hydration':
        Navigator.pushNamed(context, '/hydration-tracker');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header Section
            _buildHeader(context),

            // Main Content - Grid of Record Categories
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.0,
                  children: [
                    _buildRecordCard(
                      context,
                      title: 'Food & Nutrition',
                      icon: Icons.restaurant,
                      iconColor: Colors.green,
                      backgroundColor: Colors.green.withOpacity(0.1),
                      onTap: () => _navigateToCategory('food'),
                    ),
                    _buildRecordCard(
                      context,
                      title: 'Medication',
                      icon: Icons.medication,
                      iconColor: Colors.blue,
                      backgroundColor: Colors.blue.withOpacity(0.1),
                      onTap: () => _navigateToCategory('medication'),
                    ),
                    _buildRecordCard(
                      context,
                      title: 'Symptoms',
                      icon: Icons.sick,
                      iconColor: Colors.red,
                      backgroundColor: Colors.red.withOpacity(0.1),
                      onTap: () => _navigateToCategory('symptoms'),
                    ),
                    _buildRecordCard(
                      context,
                      title: 'Sleep',
                      icon: Icons.bedtime,
                      iconColor: Colors.purple,
                      backgroundColor: Colors.purple.withOpacity(0.1),
                      onTap: () => _navigateToCategory('sleep'),
                    ),
                    _buildRecordCard(
                      context,
                      title: 'Mental Health',
                      icon: Icons.psychology,
                      iconColor: Colors.orange,
                      backgroundColor: Colors.orange.withOpacity(0.1),
                      onTap: () => _navigateToCategory('mental_health'),
                    ),
                    _buildRecordCard(
                      context,
                      title: 'Kick Count',
                      icon: Icons.favorite,
                      iconColor: Colors.pink,
                      backgroundColor: Colors.pink.withOpacity(0.1),
                      onTap: () => _navigateToCategory('kick_count'),
                    ),
                    _buildRecordCard(
                      context,
                      title: 'Activity Tracker',
                      icon: Icons.directions_walk,
                      iconColor: Colors.green,
                      backgroundColor: Colors.green.withOpacity(0.1),
                      onTap: () => _navigateToCategory('activity'),
                    ),
                    _buildRecordCard(
                      context,
                      title: 'Hydration Tracker',
                      icon: Icons.local_drink,
                      iconColor: Colors.blue,
                      backgroundColor: Colors.blue.withOpacity(0.1),
                      onTap: () => _navigateToCategory('hydration'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          // Back Arrow and Title Row
          Row(
            children: [
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Icon(
                  Icons.arrow_back,
                  color: AppTheme.textGray,
                  size: 24,
                ),
              ),
              Expanded(
                child: Text(
                  'Daily Records',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textGray,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(width: 48), // Balance the back button
            ],
          ),
          const SizedBox(height: 8),
          // Date
          Text(
            _formatDate(_selectedDate),
            style: TextStyle(
              fontSize: 16,
              color: AppTheme.textGray.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildRecordCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color iconColor,
    required Color backgroundColor,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icon Circle
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: backgroundColor,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    size: 30,
                    color: iconColor,
                  ),
                ),
                const SizedBox(height: 12),
                // Title
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.textGray,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}

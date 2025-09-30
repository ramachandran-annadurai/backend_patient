import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../screens/patient_screens/dashboard_screen.dart';
import '../screens/patient_screens/patient_daily_log_screen.dart';
import '../screens/hydration_tracker_screen.dart';
import '../screens/activity_tracker_screen.dart';
import '../screens/medical_records_screen.dart';
import '../screens/upload_document_screen.dart';
import '../screens/messaging_list_screen.dart';
import '../screens/messaging_conversation_screen.dart';
import '../screens/appointment_history_screen.dart';
import '../screens/alerts_screen.dart';
import '../screens/appointment_overview_screen.dart';
import '../screens/new_appointment_screen.dart';
import '../screens/appointment_confirmation_screen.dart';
import '../screens/mental_health_new_screen.dart';
import '../screens/patient_screens/patient_sleep_log_screen.dart';
import '../screens/patient_screens/patient_kick_counter_screen.dart';
import '../screens/patient_screens/patient_symptoms_tracking_screen.dart';
import '../screens/patient_screens/patient_medication_tracking_screen.dart';
import '../screens/patient_screens/patient_food_tracking_screen.dart';
import '../screens/profile_settings_screen.dart';
import '../screens/appointment_details_screen.dart';
import '../screens/appointment_cancelled_screen.dart';
import '../screens/reschedule_appointment_screen.dart';
import '../screens/emergency_screen.dart';
import '../screens/ambulance_location_screen.dart';
import '../screens/privacy_settings_screen.dart';
import '../screens/notification_settings_screen.dart';
import '../screens/edit_profile_screen.dart';
import '../screens/app_information_screen.dart';
import '../screens/privacy_policy_screen.dart';

import '../providers/food_analysis_provider.dart';
import '../providers/save_food_entry_provider.dart';
import '../providers/sleep_log_provider.dart';
import '../providers/kick_counter_provider.dart';
import '../providers/symptom_analysis_provider.dart';
import '../providers/save_medication_log_provider.dart';
import '../providers/get_upcoming_dosages_provider.dart';

class MainTabScaffold extends StatefulWidget {
  final String email;
  const MainTabScaffold({required this.email, super.key});

  @override
  State<MainTabScaffold> createState() => _MainTabScaffoldState();
}

class _MainTabScaffoldState extends State<MainTabScaffold> {
  late CupertinoTabController _tabController;
  int _currentIndex = 0;
  late final VoidCallback _tabListener;

  final List<GlobalKey<NavigatorState>> _navigatorKeys = [
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = CupertinoTabController(initialIndex: 0);
    _tabListener = () {
      if (_currentIndex != _tabController.index) {
        setState(() => _currentIndex = _tabController.index);
      }
    };
    _tabController.addListener(_tabListener);
  }

  @override
  void dispose() {
    _tabController.removeListener(_tabListener);
    _tabController.dispose();
    super.dispose();
  }

  void _onTap(int index) {
    if (index == _currentIndex) {
      final navigator = _navigatorKeys[index].currentState!;
      if (navigator.canPop()) {
        navigator.popUntil((route) => route.isFirst);
      }
    } else {
      _tabController.index = index;
      setState(() => _currentIndex = index);
    }
  }

  Future<bool> _onWillPop() async {
    final int currentIndex = _tabController.index;
    final currentNavigator = _navigatorKeys[currentIndex].currentState!;

    // Allow back navigation inside a tab
    if (currentNavigator.canPop()) {
      currentNavigator.pop();
      return false;
    }

    // If not on Home, switch to it
    if (currentIndex != 0) {
      _tabController.index = 0;
      return false;
    }

    // Already on Home and cannot pop -> exit
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (didPop) return;
        _onWillPop();
      },
      child: CupertinoTabScaffold(
        controller: _tabController,
        tabBar: CupertinoTabBar(
          onTap: _onTap,
          currentIndex: _currentIndex,
          backgroundColor: Colors.white.withOpacity(0.95),
          activeColor: const Color(0xFF8B5CF6),
          inactiveColor: Colors.grey[400]!,
          iconSize: 24,
          items: [
            BottomNavigationBarItem(
              icon: Icon(
                _currentIndex == 0 ? Icons.home : Icons.home_outlined,
                size: 24.0,
              ),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(
                _currentIndex == 1
                    ? Icons.calendar_month
                    : Icons.calendar_month_outlined,
                size: 24.0,
              ),
              label: 'Appointments',
            ),
            BottomNavigationBarItem(
              icon: Icon(
                _currentIndex == 2 ? Icons.message : Icons.message_outlined,
                size: 24.0,
              ),
              label: 'Messages',
            ),
            BottomNavigationBarItem(
              icon: Icon(
                _currentIndex == 3 ? Icons.person : Icons.person_outline,
                size: 24.0,
              ),
              label: 'Profile',
            ),
          ],
        ),
        tabBuilder: (BuildContext context, int index) {
          return CupertinoTabView(
            navigatorKey: _navigatorKeys[index],
            builder: (context) => _buildTabContent(index),
            onGenerateRoute: (settings) {
              final args = settings.arguments as Map<String, dynamic>?;

              switch (settings.name) {
                case '/appointment-details':
                  return MaterialPageRoute(
                    builder: (_) => const AppointmentDetailsScreen(),
                  );
                case '/appointment-cancelled':
                  return MaterialPageRoute(
                    builder: (_) => const AppointmentCancelledScreen(),
                  );
                case '/reschedule-appointment':
                  return MaterialPageRoute(
                    builder: (_) => const RescheduleAppointmentScreen(),
                  );
                case '/emergency':
                  return MaterialPageRoute(
                    builder: (_) => const EmergencyScreen(),
                  );
                case '/ambulance-location':
                  return MaterialPageRoute(
                    builder: (_) => const AmbulanceLocationScreen(),
                  );
                case '/privacy-settings':
                  return MaterialPageRoute(
                    builder: (_) => const PrivacySettingsScreen(),
                  );
                case '/notification-settings':
                  return MaterialPageRoute(
                    builder: (_) => const NotificationSettingsScreen(),
                  );
                case '/new-appointment':
                  return MaterialPageRoute(
                    builder: (_) => const NewAppointmentScreen(),
                  );
                case '/patient-daily-log':
                  return MaterialPageRoute(
                    builder: (_) => const PatientDailyLogScreen(),
                  );

                case '/hydration-tracker':
                  return MaterialPageRoute(
                    builder: (_) => const HydrationTrackerScreen(),
                  );

                case '/activity-tracker':
                  return MaterialPageRoute(
                    builder: (_) => const ActivityTrackerScreen(),
                  );

                case '/medical-records':
                  return MaterialPageRoute(
                    builder: (_) => const MedicalRecordsScreen(),
                  );

                case '/upload-document':
                  return MaterialPageRoute(
                    builder: (_) => const UploadDocumentScreen(),
                  );

                case '/messaging-list':
                  return MaterialPageRoute(
                    builder: (_) => const MessagingListScreen(),
                  );

                case '/messaging-chat':
                  return MaterialPageRoute(
                    builder: (_) => const MessagingConversationScreen(),
                  );

                case '/alerts':
                  return MaterialPageRoute(
                    builder: (_) => const AlertsScreen(),
                  );

                case '/appointments-overview':
                  return MaterialPageRoute(
                    builder: (_) => const AppointmentOverviewScreen(),
                  );

                case '/appointment-confirmation':
                  return MaterialPageRoute(
                    builder: (_) => const AppointmentConfirmationScreen(),
                  );
                case '/app-information':
                  return MaterialPageRoute(
                    builder: (_) => const AppInformationScreen(),
                  );
                case '/privacy-policy':
                  return MaterialPageRoute(
                    builder: (_) => const PrivacyPolicyScreen(),
                  );
                case '/edit-profile':
                  return MaterialPageRoute(
                    builder: (_) => const EditProfileScreen(),
                  );

                case '/patient-food-tracking':
                  return MaterialPageRoute(
                    builder: (_) => MultiProvider(
                      providers: [
                        ChangeNotifierProvider(
                            create: (_) => FoodAnalysisProvider()),
                        ChangeNotifierProvider(
                            create: (_) => SaveFoodEntryProvider()),
                      ],
                      child: PatientFoodTrackingScreen(date: args?['date']),
                    ),
                  );

                case '/mental-health':
                  return MaterialPageRoute(
                    builder: (_) => MentalHealthNewScreen(),
                  );

                case '/patient-sleep-log':
                  return MaterialPageRoute(
                    builder: (_) => ChangeNotifierProvider(
                      create: (_) => SleepLogProvider(),
                      child: PatientSleepLogScreen(
                        userId: args?['userId'],
                        userRole: args?['userRole'],
                        username: args?['username'],
                        email: args?['email'],
                      ),
                    ),
                  );

                case '/patient-kick-counter':
                  return MaterialPageRoute(
                    builder: (_) => ChangeNotifierProvider(
                      create: (_) => KickCounterProvider()
                        ..loadHistory(args?['userId'] as String),
                      child: PatientKickCounterScreen(
                        userId: args?['userId'],
                        userRole: args?['userRole'],
                        username: args?['username'],
                        email: args?['email'],
                      ),
                    ),
                  );

                case '/patient-symptoms-tracking':
                  return MaterialPageRoute(
                    builder: (_) => ChangeNotifierProvider(
                      create: (_) => SymptomAnalysisProvider(),
                      child:
                          PatientSymptomsTrackingScreen(date: args?['date']),
                    ),
                  );

                case '/patient-medication-tracking':
                  return MaterialPageRoute(
                    builder: (_) => MultiProvider(
                      providers: [
                        ChangeNotifierProvider(
                            create: (_) => SaveMedicationLogProvider()),
                        ChangeNotifierProvider(
                            create: (_) => GetUpcomingDosagesProvider()),
                      ],
                      child: PatientMedicationTrackingScreen(date: args?['date']),
                    ),
                  );

                default:
                  return MaterialPageRoute(
                    builder: (_) => _buildTabContent(index),
                  );
              }
            },
          );
        },
      ),
    );
  }

  Widget _buildTabContent(int index) {
    switch (index) {
      case 0:
        return const DashboardScreen();
      case 1:
        return const AppointmentHistoryScreen();
      case 2:
        return const MessagingListScreen();
      case 3:
        return const ProfileSettingsScreen();
      default:
        return const DashboardScreen();
    }
  }
}

import 'package:flutter/material.dart';
import 'package:patient_alert_app/screens/mental_health_new_screen.dart';
import 'package:provider/provider.dart';

import 'screens/role_selection_screen.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/account_created_screen.dart';
import 'screens/password_reset_successful_screen.dart';
import 'screens/home_screen.dart';
import 'screens/patient_screens/patient_profile_screen.dart';
import 'screens/medication_dosage_list_screen.dart';
import 'screens/patient_screens/patient_daily_tracking_details_screen.dart';
import 'screens/forgot_password_screen.dart';
import 'providers/forgot_password_provider.dart';
import 'providers/reset_password_provider.dart';
import 'providers/login_provider.dart';
import 'screens/otp_verification_screen.dart';
import 'screens/reset_password_screen.dart';
import 'screens/patient_screens/profile_completion_screen.dart';
import 'screens/doctor_screens/doctor_dashboard_screen.dart';
import 'screens/doctor_screens/doctor_profile_screen.dart';
import 'screens/doctor_screens/doctor_profile_completion_screen.dart';
import 'screens/doctor_screens/doctor_forgot_password_screen.dart';
import 'screens/doctor_screens/doctor_reset_password_screen.dart';
import 'screens/doctor_screens/doctor_daily_log_screen.dart';
import 'screens/doctor_screens/doctor_food_tracking_screen.dart';
import 'screens/patient_screens/detailed_food_entry_screen.dart';
import 'screens/patient_screens/patient_daily_log_screen.dart';
import 'screens/patient_screens/dashboard_screen.dart';
import 'screens/main_tab_scaffold.dart';
import 'screens/hydration_tracker_screen.dart';
import 'screens/activity_tracker_screen.dart';
import 'providers/detailed_food_entry_provider.dart';
import 'providers/profile_provider.dart';
import 'providers/get_upcoming_dosages_provider.dart';

class AppRouter {
  static const String initialRoute = '/role-selection';

  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/role-selection':
        return MaterialPageRoute(builder: (_) => const RoleSelectionScreen());
      case '/login':
        final role = settings.arguments as String?;
        return MaterialPageRoute(
          builder: (_) => ChangeNotifierProvider(
            create: (_) => LoginProvider(),
            child: LoginScreen(role: role ?? 'patient'),
          ),
        );
      case '/signup':
        final role = settings.arguments as String?;
        return MaterialPageRoute(
            builder: (_) => SignupScreen(role: role ?? 'patient'));
      case '/account-created':
        return MaterialPageRoute(builder: (_) => const AccountCreatedScreen());
      case '/password-reset-successful':
        return MaterialPageRoute(
            builder: (_) => const PasswordResetSuccessfulScreen());
      case '/home':
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      case '/main-tabs':
        final email = settings.arguments as String? ?? 'user@example.com';
        return MaterialPageRoute(builder: (_) => MainTabScaffold(email: email));
      case '/patient-profile':
        return MaterialPageRoute(
          builder: (context) => ChangeNotifierProvider(
            create: (_) => ProfileProvider()..loadProfileFromContext(context),
            child: const PatientProfileScreen(),
          ),
        );
      case '/forgot-password':
        return MaterialPageRoute(
          builder: (_) => ChangeNotifierProvider(
            create: (_) => ForgotPasswordProvider(),
            child: const ForgotPasswordScreen(),
          ),
        );
      case '/otp-verification':
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
            builder: (_) => OtpVerificationScreen(
                email: args['email'], role: args['role'] ?? 'patient'));
      case '/reset-password':
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => ChangeNotifierProvider(
            create: (_) => ResetPasswordProvider(),
            child: ResetPasswordScreen(email: args['email']),
          ),
        );
      case '/profile-completion':
        return MaterialPageRoute(
          builder: (context) => ChangeNotifierProvider(
            create: (_) => ProfileProvider(),
            child: const ProfileCompletionScreen(),
          ),
        );
      case '/doctor-dashboard':
        return MaterialPageRoute(builder: (_) => const DoctorDashboardScreen());
      case '/doctor-profile':
        return MaterialPageRoute(builder: (_) => const DoctorProfileScreen());
      case '/doctor-profile-completion':
        return MaterialPageRoute(
            builder: (_) => const DoctorProfileCompletionScreen());
      case '/doctor-forgot-password':
        return MaterialPageRoute(
            builder: (_) => const DoctorForgotPasswordScreen());
      case '/doctor-reset-password':
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
            builder: (_) => DoctorResetPasswordScreen(email: args['email']));
      case '/doctor-daily-log':
        return MaterialPageRoute(builder: (_) => const DoctorDailyLogScreen());
      case '/doctor-food-tracking':
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
            builder: (_) => DoctorFoodTrackingScreen(
                patientId: args['patientId'], date: args['date']));
      case '/detailed-food-entry':
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => ChangeNotifierProvider(
            create: (_) => DetailedFoodEntryProvider()
              ..fetchPregnancyWeek(args['userId'] as String),
            child: DetailedFoodEntryScreen(
              userId: args['userId'] as String,
              username: args['username'] as String,
              email: args['email'] as String,
              pregnancyWeek: (args['pregnancyWeek'] as int?) ?? 1,
              onFoodSaved:
                  args['onFoodSaved'] as Function(Map<String, dynamic>),
            ),
          ),
        );
    }
    return null;
  }
}

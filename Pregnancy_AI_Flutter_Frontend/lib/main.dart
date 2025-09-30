import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/auth_provider_factory.dart';
import 'utils/constants.dart';
import 'app_router.dart';
import 'config/app_config.dart';

void main() {
  // Initialize environment before running the app
  AppConfig.setEnvironment(Environment.dev); // or Environment.prod
  runApp(const PatientAlertApp());
}

class PatientAlertApp extends StatelessWidget {
  const PatientAlertApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Main auth provider (manages shared state)
        ChangeNotifierProvider(create: (_) => AuthProvider()),

        // Auth factory (provides access to patient and doctor auth providers)
        ChangeNotifierProxyProvider<AuthProvider, AuthProviderFactory>(
          create: (context) => AuthProviderFactory(
              Provider.of<AuthProvider>(context, listen: false)),
          update: (context, authProvider, previous) =>
              previous ?? AuthProviderFactory(authProvider),
        ),
      ],
      child: MaterialApp(
        title: 'Mom Care - Pregnancy Tracker',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          primaryColor: AppColors.primary,
          scaffoldBackgroundColor: AppColors.background,
          appBarTheme: const AppBarTheme(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            elevation: 0,
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
        initialRoute: AppRouter.initialRoute,
        onGenerateRoute: AppRouter.onGenerateRoute,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

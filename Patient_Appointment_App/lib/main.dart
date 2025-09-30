import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'controllers/appointment_controller.dart';
import 'views/screens/appointment_list_screen.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppointmentController()),
      ],
      child: MaterialApp(
        title: 'Patient Appointment App',
        theme: AppTheme.lightTheme,
        home: const AppointmentListScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

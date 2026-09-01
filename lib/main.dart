import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_theme.dart';
import 'providers/appointment_provider.dart';
import 'providers/auth_provider.dart';
import 'repositories/mock_appointment_repository.dart';
import 'screens/splash_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AppointmentProvider(MockAppointmentRepository()),
        ),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: const DMTApp(),
    ),
  );
}

class DMTApp extends StatelessWidget {
  const DMTApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DMT Mobile',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.system,
      theme: AppTheme.lightTheme,
      home: const SplashScreen(),
    );
  }
}

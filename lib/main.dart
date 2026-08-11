import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/constants/app_color.dart';
import 'providers/appointment_provider.dart';
import 'repositories/mock_appointment_repository.dart';
import 'screens/splash_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AppointmentProvider(MockAppointmentRepository()),
        ),
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
      theme: ThemeData(
        primaryColor: AppColors.primaryMaroon,
        scaffoldBackgroundColor: AppColors.lightBackground,
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}

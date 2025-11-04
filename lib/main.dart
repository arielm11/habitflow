import 'package:flutter/material.dart';
import 'package:habitflow/screens/navigation_screen.dart';
import 'package:habitflow/screens/onboarding_screen.dart';
import 'package:habitflow/utils/app_colors.dart';
import 'package:habitflow/data/providers/habito_provider.dart';
import 'package:provider/provider.dart';
import 'package:habitflow/services/notification_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final notificationService = NotificationService();
  await notificationService.init();
  await notificationService.requestPermissions();

  final prefs = await SharedPreferences.getInstance();
  final bool hasSeenOnboarding = prefs.getBool('hasSeenOnBoarding') ?? false;

  runApp(
    ChangeNotifierProvider(
      create: (context) => HabitoProvider(),
      child: HabitFlowApp(hasSeenOnboarding: hasSeenOnboarding),
    ),
  );
}

class HabitFlowApp extends StatelessWidget {
  final bool hasSeenOnboarding;

  const HabitFlowApp({super.key, required this.hasSeenOnboarding});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'HabitFlow',
      theme: ThemeData(
        primaryColor: AppColors.teal,
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.teal),
        fontFamily: 'Roboto',
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.teal,
          foregroundColor: Colors.white,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            textStyle:
                const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ),
        useMaterial3: true,
      ),
      home: hasSeenOnboarding
          ? const NavigationScreen()
          : const OnboardingScreen(),
    );
  }
}

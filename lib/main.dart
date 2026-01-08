// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meetzone/services/storage_service.dart';
import 'package:meetzone/views/business_setup_view.dart';
import 'package:meetzone/views/dashboard_view.dart';
import 'package:meetzone/views/login_view.dart';
import 'package:meetzone/views/onboarding_view.dart';
import 'package:meetzone/views/otp_view.dart';
import 'package:meetzone/views/profile_setup_view.dart';
import 'package:meetzone/views/signup_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await StorageService.init();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor:
          Colors.transparent, // Makes status bar blend with gradient
      statusBarIconBrightness:
          Brightness.dark, // Dark icons on light onboarding/signup
      statusBarBrightness: Brightness.light, // For iOS
    ),
  );

  // Get initial route from storage
  final initialRoute = await StorageService.getInitialRoute();

  runApp(ProviderScope(child: MyApp(initialRoute: initialRoute)));
}

class MyApp extends StatelessWidget {
  final String initialRoute;

  const MyApp({super.key, required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MeetZone',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Inter', // matches your theme.dart
        scaffoldBackgroundColor:
            Colors.transparent, // allows gradients to shine
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF8156FF),
          brightness: Brightness.light,
        ),
      ),
      initialRoute: initialRoute,
      onGenerateRoute: (settings) {
        if (settings.name == '/otp') {
          final email = settings.arguments as String;
          return MaterialPageRoute(builder: (_) => OtpView(email: email));
        }
        return null;
      },
      routes: {
        '/': (_) => const OnboardingView(),
        '/login': (_) => const LoginView(),
        '/signup': (_) => const SignupView(),
        '/profile-setup': (_) => const ProfileSetupView(),
        '/business-setup': (_) => const BusinessSetupView(),
        '/dashboard': (_) => const DashboardView(),
      },
      builder: (context, child) {
        // Ensures status bar icons stay dark on all light-themed screens
        SystemChrome.setSystemUIOverlayStyle(
          const SystemUiOverlayStyle(
            statusBarIconBrightness: Brightness.dark,
            statusBarBrightness: Brightness.light,
          ),
        );
        return child!;
      },
    );
  }
}



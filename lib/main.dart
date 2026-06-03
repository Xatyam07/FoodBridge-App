import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';
import 'package:firebase_core/firebase_core.dart';

// ✅ Make sure this file exists: lib/firebase_options.dart
import 'firebase_options.dart';

import '../core/app_export.dart';
import '../widgets/custom_error_widget.dart';
import '../presentation/login_screen/login_screen.dart';
import '../presentation/user_registration/user_registration.dart';
import '../presentation/provider_dashboard/provider_dashboard.dart';
import '../presentation/ngo_dashboard/ngo_dashboard.dart';
import '../presentation/login_screen/setting_page/volunteer_dashboard/volunteer_dashboard.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ VERY IMPORTANT: initialize firebase with generated flutterfire config
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // ✅ Lock orientation + enable transparent status bar
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  // ✅ Clean custom error widget handler
  bool hasShownError = false;
  ErrorWidget.builder = (FlutterErrorDetails details) {
    if (!hasShownError) {
      hasShownError = true;
      Future.delayed(const Duration(seconds: 5), () {
        hasShownError = false;
      });
      return CustomErrorWidget(errorDetails: details);
    }
    return const SizedBox.shrink();
  };

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Sizer(
      builder: (context, orientation, screenType) {
        return MaterialApp(
          title: 'FoodBridge',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,

          // ✅ start at login screen
          initialRoute: '/login-screen',

          routes: {
            '/login-screen': (context) => const LoginScreen(),
            '/user-registration': (context) => const UserRegistration(),
            '/provider-dashboard': (context) => const ProviderDashboard(),
            '/ngo-dashboard': (context) => const NgoDashboard(),
            '/volunteer-dashboard': (context) => const VolunteerDashboard(),
            '/welcome': (context) => const WelcomeScreen(),
          },

          builder: (context, child) {
            return MediaQuery(
              data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
              child: child!,
            );
          },
        );
      },
    );
  }
}

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Welcome")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Account created successfully! 🎉",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/login-screen');
              },
              child: const Text("Go to Login"),
            ),
          ],
        ),
      ),
    );
  }
}

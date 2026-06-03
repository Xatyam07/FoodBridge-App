import 'package:flutter/material.dart';

// Import all your screens
import 'package:foodbridge/presentation/splash_screen/splash_screen.dart';
import 'package:foodbridge/presentation/login_screen/login_screen.dart';
import 'package:foodbridge/presentation/user_registration/user_registration.dart';
import 'package:foodbridge/presentation/home_page/home_page.dart';
import 'package:foodbridge/presentation/profile_page/profile_page.dart';
import 'package:foodbridge/presentation/notification_page/notification_page.dart';
import 'package:foodbridge/presentation/login_screen/setting_page/setting_page.dart';
import 'package:foodbridge/presentation/analytics_dashboard/analytics_dashboard.dart';
import 'package:foodbridge/presentation/donation_history/donation_history.dart';
import 'package:foodbridge/presentation/food_upload_screen/food_upload_screen.dart';
import 'package:foodbridge/presentation/provider_dashboard/provider_dashboard.dart';
import 'package:foodbridge/presentation/ngo_alert_management/ngo_alert_management.dart';
import 'package:foodbridge/presentation/volunteer_route_navigation/volunteer_route_navigation.dart';

class AppRoutes {
  // ✅ Start with splash screen first
  static const String initial = '/splash';

  static final routes = <String, WidgetBuilder>{
    '/splash': (context) => const SplashScreen(),
    '/login': (context) => const LoginScreen(),
    '/user-registration': (context) => const UserRegistration(),
    '/home': (context) => const HomePage(),
    '/profile': (context) => const ProfilePage(),
    '/notifications': (context) => const NotificationPage(),
    '/settings': (context) => const SettingPage(),
    '/analytics': (context) => const AnalyticsDashboard(),
    '/donations': (context) => const DonationHistory(),
    '/upload-food': (context) => const FoodUploadScreen(),
    '/provider-dashboard': (context) => const ProviderDashboard(),
    '/ngo-alert-management': (context) => const NgoAlertManagement(),
    '/volunteer-route-navigation': (context) => const VolunteerRouteNavigation(),
  };
}

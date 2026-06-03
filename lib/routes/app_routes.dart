import 'package:flutter/material.dart';
import '../presentation/provider_dashboard/provider_dashboard.dart';
import '../presentation/volunteer_route_navigation/volunteer_route_navigation.dart';
import '../presentation/login_screen/login_screen.dart';
import '../presentation/food_upload_screen/food_upload_screen.dart';
import '../presentation/user_registration/user_registration.dart';
import '../presentation/ngo_alert_management/ngo_alert_management.dart';

class AppRoutes {
  // TODO: Add your routes here
  static const String initial = '/';
  static const String providerDashboard = '/provider-dashboard';
  static const String volunteerRouteNavigation = '/volunteer-route-navigation';
  static const String login = '/login-screen';
  static const String foodUpload = '/food-upload-screen';
  static const String userRegistration = '/user-registration';
  static const String ngoAlertManagement = '/ngo-alert-management';

  static Map<String, WidgetBuilder> routes = {
    initial: (context) => const LoginScreen(),
    providerDashboard: (context) => const ProviderDashboard(),
    volunteerRouteNavigation: (context) => const VolunteerRouteNavigation(),
    login: (context) => const LoginScreen(),
    foodUpload: (context) => const FoodUploadScreen(),
    userRegistration: (context) => const UserRegistration(),
    ngoAlertManagement: (context) => const NgoAlertManagement(),
    // TODO: Add your other routes here
  };
}

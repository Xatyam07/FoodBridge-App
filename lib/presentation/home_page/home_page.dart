import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

// Import all the pages you want to navigate to
import '/presentation/analytics_dashboard/analytics_dashboard.dart';
import '/presentation/donation_history/donation_history.dart';
import '/presentation/food_upload_screen/food_upload_screen.dart';
import '/presentation/ngo_alert_management/ngo_alert_management.dart';
import '/presentation/notification_page/notification_page.dart';
import '/presentation/profile_page/profile_page.dart';
import '/presentation/login_screen/setting_page/setting_page.dart';
import '/presentation/volunteer_route_navigation/volunteer_route_navigation.dart';
import '/presentation/provider_dashboard/provider_dashboard.dart';


class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final items = [
      _HomeItem('Analytics Dashboard', Icons.bar_chart, const AnalyticsDashboard()),
      _HomeItem('Donation History', Icons.history, const DonationHistory()),
      _HomeItem('Food Upload', Icons.cloud_upload, const FoodUploadScreen()),
      _HomeItem('NGO Alert Management', Icons.campaign, const NgoAlertManagement()),
      _HomeItem('Notifications', Icons.notifications, const NotificationPage()),
      _HomeItem('Profile', Icons.person, const ProfilePage()),
      _HomeItem('Provider Dashboard', Icons.dashboard, const ProviderDashboard()),
      _HomeItem('Settings', Icons.settings, const SettingPage()),
      _HomeItem('Volunteer Route Navigation', Icons.map, const VolunteerRouteNavigation()),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('FoodBridge'),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.all(4.w),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            return _FeatureCard(item: item);
          },
        ),
      ),
    );
  }
}

class _HomeItem {
  final String title;
  final IconData icon;
  final Widget page;
  const _HomeItem(this.title, this.icon, this.page);
}

class _FeatureCard extends StatelessWidget {
  final _HomeItem item;
  const _FeatureCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => item.page),
        );
      },
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(item.icon, size: 40.sp, color: Theme.of(context).colorScheme.primary),
              SizedBox(height: 1.h),
              Text(
                item.title,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

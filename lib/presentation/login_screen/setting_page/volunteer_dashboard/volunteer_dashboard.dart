import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../../../theme/app_theme.dart';
import './widgets/dashboard_header_widget.dart';
import './widgets/metrics_card_widget.dart';
import './widgets/quick_action_button_widget.dart';


class VolunteerDashboard extends StatefulWidget {
  const VolunteerDashboard({super.key});

  @override
  State<VolunteerDashboard> createState() => _VolunteerDashboardState();
}

class _VolunteerDashboardState extends State<VolunteerDashboard>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();
  bool _isRefreshing = false;

  // Volunteer-specific metrics
  final List<Map<String, dynamic>> _metricsData = [
    {
      "title": "Active Deliveries",
      "value": "5",
      "subtitle": "2 pending pickup",
      "icon": Icons.local_shipping,
      "color": AppTheme.primaryLight,
    },
    {
      "title": "Hours Volunteered",
      "value": "24h",
      "subtitle": "This week",
      "icon": Icons.access_time,
      "color": AppTheme.secondaryLight,
    },
    {
      "title": "Meals Delivered",
      "value": "320",
      "subtitle": "This month",
      "icon": Icons.restaurant,
      "color": AppTheme.successLight,
    },
    {
      "title": "Impact Score",
      "value": "88%",
      "subtitle": "Community rating",
      "icon": Icons.star,
      "color": AppTheme.accentLight,
    },
  ];

  final List<Map<String, dynamic>> _activeTasks = [
    {
      "id": 1,
      "title": "Pickup from Green Valley Restaurant",
      "time": "Today, 5:00 PM",
      "location": "Downtown",
      "status": "Pending Pickup",
    },
    {
      "id": 2,
      "title": "Deliver to Local Shelter",
      "time": "Today, 6:30 PM",
      "location": "Westside Community Center",
      "status": "In Progress",
    },
    {
      "id": 3,
      "title": "Pickup from Fresh Market",
      "time": "Tomorrow, 9:00 AM",
      "location": "Central Market",
      "status": "Scheduled",
    },
  ];

  @override
  void initState() {
    super.initState();
    // Validate authentication state before dashboard access
    if (FirebaseAuth.instance.currentUser == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(context, '/login-screen');
      });
      return;
    }
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _handleRefresh() async {
    setState(() => _isRefreshing = true);
    await Future.delayed(const Duration(seconds: 2));
    setState(() => _isRefreshing = false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Column(
        children: [
          // Custom Header
          DashboardHeaderWidget(
            userName: "John Doe",
            onNotificationTap: _showNotifications,
            onProfileTap: _navigateToProfile,
          ),

          // Tab Bar
          Container(
            color: theme.colorScheme.surface,
            child: TabBar(
              controller: _tabController,
              labelColor: theme.colorScheme.primary,
              unselectedLabelColor:
              theme.colorScheme.onSurface.withValues(alpha: 0.6),
              indicatorColor: theme.colorScheme.primary,
              tabs: const [
                Tab(text: 'Dashboard'),
                Tab(text: 'Tasks'),
                Tab(text: 'Profile'),
              ],
            ),
          ),

          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildDashboardTab(),
                _buildTasksTab(),
                _buildProfileTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardTab() {
    final theme = Theme.of(context);

    return RefreshIndicator(
      onRefresh: _handleRefresh,
      child: SingleChildScrollView(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 2.h),

            // Metrics Section
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              child: Text(
                'Your Impact',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            SizedBox(height: 1.h),

            SizedBox(
              height: 22.h,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: 4.w),
                itemCount: _metricsData.length,
                itemBuilder: (context, index) {
                  final metric = _metricsData[index];
                  return Padding(
                    padding: EdgeInsets.only(right: 3.w),
                    child: MetricsCardWidget(
                      title: metric['title'],
                      value: metric['value'],
                      subtitle: metric['subtitle'],
                      icon: metric['icon'],
                      iconColor: metric['color'],
                      onTap: () {},
                    ),
                  );
                },
              ),
            ),

            SizedBox(height: 3.h),

            // Quick Actions
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  QuickActionButtonWidget(
                    title: 'Find Tasks',
                    icon: Icons.search,
                    onTap: () => _tabController.animateTo(1), label: '',
                  ),
                  QuickActionButtonWidget(
                    title: 'My Schedule',
                    icon: Icons.calendar_today,
                    onTap: _showSchedule, label: '',
                  ),
                  QuickActionButtonWidget(
                    title: 'Report Issue',
                    icon: Icons.report,
                    onTap: _reportIssue, label: '',
                  ),
                ],
              ),
            ),
            SizedBox(height: 5.h),
          ],
        ),
      ),
    );
  }

  Widget _buildTasksTab() {
    return RefreshIndicator(
      onRefresh: _handleRefresh,
      child: ListView.builder(
        padding: EdgeInsets.all(4.w),
        itemCount: _activeTasks.length,
        itemBuilder: (context, index) {
          final task = _activeTasks[index];
          return ActiveTaskCardWidget(
            task: task,
            onViewDetails: () => _showTaskDetails(task),
            onMarkComplete: () => _markTaskComplete(task),
          );
        },
      ),
    );
  }

  Widget _buildProfileTab() {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      padding: EdgeInsets.all(4.w),
      child: Column(
        children: [
          SizedBox(height: 5.h),
          Text(
            "Volunteer Profile Coming Soon...",
            style: theme.textTheme.bodyLarge,
          ),
          SizedBox(height: 5.h),
          Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(3.w),
              border: Border.all(
                color: theme.colorScheme.outline.withValues(alpha: 0.1),
              ),
            ),
            child: ListTile(
              leading: Icon(
                Icons.logout,
                color: theme.colorScheme.error,
                size: 24,
              ),
              title: Text(
                'Logout',
                style: TextStyle(
                  color: theme.colorScheme.error,
                  fontWeight: FontWeight.w600,
                ),
              ),
              onTap: () async {
                try {
                  await FirebaseAuth.instance.signOut();
                  await GoogleSignIn().signOut();
                } catch (e) {
                  debugPrint("Sign out error: $e");
                }
                if (context.mounted) {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/login-screen',
                    (route) => false,
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  // Action Methods
  void _navigateToProfile() => _tabController.animateTo(2);
  void _showNotifications() {}
  void _showSchedule() {}
  void _reportIssue() {}
  void _showTaskDetails(Map<String, dynamic> task) {
    Navigator.pushNamed(context, '/volunteer-route-navigation');
  }
  void _markTaskComplete(Map<String, dynamic> task) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Task "${task['title']}" marked as completed!'),
        backgroundColor: Colors.green,
      ),
    );
  }
}

class ActiveTaskCardWidget extends StatelessWidget {
  final Map<String, dynamic> task;
  final VoidCallback onViewDetails;
  final VoidCallback onMarkComplete;

  const ActiveTaskCardWidget({
    super.key,
    required this.task,
    required this.onViewDetails,
    required this.onMarkComplete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: EdgeInsets.only(bottom: 2.h),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    task['title'] ?? '',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 2.5.w, vertical: 0.5.h),
                  decoration: BoxDecoration(
                    color: _getStatusColor(task['status'], theme).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    task['status'] ?? '',
                    style: TextStyle(
                      color: _getStatusColor(task['status'], theme),
                      fontSize: 9.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 1.5.h),
            Row(
              children: [
                Icon(Icons.access_time_filled, size: 16, color: theme.colorScheme.primary),
                SizedBox(width: 2.w),
                Text(
                  task['time'] ?? '',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ],
            ),
            SizedBox(height: 0.8.h),
            Row(
              children: [
                Icon(Icons.location_on, size: 16, color: theme.colorScheme.secondary),
                SizedBox(width: 2.w),
                Text(
                  task['location'] ?? '',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ],
            ),
            SizedBox(height: 2.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton(
                  onPressed: onViewDetails,
                  child: const Text('View Route'),
                ),
                SizedBox(width: 3.w),
                ElevatedButton(
                  onPressed: onMarkComplete,
                  child: const Text('Complete'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String? status, ThemeData theme) {
    switch (status) {
      case 'In Progress':
        return theme.colorScheme.secondary;
      case 'Pending Pickup':
        return theme.colorScheme.primary;
      case 'Scheduled':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }
}

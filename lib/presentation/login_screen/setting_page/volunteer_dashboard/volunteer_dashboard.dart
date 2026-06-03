import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../../theme/app_theme.dart';
import '../../core/app_export.dart';
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
            providerName: "John Doe",
            businessType: "Volunteer",
            notificationCount: 2,
            onNotificationTap: _showNotifications,
            onProfileTap: _navigateToProfile, userName: '',
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
    return Center(
      child: Text("Volunteer Profile Coming Soon..."),
    );
  }

  // Action Methods
  void _navigateToProfile() => _tabController.animateTo(2);
  void _showNotifications() {}
  void _showSchedule() {}
  void _reportIssue() {}
  void _showTaskDetails(Map<String, dynamic> task) {}
  void _markTaskComplete(Map<String, dynamic> task) {}
}

ActiveTaskCardWidget({required Map<String, dynamic> task, required void Function() onViewDetails, required void Function() onMarkComplete}) {
}

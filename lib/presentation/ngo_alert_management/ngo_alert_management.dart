import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:sizer/sizer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../core/app_export.dart';
import '../../theme/app_theme.dart';
import '../../widgets/custom_icon_widget.dart';
import '../../widgets/custom_image_widget.dart';
import './widgets/alert_card_widget.dart';
import './widgets/donation_acceptance_bottom_sheet.dart';
import './widgets/filter_chips_widget.dart';
import './widgets/urgent_alerts_banner_widget.dart';

class NgoAlertManagement extends StatefulWidget {
  const NgoAlertManagement({super.key});

  @override
  State<NgoAlertManagement> createState() => _NgoAlertManagementState();
}

class _NgoAlertManagementState extends State<NgoAlertManagement>
    with TickerProviderStateMixin {
  late TabController _tabController;
  bool _isMapView = false;
  bool _isRefreshing = false;
  List<String> _selectedFilters = ['Distance'];
  
  final List<Map<String, dynamic>> _mockAlerts = [
{ 'id': '1',
'providerName': 'Sunset Bistro',
'providerPhoto': 'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=400',
'foodType': 'Prepared Meals',
'quantity': 25,
'location': '123 Main St, Downtown',
'distance': 1.2,
'expirationHours': 2,
'freshnessScore': 0.85,
'urgency': 'Urgent',
'timestamp': DateTime.now().subtract(const Duration(minutes: 15)),
},
{ 'id': '2',
'providerName': 'Fresh Market Co.',
'providerPhoto': 'https://images.unsplash.com/photo-1556909114-f6e7ad7d3136?w=400',
'foodType': 'Fresh Produce',
'quantity': 50,
'location': '456 Oak Ave, Midtown',
'distance': 2.8,
'expirationHours': 6,
'freshnessScore': 0.92,
'urgency': 'High',
'timestamp': DateTime.now().subtract(const Duration(minutes: 45)),
},
{ 'id': '3',
'providerName': 'Corner Bakery',
'providerPhoto': 'https://images.unsplash.com/photo-1509440159596-0249088772ff?w=400',
'foodType': 'Bakery Items',
'quantity': 15,
'location': '789 Pine St, Uptown',
'distance': 0.9,
'expirationHours': 4,
'freshnessScore': 0.78,
'urgency': 'Medium',
'timestamp': DateTime.now().subtract(const Duration(hours: 1)),
},
{ 'id': '4',
'providerName': 'Green Grocers',
'providerPhoto': 'https://images.unsplash.com/photo-1542838132-92c53300491e?w=400',
'foodType': 'Dairy Products',
'quantity': 30,
'location': '321 Elm Dr, Westside',
'distance': 3.5,
'expirationHours': 8,
'freshnessScore': 0.88,
'urgency': 'Low',
'timestamp': DateTime.now().subtract(const Duration(hours: 2)),
},
{ 'id': '5',
'providerName': 'Metro Deli',
'providerPhoto': 'https://images.unsplash.com/photo-1555396273-367ea4eb4db5?w=400',
'foodType': 'Packaged Goods',
'quantity': 40,
'location': '654 Maple Ln, Eastside',
'distance': 4.2,
'expirationHours': 12,
'freshnessScore': 0.95,
'urgency': 'Low',
'timestamp': DateTime.now().subtract(const Duration(hours: 3)),
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
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final urgentCount = _mockAlerts.where((alert) => 
      (alert['urgency'] as String).toLowerCase() == 'urgent').length;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: _buildAppBar(context),
      body: Column(
        children: [
          _buildTabBar(context),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildAlertsTab(context, urgentCount),
                _buildActiveTab(context),
                _buildHistoryTab(context),
                _buildProfileTab(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    final theme = Theme.of(context);
    return AppBar(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'NGO Dashboard',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            'Food Bridge Network',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          onPressed: () => setState(() => _isMapView = !_isMapView),
          icon: CustomIconWidget(
            iconName: _isMapView ? 'list' : 'map',
            color: theme.colorScheme.onSurface,
            size: 24,
          ),
          tooltip: _isMapView ? 'List View' : 'Map View',
        ),
        IconButton(
          onPressed: _showNotificationSettings,
          icon: CustomIconWidget(
            iconName: 'settings',
            color: theme.colorScheme.onSurface,
            size: 24,
          ),
          tooltip: 'Notification Settings',
        ),
        Stack(
          children: [
            IconButton(
              onPressed: _showNotifications,
              icon: CustomIconWidget(
                iconName: 'notifications',
                color: theme.colorScheme.onSurface,
                size: 24,
              ),
              tooltip: 'Notifications',
            ),
            Positioned(
              right: 8,
              top: 8,
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: theme.colorScheme.error,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTabBar(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: theme.colorScheme.outline.withValues(alpha: 0.2),
          ),
        ),
      ),
      child: TabBar(
        controller: _tabController,
        labelColor: theme.colorScheme.primary,
        unselectedLabelColor: theme.colorScheme.onSurface.withValues(alpha: 0.6),
        indicatorColor: theme.colorScheme.primary,
        indicatorWeight: 3,
        labelStyle: theme.textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: theme.textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w400,
        ),
        tabs: const [
          Tab(text: 'Alerts'),
          Tab(text: 'Active'),
          Tab(text: 'History'),
          Tab(text: 'Profile'),
        ],
      ),
    );
  }

  Widget _buildAlertsTab(BuildContext context, int urgentCount) {
    if (_isMapView) {
      return _buildMapView(context);
    }

    return RefreshIndicator(
      onRefresh: _handleRefresh,
      child: Column(
        children: [
          UrgentAlertsBannerWidget(
            urgentCount: urgentCount,
            onViewAll: () => _filterByUrgent(),
          ),
          FilterChipsWidget(
            selectedFilters: _selectedFilters,
            onFiltersChanged: (filters) {
              setState(() => _selectedFilters = filters);
            },
          ),
          SizedBox(height: 1.h),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.only(bottom: 2.h),
              itemCount: _mockAlerts.length,
              itemBuilder: (context, index) {
                final alert = _mockAlerts[index];
                return Slidable(
                  key: ValueKey(alert['id']),
                  endActionPane: ActionPane(
                    motion: const ScrollMotion(),
                    children: [
                      SlidableAction(
                        onPressed: (context) => _contactProvider(alert),
                        backgroundColor: Theme.of(context).colorScheme.tertiary,
                        foregroundColor: Theme.of(context).colorScheme.onTertiary,
                        icon: Icons.phone,
                        label: 'Contact',
                      ),
                      SlidableAction(
                        onPressed: (context) => _assignVolunteer(alert),
                        backgroundColor: Theme.of(context).colorScheme.secondary,
                        foregroundColor: Theme.of(context).colorScheme.onSecondary,
                        icon: Icons.person_add,
                        label: 'Assign',
                      ),
                      SlidableAction(
                        onPressed: (context) => _addToRoute(alert),
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Theme.of(context).colorScheme.onPrimary,
                        icon: Icons.route,
                        label: 'Route',
                      ),
                    ],
                  ),
                  child: GestureDetector(
                    onLongPress: () => _showContextMenu(context, alert),
                    child: AlertCardWidget(
                      alertData: alert,
                      onAcceptDonation: () => _acceptDonation(alert),
                      onViewDetails: () => _viewDetails(alert),
                      onContactProvider: () => _contactProvider(alert),
                      onAssignVolunteer: () => _assignVolunteer(alert),
                      onAddToRoute: () => _addToRoute(alert),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveTab(BuildContext context) {
    final theme = Theme.of(context);
    final activeAlerts = _mockAlerts.where((alert) => 
      (alert['urgency'] as String).toLowerCase() != 'low').toList();

    return ListView.builder(
      padding: EdgeInsets.all(4.w),
      itemCount: activeAlerts.length,
      itemBuilder: (context, index) {
        final alert = activeAlerts[index];
        return Card(
          margin: EdgeInsets.only(bottom: 2.h),
          child: ListTile(
            leading: Container(
              width: 10.w,
              height: 10.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: theme.colorScheme.outline.withValues(alpha: 0.2),
                ),
              ),
              child: ClipOval(
                child: CustomImageWidget(
                  imageUrl: alert['providerPhoto'] as String,
                  width: 10.w,
                  height: 10.w,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            title: Text(
              alert['providerName'] as String,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: Text(
              '${alert['quantity']} ${alert['foodType']} • ${alert['distance']} km',
              style: theme.textTheme.bodySmall,
            ),
            trailing: Container(
              padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
              decoration: BoxDecoration(
                color: theme.colorScheme.secondary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'In Progress',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.secondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHistoryTab(BuildContext context) {
    final theme = Theme.of(context);
    return ListView.builder(
      padding: EdgeInsets.all(4.w),
      itemCount: 10,
      itemBuilder: (context, index) {
        return Card(
          margin: EdgeInsets.only(bottom: 2.h),
          child: ListTile(
            leading: CustomIconWidget(
              iconName: 'check_circle',
              color: AppTheme.successLight,
              size: 24,
            ),
            title: Text(
              'Donation #${1000 + index}',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: Text(
              'Completed ${index + 1} days ago',
              style: theme.textTheme.bodySmall,
            ),
            trailing: Text(
              '${(index + 1) * 15} meals',
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildProfileTab(BuildContext context) {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      padding: EdgeInsets.all(4.w),
      child: Column(
        children: [
          Container(
            width: 20.w,
            height: 20.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: theme.colorScheme.outline.withValues(alpha: 0.2),
              ),
            ),
            child: ClipOval(
              child: CustomImageWidget(
                imageUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400',
                width: 20.w,
                height: 20.w,
                fit: BoxFit.cover,
              ),
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            'Hope Foundation',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 0.5.h),
          Text(
            'NGO Coordinator',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          SizedBox(height: 4.h),
          _buildProfileStats(context),
          SizedBox(height: 4.h),
          _buildProfileActions(context),
        ],
      ),
    );
  }

  Widget _buildProfileStats(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(context, '156', 'Donations\nReceived'),
        ),
        SizedBox(width: 4.w),
        Expanded(
          child: _buildStatCard(context, '2,340', 'Meals\nDistributed'),
        ),
        SizedBox(width: 4.w),
        Expanded(
          child: _buildStatCard(context, '45', 'Active\nVolunteers'),
        ),
      ],
    );
  }

  Widget _buildStatCard(BuildContext context, String value, String label) {
    final theme = Theme.of(context);
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: theme.textTheme.headlineMedium?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildProfileActions(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        ListTile(
          leading: CustomIconWidget(
            iconName: 'edit',
            color: theme.colorScheme.primary,
            size: 24,
          ),
          title: const Text('Edit Profile'),
          trailing: CustomIconWidget(
            iconName: 'arrow_forward_ios',
            color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
            size: 16,
          ),
          onTap: () {},
        ),
        ListTile(
          leading: CustomIconWidget(
            iconName: 'settings',
            color: theme.colorScheme.primary,
            size: 24,
          ),
          title: const Text('Settings'),
          trailing: CustomIconWidget(
            iconName: 'arrow_forward_ios',
            color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
            size: 16,
          ),
          onTap: () {},
        ),
        ListTile(
          leading: CustomIconWidget(
            iconName: 'help',
            color: theme.colorScheme.primary,
            size: 24,
          ),
          title: const Text('Help & Support'),
          trailing: CustomIconWidget(
            iconName: 'arrow_forward_ios',
            color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
            size: 16,
          ),
          onTap: () {},
        ),
        ListTile(
          leading: CustomIconWidget(
            iconName: 'logout',
            color: theme.colorScheme.error,
            size: 24,
          ),
          title: Text(
            'Logout',
            style: TextStyle(color: theme.colorScheme.error),
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
      ],
    );
  }

  Widget _buildMapView(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: theme.colorScheme.surface,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomIconWidget(
              iconName: 'map',
              color: theme.colorScheme.primary,
              size: 64,
            ),
            SizedBox(height: 2.h),
            Text(
              'Map View',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 1.h),
            Text(
              'Interactive map showing donation locations\nwith clustering for dense areas',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 3.h),
            ElevatedButton(
              onPressed: () => setState(() => _isMapView = false),
              child: const Text('Switch to List View'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleRefresh() async {
    setState(() => _isRefreshing = true);
    await Future.delayed(const Duration(seconds: 2));
    setState(() => _isRefreshing = false);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Alerts refreshed successfully'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _filterByUrgent() {
    setState(() {
      _selectedFilters = ['Expiration'];
    });
  }

  void _acceptDonation(Map<String, dynamic> alert) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DonationAcceptanceBottomSheet(
        donationData: alert,
        onConfirm: () {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Donation from ${alert['providerName']} accepted!'),
              backgroundColor: AppTheme.successLight,
            ),
          );
        },
        onCancel: () => Navigator.pop(context),
      ),
    );
  }

  void _viewDetails(Map<String, dynamic> alert) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Donation Details'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Provider: ${alert['providerName']}'),
            Text('Food Type: ${alert['foodType']}'),
            Text('Quantity: ${alert['quantity']} meals'),
            Text('Location: ${alert['location']}'),
            Text('Distance: ${alert['distance']} km'),
            Text('Expires in: ${alert['expirationHours']} hours'),
            Text('Freshness: ${((alert['freshnessScore'] as double) * 100).toInt()}%'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _contactProvider(Map<String, dynamic> alert) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Contacting ${alert['providerName']}...'),
      ),
    );
  }

  void _assignVolunteer(Map<String, dynamic> alert) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Assigning volunteer for ${alert['providerName']}...'),
      ),
    );
  }

  void _addToRoute(Map<String, dynamic> alert) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Added ${alert['providerName']} to route'),
        backgroundColor: AppTheme.successLight,
      ),
    );
  }

  void _showContextMenu(BuildContext context, Map<String, dynamic> alert) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: EdgeInsets.all(4.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: CustomIconWidget(
                iconName: 'bookmark',
                color: Theme.of(context).colorScheme.primary,
                size: 24,
              ),
              title: const Text('Save for Later'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Saved for later')),
                );
              },
            ),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'report',
                color: Theme.of(context).colorScheme.error,
                size: 24,
              ),
              title: const Text('Report Issue'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Issue reported')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showNotifications() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Notifications'),
        content: const Text('You have 3 new donation alerts'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showNotificationSettings() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Notification Settings'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SwitchListTile(
              title: const Text('Urgent Alerts'),
              value: true,
              onChanged: (value) {},
            ),
            SwitchListTile(
              title: const Text('New Donations'),
              value: true,
              onChanged: (value) {},
            ),
            SwitchListTile(
              title: const Text('Volunteer Updates'),
              value: false,
              onChanged: (value) {},
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
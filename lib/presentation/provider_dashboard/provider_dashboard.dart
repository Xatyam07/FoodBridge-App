import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/dashboard_header_widget.dart';
import './widgets/food_inventory_card_widget.dart';
import './widgets/metrics_card_widget.dart';
import './widgets/quick_action_button_widget.dart';

class ProviderDashboard extends StatefulWidget {
  const ProviderDashboard({super.key});

  @override
  State<ProviderDashboard> createState() => _ProviderDashboardState();
}

class _ProviderDashboardState extends State<ProviderDashboard>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();
  bool _isRefreshing = false;

  // Mock data for the dashboard
  final List<Map<String, dynamic>> _metricsData = [
    {
      "title": "Today's Surplus",
      "value": "45 kg",
      "subtitle": "+12% from yesterday",
      "icon": Icons.restaurant_menu,
      "color": AppTheme.primaryLight,
    },
    {
      "title": "Active Donations",
      "value": "8",
      "subtitle": "3 pending pickup",
      "icon": Icons.volunteer_activism,
      "color": AppTheme.secondaryLight,
    },
    {
      "title": "Waste Prevented",
      "value": "\$1,240",
      "subtitle": "This month",
      "icon": Icons.eco,
      "color": AppTheme.successLight,
    },
    {
      "title": "Impact Score",
      "value": "94%",
      "subtitle": "Blockchain verified",
      "icon": Icons.verified,
      "color": AppTheme.accentLight,
    },
    {
      "title": "CO2 Saved",
      "value": "128 kg",
      "subtitle": "Environmental impact",
      "icon": Icons.nature,
      "color": AppTheme.successLight,
    },
    {
      "title": "Meals Created",
      "value": "156",
      "subtitle": "From donations",
      "icon": Icons.dining,
      "color": AppTheme.warningLight,
    },
  ];

  final List<Map<String, dynamic>> _foodInventory = [
    {
      "id": 1,
      "name": "Fresh Vegetables Mix",
      "type": "Vegetables",
      "quantity": 25,
      "unit": "kg",
      "image":
          "https://images.pexels.com/photos/1435904/pexels-photo-1435904.jpeg?auto=compress&cs=tinysrgb&w=500",
      "freshnessScore": 92,
      "expirationHours": 18,
      "temperature": 4.2,
      "humidity": 85,
    },
    {
      "id": 2,
      "name": "Artisan Bread Loaves",
      "type": "Bakery",
      "quantity": 12,
      "unit": "pieces",
      "image":
          "https://images.pexels.com/photos/209206/pexels-photo-209206.jpeg?auto=compress&cs=tinysrgb&w=500",
      "freshnessScore": 78,
      "expirationHours": 8,
      "temperature": 22.1,
      "humidity": 65,
    },
    {
      "id": 3,
      "name": "Grilled Chicken Portions",
      "type": "Prepared Food",
      "quantity": 8,
      "unit": "portions",
      "image":
          "https://images.pexels.com/photos/616354/pexels-photo-616354.jpeg?auto=compress&cs=tinysrgb&w=500",
      "freshnessScore": 85,
      "expirationHours": 4,
      "temperature": 3.8,
      "humidity": 70,
    },
    {
      "id": 4,
      "name": "Fresh Fruit Salad",
      "type": "Fruits",
      "quantity": 15,
      "unit": "cups",
      "image":
          "https://images.pexels.com/photos/1092730/pexels-photo-1092730.jpeg?auto=compress&cs=tinysrgb&w=500",
      "freshnessScore": 88,
      "expirationHours": 12,
      "temperature": 5.1,
      "humidity": 80,
    },
    {
      "id": 5,
      "name": "Dairy Products Bundle",
      "type": "Dairy",
      "quantity": 20,
      "unit": "items",
      "image":
          "https://images.pexels.com/photos/416978/pexels-photo-416978.jpeg?auto=compress&cs=tinysrgb&w=500",
      "freshnessScore": 95,
      "expirationHours": 72,
      "temperature": 2.5,
      "humidity": 75,
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _handleRefresh() async {
    setState(() {
      _isRefreshing = true;
    });

    // Simulate API call for refreshing data
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _isRefreshing = false;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Dashboard data refreshed'),
          duration: Duration(seconds: 2),
        ),
      );
    }
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
            providerName: "Green Valley Restaurant",
            businessType: "Fine Dining Restaurant",
            notificationCount: 3,
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
                Tab(text: 'Inventory'),
                Tab(text: 'Analytics'),
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
                _buildInventoryTab(),
                _buildAnalyticsTab(),
                _buildProfileTab(),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _navigateToFoodUpload,
        icon: CustomIconWidget(
          iconName: 'add_a_photo',
          size: 5.w,
          color: theme.colorScheme.onSecondary,
        ),
        label: Text(
          'Add Food',
          style: theme.textTheme.labelLarge?.copyWith(
            color: theme.colorScheme.onSecondary,
          ),
        ),
        backgroundColor: theme.colorScheme.secondary,
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

            // Metrics Cards Section
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              child: Text(
                'Today\'s Overview',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            SizedBox(height: 1.h),

            SizedBox(
              height: 25.h,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: 4.w),
                itemCount: _metricsData.length,
                itemBuilder: (context, index) {
                  final metric = _metricsData[index];
                  return Padding(
                    padding: EdgeInsets.only(right: 3.w),
                    child: MetricsCardWidget(
                      title: metric['title'] as String,
                      value: metric['value'] as String,
                      subtitle: metric['subtitle'] as String,
                      icon: metric['icon'] as IconData,
                      iconColor: metric['color'] as Color,
                      onTap: () => _showMetricDetails(metric),
                    ),
                  );
                },
              ),
            ),

            SizedBox(height: 3.h),

            // Quick Actions Section
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              child: Text(
                'Quick Actions',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            SizedBox(height: 1.h),

            Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  QuickActionButtonWidget(
                    title: 'Add Surplus Food',
                    icon: Icons.add_a_photo,
                    onTap: _navigateToFoodUpload,
                  ),
                  QuickActionButtonWidget(
                    title: 'Active Donations',
                    icon: Icons.location_on,
                    onTap: _showActiveDonations,
                  ),
                  QuickActionButtonWidget(
                    title: 'IoT Sensors',
                    icon: Icons.sensors,
                    onTap: _showSensorStatus,
                  ),
                ],
              ),
            ),

            SizedBox(height: 3.h),

            // Recent Activity Section
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Recent Food Items',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  TextButton(
                    onPressed: () => _tabController.animateTo(1),
                    child: Text(
                      'View All',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Recent Food Items
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              itemCount: _foodInventory.take(3).length,
              itemBuilder: (context, index) {
                final foodItem = _foodInventory[index];
                return FoodInventoryCardWidget(
                  foodItem: foodItem,
                  onDonate: () => _donateFood(foodItem),
                  onUpdate: () => _updateFood(foodItem),
                  onMarkConsumed: () => _markConsumed(foodItem),
                  onTap: () => _showFoodDetails(foodItem),
                );
              },
            ),

            SizedBox(height: 10.h), // Space for FAB
          ],
        ),
      ),
    );
  }

  Widget _buildInventoryTab() {
    final theme = Theme.of(context);

    return Column(
      children: [
        // Search and Filter Bar
        Container(
          padding: EdgeInsets.all(4.w),
          color: theme.colorScheme.surface,
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search food items...',
                    prefixIcon: CustomIconWidget(
                      iconName: 'search',
                      size: 5.w,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(2.w),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: theme.colorScheme.surface,
                  ),
                ),
              ),
              SizedBox(width: 2.w),
              IconButton(
                onPressed: _showFilterOptions,
                icon: CustomIconWidget(
                  iconName: 'filter_list',
                  size: 6.w,
                  color: theme.colorScheme.primary,
                ),
                style: IconButton.styleFrom(
                  backgroundColor:
                      theme.colorScheme.primary.withValues(alpha: 0.1),
                ),
              ),
            ],
          ),
        ),

        // Inventory List
        Expanded(
          child: RefreshIndicator(
            onRefresh: _handleRefresh,
            child: ListView.builder(
              padding: EdgeInsets.all(4.w),
              itemCount: _foodInventory.length,
              itemBuilder: (context, index) {
                final foodItem = _foodInventory[index];
                return FoodInventoryCardWidget(
                  foodItem: foodItem,
                  onDonate: () => _donateFood(foodItem),
                  onUpdate: () => _updateFood(foodItem),
                  onMarkConsumed: () => _markConsumed(foodItem),
                  onTap: () => _showFoodDetails(foodItem),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAnalyticsTab() {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: EdgeInsets.all(4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Analytics Dashboard',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 2.h),

          // Analytics cards would go here
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(6.w),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(3.w),
              border: Border.all(
                color: theme.colorScheme.outline.withValues(alpha: 0.1),
              ),
            ),
            child: Column(
              children: [
                CustomIconWidget(
                  iconName: 'analytics',
                  size: 15.w,
                  color: theme.colorScheme.primary.withValues(alpha: 0.5),
                ),
                SizedBox(height: 2.h),
                Text(
                  'Analytics Coming Soon',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 1.h),
                Text(
                  'Detailed analytics and reporting features will be available in the next update.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileTab() {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: EdgeInsets.all(4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Profile Settings',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 2.h),

          // Profile options would go here
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(6.w),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(3.w),
              border: Border.all(
                color: theme.colorScheme.outline.withValues(alpha: 0.1),
              ),
            ),
            child: Column(
              children: [
                CustomIconWidget(
                  iconName: 'person',
                  size: 15.w,
                  color: theme.colorScheme.primary.withValues(alpha: 0.5),
                ),
                SizedBox(height: 2.h),
                Text(
                  'Profile Management',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 1.h),
                Text(
                  'Profile management features will be available in the next update.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Action Methods
  void _navigateToFoodUpload() {
    Navigator.pushNamed(context, '/food-upload-screen');
  }

  void _navigateToProfile() {
    _tabController.animateTo(3);
  }

  void _showNotifications() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildNotificationBottomSheet(),
    );
  }

  void _showMetricDetails(Map<String, dynamic> metric) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(metric['title'] as String),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Current Value: ${metric['value']}'),
            SizedBox(height: 1.h),
            Text('Trend: ${metric['subtitle']}'),
            SizedBox(height: 1.h),
            Text(
                'This metric shows your current performance in food waste management.'),
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

  void _showActiveDonations() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Showing active donations...'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _showSensorStatus() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('IoT Sensor Status'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildSensorStatusItem('Temperature Sensor', true, '4.2°C'),
            _buildSensorStatusItem('Humidity Sensor', true, '75%'),
            _buildSensorStatusItem('Gas Sensor', false, 'Offline'),
            _buildSensorStatusItem('Motion Sensor', true, 'Active'),
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

  Widget _buildSensorStatusItem(String name, bool isOnline, String value) {
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 1.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(name),
          Row(
            children: [
              Container(
                width: 2.w,
                height: 2.w,
                decoration: BoxDecoration(
                  color: isOnline ? AppTheme.successLight : AppTheme.errorLight,
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(width: 2.w),
              Text(
                value,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showFilterOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: EdgeInsets.all(4.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Filter Options',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            SizedBox(height: 2.h),
            Wrap(
              spacing: 2.w,
              children: [
                FilterChip(
                  label: const Text('Fresh'),
                  selected: true,
                  onSelected: (value) {},
                ),
                FilterChip(
                  label: const Text('Expiring Soon'),
                  selected: false,
                  onSelected: (value) {},
                ),
                FilterChip(
                  label: const Text('All Items'),
                  selected: false,
                  onSelected: (value) {},
                ),
              ],
            ),
            SizedBox(height: 2.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Apply Filters'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _donateFood(Map<String, dynamic> foodItem) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Donate Food'),
        content: Text('Are you sure you want to donate ${foodItem['name']}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${foodItem['name']} marked for donation'),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            child: const Text('Donate'),
          ),
        ],
      ),
    );
  }

  void _updateFood(Map<String, dynamic> foodItem) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Updating ${foodItem['name']}...'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _markConsumed(Map<String, dynamic> foodItem) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${foodItem['name']} marked as consumed'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showFoodDetails(Map<String, dynamic> foodItem) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildFoodDetailsBottomSheet(foodItem),
    );
  }

  Widget _buildNotificationBottomSheet() {
    final theme = Theme.of(context);

    return Container(
      height: 70.h,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(5.w)),
      ),
      child: Column(
        children: [
          Container(
            width: 10.w,
            height: 1.h,
            margin: EdgeInsets.symmetric(vertical: 2.h),
            decoration: BoxDecoration(
              color: theme.colorScheme.outline.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(0.5.h),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Notifications',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  child: const Text('Mark all read'),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              itemCount: 5,
              itemBuilder: (context, index) {
                return Card(
                  margin: EdgeInsets.only(bottom: 2.h),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor:
                          theme.colorScheme.primary.withValues(alpha: 0.1),
                      child: CustomIconWidget(
                        iconName: 'restaurant',
                        size: 5.w,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    title: Text(
                      'New donation request from Local NGO',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    subtitle: Text(
                      'Requesting 20kg vegetables - 2 hours ago',
                      style: theme.textTheme.bodySmall,
                    ),
                    trailing: Container(
                      width: 2.w,
                      height: 2.w,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary,
                        shape: BoxShape.circle,
                      ),
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

  Widget _buildFoodDetailsBottomSheet(Map<String, dynamic> foodItem) {
    final theme = Theme.of(context);

    return Container(
      height: 80.h,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(5.w)),
      ),
      child: Column(
        children: [
          Container(
            width: 10.w,
            height: 1.h,
            margin: EdgeInsets.symmetric(vertical: 2.h),
            decoration: BoxDecoration(
              color: theme.colorScheme.outline.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(0.5.h),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(4.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Food Image
                  ClipRRect(
                    borderRadius: BorderRadius.circular(3.w),
                    child: CustomImageWidget(
                      imageUrl: (foodItem['image'] as String?) ?? '',
                      width: double.infinity,
                      height: 30.h,
                      fit: BoxFit.cover,
                    ),
                  ),
                  SizedBox(height: 2.h),

                  // Food Name and Type
                  Text(
                    (foodItem['name'] as String?) ?? 'Unknown Food',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    (foodItem['type'] as String?) ?? 'Food Item',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 2.h),

                  // Details Grid
                  Row(
                    children: [
                      Expanded(
                        child: _buildDetailCard(
                          'Quantity',
                          '${foodItem['quantity']} ${foodItem['unit']}',
                          Icons.scale,
                          theme,
                        ),
                      ),
                      SizedBox(width: 2.w),
                      Expanded(
                        child: _buildDetailCard(
                          'Freshness',
                          '${foodItem['freshnessScore']}%',
                          Icons.eco,
                          theme,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 2.h),

                  Row(
                    children: [
                      Expanded(
                        child: _buildDetailCard(
                          'Temperature',
                          '${foodItem['temperature']}°C',
                          Icons.thermostat,
                          theme,
                        ),
                      ),
                      SizedBox(width: 2.w),
                      Expanded(
                        child: _buildDetailCard(
                          'Humidity',
                          '${foodItem['humidity']}%',
                          Icons.water_drop,
                          theme,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 3.h),

                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pop(context);
                            _donateFood(foodItem);
                          },
                          icon: CustomIconWidget(
                            iconName: 'volunteer_activism',
                            size: 4.w,
                            color: theme.colorScheme.onPrimary,
                          ),
                          label: const Text('Donate Now'),
                        ),
                      ),
                      SizedBox(width: 2.w),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Navigator.pop(context);
                            _updateFood(foodItem);
                          },
                          icon: CustomIconWidget(
                            iconName: 'edit',
                            size: 4.w,
                            color: theme.colorScheme.primary,
                          ),
                          label: const Text('Update'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailCard(
      String title, String value, IconData icon, ThemeData theme) {
    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(2.w),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        children: [
          CustomIconWidget(
            iconName: icon.codePoint.toString(),
            size: 6.w,
            color: theme.colorScheme.primary,
          ),
          SizedBox(height: 1.h),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            title,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }
}

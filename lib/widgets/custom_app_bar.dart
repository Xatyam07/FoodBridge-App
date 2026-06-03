import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

enum CustomAppBarVariant {
  standard,
  centered,
  minimal,
  dashboard,
  search,
}

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final CustomAppBarVariant variant;
  final List<Widget>? actions;
  final Widget? leading;
  final bool automaticallyImplyLeading;
  final VoidCallback? onBackPressed;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double? elevation;
  final bool showNotificationBadge;
  final int notificationCount;
  final VoidCallback? onNotificationTap;
  final VoidCallback? onSearchTap;
  final String? searchHint;

  const CustomAppBar({
    super.key,
    required this.title,
    this.variant = CustomAppBarVariant.standard,
    this.actions,
    this.leading,
    this.automaticallyImplyLeading = true,
    this.onBackPressed,
    this.backgroundColor,
    this.foregroundColor,
    this.elevation,
    this.showNotificationBadge = false,
    this.notificationCount = 0,
    this.onNotificationTap,
    this.onSearchTap,
    this.searchHint,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return AppBar(
      title: _buildTitle(context),
      centerTitle: variant == CustomAppBarVariant.centered ||
          variant == CustomAppBarVariant.minimal,
      leading: _buildLeading(context),
      automaticallyImplyLeading: automaticallyImplyLeading,
      actions: _buildActions(context),
      backgroundColor: backgroundColor ??
          (variant == CustomAppBarVariant.minimal
              ? Colors.transparent
              : theme.appBarTheme.backgroundColor),
      foregroundColor: foregroundColor ?? theme.appBarTheme.foregroundColor,
      elevation:
          elevation ?? (variant == CustomAppBarVariant.minimal ? 0 : 2.0),
      surfaceTintColor: Colors.transparent,
      shadowColor: theme.appBarTheme.shadowColor,
      flexibleSpace: variant == CustomAppBarVariant.dashboard
          ? _buildDashboardBackground(context)
          : null,
    );
  }

  Widget _buildTitle(BuildContext context) {
    final theme = Theme.of(context);

    switch (variant) {
      case CustomAppBarVariant.search:
        return GestureDetector(
          onTap: onSearchTap,
          child: Container(
            height: 40,
            decoration: BoxDecoration(
              color: theme.colorScheme.surface.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: theme.colorScheme.outline.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                const SizedBox(width: 16),
                Icon(
                  Icons.search,
                  size: 20,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    searchHint ?? 'Search food items...',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );

      case CustomAppBarVariant.minimal:
        return Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: theme.colorScheme.onSurface,
          ),
        );

      case CustomAppBarVariant.dashboard:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
            ),
            Text(
              _getCurrentDateString(),
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ],
        );

      default:
        return Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        );
    }
  }

  Widget? _buildLeading(BuildContext context) {
    if (leading != null) return leading;

    if (automaticallyImplyLeading && Navigator.of(context).canPop()) {
      return IconButton(
        icon: const Icon(Icons.arrow_back_ios, size: 20),
        onPressed: onBackPressed ?? () => Navigator.of(context).pop(),
        tooltip: 'Back',
      );
    }

    return null;
  }

  List<Widget>? _buildActions(BuildContext context) {
    final theme = Theme.of(context);
    final List<Widget> actionWidgets = [];

    // Add role-specific actions based on current route
    final currentRoute = ModalRoute.of(context)?.settings.name;

    switch (currentRoute) {
      case '/provider-dashboard':
        actionWidgets.addAll([
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            onPressed: () =>
                Navigator.pushNamed(context, '/food-upload-screen'),
            tooltip: 'Add Food Item',
          ),
          _buildNotificationButton(context),
        ]);
        break;

      case '/ngo-alert-management':
        actionWidgets.addAll([
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterDialog(context),
            tooltip: 'Filter Alerts',
          ),
          _buildNotificationButton(context),
        ]);
        break;

      case '/volunteer-route-navigation':
        actionWidgets.addAll([
          IconButton(
            icon: const Icon(Icons.navigation),
            onPressed: () => _startNavigation(context),
            tooltip: 'Start Navigation',
          ),
          IconButton(
            icon: const Icon(Icons.phone),
            onPressed: () => _showContactDialog(context),
            tooltip: 'Contact Support',
          ),
        ]);
        break;

      default:
        if (variant == CustomAppBarVariant.search) {
          actionWidgets.add(
            IconButton(
              icon: const Icon(Icons.tune),
              onPressed: () => _showSearchFilters(context),
              tooltip: 'Search Filters',
            ),
          );
        }
        actionWidgets.add(_buildNotificationButton(context));
    }

    // Add custom actions if provided
    if (actions != null) {
      actionWidgets.addAll(actions!);
    }

    return actionWidgets.isNotEmpty ? actionWidgets : null;
  }

  Widget _buildNotificationButton(BuildContext context) {
    final theme = Theme.of(context);

    return Stack(
      children: [
        IconButton(
          icon: const Icon(Icons.notifications_outlined),
          onPressed: onNotificationTap ?? () => _showNotifications(context),
          tooltip: 'Notifications',
        ),
        if (showNotificationBadge && notificationCount > 0)
          Positioned(
            right: 8,
            top: 8,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: theme.colorScheme.error,
                borderRadius: BorderRadius.circular(10),
              ),
              constraints: const BoxConstraints(
                minWidth: 16,
                minHeight: 16,
              ),
              child: Text(
                notificationCount > 99 ? '99+' : notificationCount.toString(),
                style: GoogleFonts.inter(
                  color: theme.colorScheme.onError,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }

  Widget? _buildDashboardBackground(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.primary.withValues(alpha: 0.05),
            theme.colorScheme.secondary.withValues(alpha: 0.02),
          ],
        ),
      ),
    );
  }

  String _getCurrentDateString() {
    final now = DateTime.now();
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return '${months[now.month - 1]} ${now.day}, ${now.year}';
  }

  void _showNotifications(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _NotificationBottomSheet(),
    );
  }

  void _showFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Filter Alerts',
          style: GoogleFonts.inter(fontWeight: FontWeight.w600),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CheckboxListTile(
              title: const Text('Urgent'),
              value: true,
              onChanged: (value) {},
            ),
            CheckboxListTile(
              title: const Text('Expiring Soon'),
              value: false,
              onChanged: (value) {},
            ),
            CheckboxListTile(
              title: const Text('New Donations'),
              value: true,
              onChanged: (value) {},
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }

  void _showSearchFilters(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Search Filters',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              children: [
                FilterChip(
                  label: const Text('Fresh'),
                  selected: true,
                  onSelected: (value) {},
                ),
                FilterChip(
                  label: const Text('Expiring'),
                  selected: false,
                  onSelected: (value) {},
                ),
                FilterChip(
                  label: const Text('Nearby'),
                  selected: true,
                  onSelected: (value) {},
                ),
              ],
            ),
            const SizedBox(height: 16),
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

  void _startNavigation(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Starting navigation...'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _showContactDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Contact Support',
          style: GoogleFonts.inter(fontWeight: FontWeight.w600),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.phone),
              title: const Text('Call Support'),
              subtitle: const Text('+1 (555) 123-4567'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.message),
              title: const Text('Send Message'),
              subtitle: const Text('Chat with support team'),
              onTap: () => Navigator.pop(context),
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

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _NotificationBottomSheet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: theme.colorScheme.outline.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Notifications',
                  style: GoogleFonts.inter(
                    fontSize: 20,
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
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: 5,
              itemBuilder: (context, index) {
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor:
                          theme.colorScheme.primary.withValues(alpha: 0.1),
                      child: Icon(
                        Icons.restaurant,
                        color: theme.colorScheme.primary,
                        size: 20,
                      ),
                    ),
                    title: Text(
                      'New food donation available',
                      style: GoogleFonts.inter(fontWeight: FontWeight.w500),
                    ),
                    subtitle: Text(
                      '50 meals from Local Restaurant - 2 hours ago',
                      style: GoogleFonts.inter(fontSize: 12),
                    ),
                    trailing: Container(
                      width: 8,
                      height: 8,
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
}

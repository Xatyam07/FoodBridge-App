import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

enum CustomBottomBarVariant {
  standard,
  floating,
  minimal,
  roleAdaptive,
}

enum UserRole {
  provider,
  ngo,
  volunteer,
  guest,
}

class CustomBottomBar extends StatefulWidget {
  final CustomBottomBarVariant variant;
  final UserRole userRole;
  final int currentIndex;
  final ValueChanged<int>? onTap;
  final Color? backgroundColor;
  final Color? selectedItemColor;
  final Color? unselectedItemColor;
  final double? elevation;
  final bool showLabels;
  final EdgeInsets? margin;

  const CustomBottomBar({
    super.key,
    this.variant = CustomBottomBarVariant.standard,
    this.userRole = UserRole.guest,
    this.currentIndex = 0,
    this.onTap,
    this.backgroundColor,
    this.selectedItemColor,
    this.unselectedItemColor,
    this.elevation,
    this.showLabels = true,
    this.margin,
  });

  @override
  State<CustomBottomBar> createState() => _CustomBottomBarState();
}

class _CustomBottomBarState extends State<CustomBottomBar>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final items = _getNavigationItems();

    switch (widget.variant) {
      case CustomBottomBarVariant.floating:
        return _buildFloatingBottomBar(context, theme, items);
      case CustomBottomBarVariant.minimal:
        return _buildMinimalBottomBar(context, theme, items);
      case CustomBottomBarVariant.roleAdaptive:
        return _buildRoleAdaptiveBottomBar(context, theme, items);
      default:
        return _buildStandardBottomBar(context, theme, items);
    }
  }

  List<_NavigationItem> _getNavigationItems() {
    switch (widget.userRole) {
      case UserRole.provider:
        return [
          _NavigationItem(
            icon: Icons.dashboard_outlined,
            activeIcon: Icons.dashboard,
            label: 'Dashboard',
            route: '/provider-dashboard',
          ),
          _NavigationItem(
            icon: Icons.add_circle_outline,
            activeIcon: Icons.add_circle,
            label: 'Add Food',
            route: '/food-upload-screen',
          ),
          _NavigationItem(
            icon: Icons.inventory_2_outlined,
            activeIcon: Icons.inventory_2,
            label: 'Inventory',
            route: '/provider-dashboard',
          ),
          _NavigationItem(
            icon: Icons.analytics_outlined,
            activeIcon: Icons.analytics,
            label: 'Analytics',
            route: '/provider-dashboard',
          ),
        ];

      case UserRole.ngo:
        return [
          _NavigationItem(
            icon: Icons.notifications_outlined,
            activeIcon: Icons.notifications,
            label: 'Alerts',
            route: '/ngo-alert-management',
          ),
          _NavigationItem(
            icon: Icons.map_outlined,
            activeIcon: Icons.map,
            label: 'Map',
            route: '/ngo-alert-management',
          ),
          _NavigationItem(
            icon: Icons.people_outline,
            activeIcon: Icons.people,
            label: 'Volunteers',
            route: '/ngo-alert-management',
          ),
          _NavigationItem(
            icon: Icons.assessment_outlined,
            activeIcon: Icons.assessment,
            label: 'Reports',
            route: '/ngo-alert-management',
          ),
        ];

      case UserRole.volunteer:
        return [
          _NavigationItem(
            icon: Icons.navigation_outlined,
            activeIcon: Icons.navigation,
            label: 'Routes',
            route: '/volunteer-route-navigation',
          ),
          _NavigationItem(
            icon: Icons.assignment_outlined,
            activeIcon: Icons.assignment,
            label: 'Tasks',
            route: '/volunteer-route-navigation',
          ),
          _NavigationItem(
            icon: Icons.history_outlined,
            activeIcon: Icons.history,
            label: 'History',
            route: '/volunteer-route-navigation',
          ),
          _NavigationItem(
            icon: Icons.person_outline,
            activeIcon: Icons.person,
            label: 'Profile',
            route: '/volunteer-route-navigation',
          ),
        ];

      default: // Guest user
        return [
          _NavigationItem(
            icon: Icons.home_outlined,
            activeIcon: Icons.home,
            label: 'Home',
            route: '/login-screen',
          ),
          _NavigationItem(
            icon: Icons.search_outlined,
            activeIcon: Icons.search,
            label: 'Search',
            route: '/login-screen',
          ),
          _NavigationItem(
            icon: Icons.info_outline,
            activeIcon: Icons.info,
            label: 'About',
            route: '/login-screen',
          ),
          _NavigationItem(
            icon: Icons.login_outlined,
            activeIcon: Icons.login,
            label: 'Login',
            route: '/login-screen',
          ),
        ];
    }
  }

  Widget _buildStandardBottomBar(
    BuildContext context,
    ThemeData theme,
    List<_NavigationItem> items,
  ) {
    return BottomNavigationBar(
      currentIndex: widget.currentIndex.clamp(0, items.length - 1),
      onTap: (index) => _handleTap(context, index, items),
      type: BottomNavigationBarType.fixed,
      backgroundColor: widget.backgroundColor ??
          theme.bottomNavigationBarTheme.backgroundColor,
      selectedItemColor: widget.selectedItemColor ??
          theme.bottomNavigationBarTheme.selectedItemColor,
      unselectedItemColor: widget.unselectedItemColor ??
          theme.bottomNavigationBarTheme.unselectedItemColor,
      elevation: widget.elevation ?? 8.0,
      showSelectedLabels: widget.showLabels,
      showUnselectedLabels: widget.showLabels,
      selectedLabelStyle: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
      unselectedLabelStyle: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w400,
      ),
      items: items
          .map((item) => BottomNavigationBarItem(
                icon: Icon(item.icon),
                activeIcon: Icon(item.activeIcon),
                label: item.label,
                tooltip: item.label,
              ))
          .toList(),
    );
  }

  Widget _buildFloatingBottomBar(
    BuildContext context,
    ThemeData theme,
    List<_NavigationItem> items,
  ) {
    return Container(
      margin: widget.margin ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: widget.backgroundColor ?? theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BottomNavigationBar(
          currentIndex: widget.currentIndex.clamp(0, items.length - 1),
          onTap: (index) => _handleTap(context, index, items),
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.transparent,
          selectedItemColor:
              widget.selectedItemColor ?? theme.colorScheme.primary,
          unselectedItemColor: widget.unselectedItemColor ??
              theme.colorScheme.onSurface.withValues(alpha: 0.6),
          elevation: 0,
          showSelectedLabels: widget.showLabels,
          showUnselectedLabels: widget.showLabels,
          selectedLabelStyle: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w400,
          ),
          items: items
              .map((item) => BottomNavigationBarItem(
                    icon: Icon(item.icon),
                    activeIcon: Icon(item.activeIcon),
                    label: item.label,
                    tooltip: item.label,
                  ))
              .toList(),
        ),
      ),
    );
  }

  Widget _buildMinimalBottomBar(
    BuildContext context,
    ThemeData theme,
    List<_NavigationItem> items,
  ) {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: widget.backgroundColor ?? theme.colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: theme.colorScheme.outline.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: items.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          final isSelected = index == widget.currentIndex;

          return GestureDetector(
            onTap: () => _handleTap(context, index, items),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isSelected ? item.activeIcon : item.icon,
                    color: isSelected
                        ? (widget.selectedItemColor ??
                            theme.colorScheme.primary)
                        : (widget.unselectedItemColor ??
                            theme.colorScheme.onSurface.withValues(alpha: 0.6)),
                    size: 24,
                  ),
                  if (widget.showLabels) ...[
                    const SizedBox(height: 4),
                    Text(
                      item.label,
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.w400,
                        color: isSelected
                            ? (widget.selectedItemColor ??
                                theme.colorScheme.primary)
                            : (widget.unselectedItemColor ??
                                theme.colorScheme.onSurface
                                    .withValues(alpha: 0.6)),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildRoleAdaptiveBottomBar(
    BuildContext context,
    ThemeData theme,
    List<_NavigationItem> items,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: widget.backgroundColor ?? theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Container(
          height: 70,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: items.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              final isSelected = index == widget.currentIndex;

              return Expanded(
                child: GestureDetector(
                  onTap: () => _handleTap(context, index, items),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? theme.colorScheme.primary.withValues(alpha: 0.1)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 200),
                          child: Icon(
                            isSelected ? item.activeIcon : item.icon,
                            key: ValueKey(isSelected),
                            color: isSelected
                                ? theme.colorScheme.primary
                                : theme.colorScheme.onSurface
                                    .withValues(alpha: 0.6),
                            size: 24,
                          ),
                        ),
                        if (widget.showLabels) ...[
                          const SizedBox(height: 4),
                          AnimatedDefaultTextStyle(
                            duration: const Duration(milliseconds: 200),
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                              color: isSelected
                                  ? theme.colorScheme.primary
                                  : theme.colorScheme.onSurface
                                      .withValues(alpha: 0.6),
                            ),
                            child: Text(
                              item.label,
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  void _handleTap(
      BuildContext context, int index, List<_NavigationItem> items) {
    if (index < 0 || index >= items.length) return;

    // Trigger haptic feedback for better UX
    _animationController.forward().then((_) {
      _animationController.reverse();
    });

    // Call the provided onTap callback
    widget.onTap?.call(index);

    // Navigate to the selected route
    final route = items[index].route;
    final currentRoute = ModalRoute.of(context)?.settings.name;

    if (route != currentRoute) {
      Navigator.pushNamedAndRemoveUntil(
        context,
        route,
        (route) => false,
      );
    }
  }
}

class _NavigationItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final String route;

  const _NavigationItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.route,
  });
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

enum CustomTabBarVariant {
  standard,
  segmented,
  pills,
  underlined,
  minimal,
}

class CustomTabBar extends StatefulWidget implements PreferredSizeWidget {
  final List<CustomTab> tabs;
  final CustomTabBarVariant variant;
  final int initialIndex;
  final ValueChanged<int>? onTap;
  final Color? backgroundColor;
  final Color? selectedColor;
  final Color? unselectedColor;
  final Color? indicatorColor;
  final double? indicatorWeight;
  final EdgeInsets? padding;
  final bool isScrollable;
  final TabController? controller;

  const CustomTabBar({
    super.key,
    required this.tabs,
    this.variant = CustomTabBarVariant.standard,
    this.initialIndex = 0,
    this.onTap,
    this.backgroundColor,
    this.selectedColor,
    this.unselectedColor,
    this.indicatorColor,
    this.indicatorWeight,
    this.padding,
    this.isScrollable = false,
    this.controller,
  });

  @override
  State<CustomTabBar> createState() => _CustomTabBarState();

  @override
  Size get preferredSize => const Size.fromHeight(48);
}

class _CustomTabBarState extends State<CustomTabBar>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _tabController = widget.controller ??
        TabController(
          length: widget.tabs.length,
          vsync: this,
          initialIndex: widget.initialIndex,
        );
    _tabController.addListener(_handleTabChange);
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _tabController.dispose();
    }
    super.dispose();
  }

  void _handleTabChange() {
    if (_tabController.indexIsChanging) {
      setState(() {
        _currentIndex = _tabController.index;
      });
      widget.onTap?.call(_tabController.index);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    switch (widget.variant) {
      case CustomTabBarVariant.segmented:
        return _buildSegmentedTabBar(context, theme);
      case CustomTabBarVariant.pills:
        return _buildPillsTabBar(context, theme);
      case CustomTabBarVariant.underlined:
        return _buildUnderlinedTabBar(context, theme);
      case CustomTabBarVariant.minimal:
        return _buildMinimalTabBar(context, theme);
      default:
        return _buildStandardTabBar(context, theme);
    }
  }

  Widget _buildStandardTabBar(BuildContext context, ThemeData theme) {
    return Container(
      color: widget.backgroundColor ?? theme.colorScheme.surface,
      padding: widget.padding ?? const EdgeInsets.symmetric(horizontal: 16),
      child: TabBar(
        controller: _tabController,
        isScrollable: widget.isScrollable,
        labelColor: widget.selectedColor ?? theme.colorScheme.primary,
        unselectedLabelColor: widget.unselectedColor ??
            theme.colorScheme.onSurface.withValues(alpha: 0.6),
        indicatorColor: widget.indicatorColor ?? theme.colorScheme.primary,
        indicatorWeight: widget.indicatorWeight ?? 2.0,
        labelStyle: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
        unselectedLabelStyle: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.5,
        ),
        tabs: widget.tabs
            .map((tab) => Tab(
          text: tab.text,
          icon: tab.icon != null ? Icon(tab.icon) : null, // ✅ Fixed
          iconMargin: tab.icon != null
              ? const EdgeInsets.only(bottom: 4)
              : null,
        ))
            .toList(),
      ),
    );
  }

  Widget _buildSegmentedTabBar(BuildContext context, ThemeData theme) {
    return Container(
      margin: widget.padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: widget.tabs.asMap().entries.map((entry) {
          final index = entry.key;
          final tab = entry.value;
          final isSelected = index == _currentIndex;
          final isFirst = index == 0;
          final isLast = index == widget.tabs.length - 1;

          return Expanded(
            child: GestureDetector(
              onTap: () {
                _tabController.animateTo(index);
                widget.onTap?.call(index);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding:
                const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                decoration: BoxDecoration(
                  color: isSelected
                      ? theme.colorScheme.primary
                      : Colors.transparent,
                  borderRadius: BorderRadius.horizontal(
                    left: isFirst ? const Radius.circular(12) : Radius.zero,
                    right: isLast ? const Radius.circular(12) : Radius.zero,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (tab.icon != null) ...[
                      Icon(
                        tab.icon,
                        size: 18,
                        color: isSelected
                            ? theme.colorScheme.onPrimary
                            : theme.colorScheme.onSurface
                            .withValues(alpha: 0.6),
                      ),
                      const SizedBox(width: 8),
                    ],
                    Flexible(
                      child: Text(
                        tab.text,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w400,
                          color: isSelected
                              ? theme.colorScheme.onPrimary
                              : theme.colorScheme.onSurface
                              .withValues(alpha: 0.6),
                        ),
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPillsTabBar(BuildContext context, ThemeData theme) {
    return Container(
      height: 48,
      padding: widget.padding ?? const EdgeInsets.symmetric(horizontal: 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: widget.tabs.length,
        itemBuilder: (context, index) {
          final tab = widget.tabs[index];
          final isSelected = index == _currentIndex;

          return GestureDetector(
            onTap: () {
              _tabController.animateTo(index);
              widget.onTap?.call(index);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 8, top: 8, bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected
                      ? theme.colorScheme.primary
                      : theme.colorScheme.outline.withValues(alpha: 0.3),
                ),
                boxShadow: isSelected
                    ? [
                  BoxShadow(
                    color:
                    theme.colorScheme.primary.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
                    : null,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (tab.icon != null) ...[
                    Icon(
                      tab.icon,
                      size: 16,
                      color: isSelected
                          ? theme.colorScheme.onPrimary
                          : theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                    const SizedBox(width: 6),
                  ],
                  Text(
                    tab.text,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight:
                      isSelected ? FontWeight.w600 : FontWeight.w400,
                      color: isSelected
                          ? theme.colorScheme.onPrimary
                          : theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildUnderlinedTabBar(BuildContext context, ThemeData theme) {
    return Container(
      color: widget.backgroundColor ?? Colors.transparent,
      padding: widget.padding ?? const EdgeInsets.symmetric(horizontal: 16),
      child: TabBar(
        controller: _tabController,
        isScrollable: widget.isScrollable,
        labelColor: widget.selectedColor ?? theme.colorScheme.primary,
        unselectedLabelColor: widget.unselectedColor ??
            theme.colorScheme.onSurface.withValues(alpha: 0.6),
        indicatorColor: widget.indicatorColor ?? theme.colorScheme.primary,
        indicatorWeight: widget.indicatorWeight ?? 3.0,
        indicatorSize: TabBarIndicatorSize.label,
        dividerColor: Colors.transparent,
        labelStyle: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.15,
        ),
        unselectedLabelStyle: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.15,
        ),
        tabs: widget.tabs
            .map((tab) => Tab(
          text: tab.text,
          icon: tab.icon != null ? Icon(tab.icon) : null, // ✅ Fixed
          iconMargin: tab.icon != null
              ? const EdgeInsets.only(bottom: 4)
              : null,
        ))
            .toList(),
      ),
    );
  }

  Widget _buildMinimalTabBar(BuildContext context, ThemeData theme) {
    return Container(
      height: 48,
      padding: widget.padding ?? const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: widget.tabs.asMap().entries.map((entry) {
          final index = entry.key;
          final tab = entry.value;
          final isSelected = index == _currentIndex;

          return Expanded(
            child: GestureDetector(
              onTap: () {
                _tabController.animateTo(index);
                widget.onTap?.call(index);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: isSelected
                          ? theme.colorScheme.primary
                          : Colors.transparent,
                      width: 2,
                    ),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (tab.icon != null) ...[
                      Icon(
                        tab.icon,
                        size: 18,
                        color: isSelected
                            ? theme.colorScheme.primary
                            : theme.colorScheme.onSurface
                            .withValues(alpha: 0.6),
                      ),
                      const SizedBox(width: 8),
                    ],
                    Flexible(
                      child: Text(
                        tab.text,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w400,
                          color: isSelected
                              ? theme.colorScheme.primary
                              : theme.colorScheme.onSurface
                              .withValues(alpha: 0.6),
                        ),
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class CustomTab {
  final String text;
  final IconData? icon;
  final String? route;
  final VoidCallback? onTap;

  const CustomTab({
    required this.text,
    this.icon,
    this.route,
    this.onTap,
  });
}

// Predefined tab configurations for food waste management contexts
class FoodManagementTabs {
  static List<CustomTab> get providerTabs => [
    const CustomTab(
      text: 'Active',
      icon: Icons.restaurant_menu,
    ),
    const CustomTab(
      text: 'Expiring',
      icon: Icons.schedule,
    ),
    const CustomTab(
      text: 'Donated',
      icon: Icons.volunteer_activism,
    ),
    const CustomTab(
      text: 'Analytics',
      icon: Icons.analytics,
    ),
  ];

  static List<CustomTab> get ngoTabs => [
    const CustomTab(
      text: 'Urgent',
      icon: Icons.priority_high,
    ),
    const CustomTab(
      text: 'Available',
      icon: Icons.inventory,
    ),
    const CustomTab(
      text: 'In Progress',
      icon: Icons.local_shipping,
    ),
    const CustomTab(
      text: 'Completed',
      icon: Icons.check_circle,
    ),
  ];

  static List<CustomTab> get volunteerTabs => [
    const CustomTab(
      text: 'Pickup',
      icon: Icons.location_on,
    ),
    const CustomTab(
      text: 'Delivery',
      icon: Icons.delivery_dining,
    ),
    const CustomTab(
      text: 'Route',
      icon: Icons.navigation,
    ),
    const CustomTab(
      text: 'History',
      icon: Icons.history,
    ),
  ];

  static List<CustomTab> get statusTabs => [
    const CustomTab(
      text: 'Fresh',
      icon: Icons.eco,
    ),
    const CustomTab(
      text: 'Good',
      icon: Icons.thumb_up,
    ),
    const CustomTab(
      text: 'Expiring',
      icon: Icons.warning,
    ),
    const CustomTab(
      text: 'Expired',
      icon: Icons.dangerous,
    ),
  ];
}

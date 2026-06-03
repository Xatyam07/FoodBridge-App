import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class RouteSummaryCard extends StatefulWidget {
  final Map<String, dynamic> routeData;
  final bool isCollapsed;
  final VoidCallback onToggle;

  const RouteSummaryCard({
    super.key,
    required this.routeData,
    required this.isCollapsed,
    required this.onToggle,
  });

  @override
  State<RouteSummaryCard> createState() => _RouteSummaryCardState();
}

class _RouteSummaryCardState extends State<RouteSummaryCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _expandAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    if (!widget.isCollapsed) {
      _animationController.forward();
    }
  }

  @override
  void didUpdateWidget(RouteSummaryCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isCollapsed != oldWidget.isCollapsed) {
      if (widget.isCollapsed) {
        _animationController.reverse();
      } else {
        _animationController.forward();
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final stops =
        (widget.routeData['stops'] as List).cast<Map<String, dynamic>>();

    return GestureDetector(
      onTap: widget.onToggle,
      child: Container(
        margin: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.shadow.withValues(alpha: 0.1),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            _buildSummaryHeader(theme, stops),
            AnimatedBuilder(
              animation: _expandAnimation,
              builder: (context, child) {
                return SizeTransition(
                  sizeFactor: _expandAnimation,
                  child: child,
                );
              },
              child: _buildExpandedContent(theme, stops),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryHeader(
      ThemeData theme, List<Map<String, dynamic>> stops) {
    return Container(
      padding: EdgeInsets.all(4.w),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(2.w),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: CustomIconWidget(
              iconName: 'navigation',
              color: theme.colorScheme.primary,
              size: 24,
            ),
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Route Summary',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 1.h),
                Row(
                  children: [
                    _buildSummaryItem(
                      theme,
                      '${widget.routeData['totalDistance']}',
                      'distance',
                    ),
                    SizedBox(width: 4.w),
                    _buildSummaryItem(
                      theme,
                      '${widget.routeData['estimatedTime']}',
                      'schedule',
                    ),
                    SizedBox(width: 4.w),
                    _buildSummaryItem(
                      theme,
                      '${stops.length} stops',
                      'location_on',
                    ),
                  ],
                ),
              ],
            ),
          ),
          AnimatedRotation(
            turns: widget.isCollapsed ? 0 : 0.5,
            duration: const Duration(milliseconds: 300),
            child: CustomIconWidget(
              iconName: 'keyboard_arrow_down',
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              size: 24,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(ThemeData theme, String value, String iconName) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        CustomIconWidget(
          iconName: iconName,
          color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          size: 16,
        ),
        SizedBox(width: 1.w),
        Text(
          value,
          style: theme.textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildExpandedContent(
      ThemeData theme, List<Map<String, dynamic>> stops) {
    return Container(
      padding: EdgeInsets.fromLTRB(4.w, 0, 4.w, 4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Divider(
            color: theme.colorScheme.outline.withValues(alpha: 0.2),
            height: 1,
          ),
          SizedBox(height: 3.h),
          Text(
            'Stops (${stops.length})',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 2.h),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: stops.length,
            separatorBuilder: (context, index) => SizedBox(height: 2.h),
            itemBuilder: (context, index) {
              final stop = stops[index];
              return _buildStopItem(theme, stop, index);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStopItem(ThemeData theme, Map<String, dynamic> stop, int index) {
    final isPickup = stop['type'] == 'pickup';
    final isCompleted = stop['status'] == 'completed';
    final isCurrent = stop['status'] == 'current';

    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: isCurrent
            ? theme.colorScheme.primary.withValues(alpha: 0.1)
            : theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCurrent
              ? theme.colorScheme.primary
              : theme.colorScheme.outline.withValues(alpha: 0.2),
          width: isCurrent ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 8.w,
            height: 8.w,
            decoration: BoxDecoration(
              color: isCompleted
                  ? theme.colorScheme.primary
                  : isPickup
                      ? Colors.blue
                      : Colors.green,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: isCompleted
                  ? CustomIconWidget(
                      iconName: 'check',
                      color: theme.colorScheme.onPrimary,
                      size: 16,
                    )
                  : Text(
                      '${index + 1}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        stop['name'] as String,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          decoration:
                              isCompleted ? TextDecoration.lineThrough : null,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 2.w, vertical: 0.5.h),
                      decoration: BoxDecoration(
                        color: isPickup
                            ? Colors.blue.withValues(alpha: 0.1)
                            : Colors.green.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        isPickup ? 'Pickup' : 'Delivery',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: isPickup ? Colors.blue : Colors.green,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 1.h),
                Row(
                  children: [
                    CustomIconWidget(
                      iconName: 'restaurant',
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      size: 16,
                    ),
                    SizedBox(width: 1.w),
                    Text(
                      stop['foodType'] as String,
                      style: theme.textTheme.bodySmall,
                    ),
                    SizedBox(width: 3.w),
                    CustomIconWidget(
                      iconName: 'scale',
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      size: 16,
                    ),
                    SizedBox(width: 1.w),
                    Text(
                      '${stop['quantity']} meals',
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
                if (stop['instructions'] != null) ...[
                  SizedBox(height: 1.h),
                  Text(
                    stop['instructions'] as String,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                      fontStyle: FontStyle.italic,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

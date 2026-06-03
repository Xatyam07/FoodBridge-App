import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class AROverlayWidget extends StatefulWidget {
  final bool isARActive;
  final Map<String, dynamic> currentDestination;
  final VoidCallback onToggleAR;

  const AROverlayWidget({
    super.key,
    required this.isARActive,
    required this.currentDestination,
    required this.onToggleAR,
  });

  @override
  State<AROverlayWidget> createState() => _AROverlayWidgetState();
}

class _AROverlayWidgetState extends State<AROverlayWidget>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _arrowController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _arrowAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _arrowController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _arrowAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _arrowController,
      curve: Curves.easeInOut,
    ));

    if (widget.isARActive) {
      _startAnimations();
    }
  }

  @override
  void didUpdateWidget(AROverlayWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isARActive != oldWidget.isARActive) {
      if (widget.isARActive) {
        _startAnimations();
      } else {
        _stopAnimations();
      }
    }
  }

  void _startAnimations() {
    _pulseController.repeat(reverse: true);
    _arrowController.repeat();
  }

  void _stopAnimations() {
    _pulseController.stop();
    _arrowController.stop();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _arrowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (!widget.isARActive) {
      return _buildARToggleButton(theme);
    }

    return Stack(
      children: [
        // AR Camera View Placeholder
        Container(
          width: double.infinity,
          height: double.infinity,
          color: Colors.black.withValues(alpha: 0.1),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CustomIconWidget(
                  iconName: 'camera_alt',
                  color: Colors.white.withValues(alpha: 0.7),
                  size: 48,
                ),
                SizedBox(height: 2.h),
                Text(
                  'AR Camera View',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
        ),

        // AR Direction Indicators
        _buildDirectionIndicators(theme),

        // Distance and Navigation Info
        _buildNavigationInfo(theme),

        // AR Toggle Button
        Positioned(
          top: 8.h,
          right: 4.w,
          child: _buildARToggleButton(theme),
        ),
      ],
    );
  }

  Widget _buildARToggleButton(ThemeData theme) {
    return GestureDetector(
      onTap: widget.onToggleAR,
      child: Container(
        padding: EdgeInsets.all(3.w),
        decoration: BoxDecoration(
          color: widget.isARActive
              ? theme.colorScheme.primary
              : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.shadow.withValues(alpha: 0.2),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomIconWidget(
              iconName: widget.isARActive ? 'visibility_off' : 'view_in_ar',
              color: widget.isARActive
                  ? theme.colorScheme.onPrimary
                  : theme.colorScheme.primary,
              size: 20,
            ),
            if (!widget.isARActive) ...[
              SizedBox(width: 2.w),
              Text(
                'AR View',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDirectionIndicators(ThemeData theme) {
    return Positioned(
      top: 20.h,
      left: 0,
      right: 0,
      child: Center(
        child: AnimatedBuilder(
          animation: _arrowAnimation,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(0, -10 * _arrowAnimation.value),
              child: AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _pulseAnimation.value,
                    child: Container(
                      padding: EdgeInsets.all(4.w),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withValues(alpha: 0.9),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: theme.colorScheme.primary
                                .withValues(alpha: 0.3),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: CustomIconWidget(
                        iconName: 'navigation',
                        color: theme.colorScheme.onPrimary,
                        size: 32,
                      ),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildNavigationInfo(ThemeData theme) {
    return Positioned(
      bottom: 25.h,
      left: 4.w,
      right: 4.w,
      child: Container(
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface.withValues(alpha: 0.95),
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Distance',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color:
                            theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                    Text(
                      widget.currentDestination['distance'] as String? ??
                          '0.5 km',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'ETA',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color:
                            theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                    Text(
                      widget.currentDestination['eta'] as String? ?? '3 min',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 2.h),
            Container(
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  CustomIconWidget(
                    iconName: 'info_outline',
                    color: theme.colorScheme.primary,
                    size: 20,
                  ),
                  SizedBox(width: 2.w),
                  Expanded(
                    child: Text(
                      'Look for the main entrance with blue signage',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

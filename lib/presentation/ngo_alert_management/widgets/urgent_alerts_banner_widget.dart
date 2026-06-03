import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class UrgentAlertsBannerWidget extends StatefulWidget {
  final int urgentCount;
  final VoidCallback? onViewAll;

  const UrgentAlertsBannerWidget({
    super.key,
    required this.urgentCount,
    this.onViewAll,
  });

  @override
  State<UrgentAlertsBannerWidget> createState() =>
      _UrgentAlertsBannerWidgetState();
}

class _UrgentAlertsBannerWidgetState extends State<UrgentAlertsBannerWidget>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    if (widget.urgentCount > 0) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (widget.urgentCount == 0) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      child: AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _pulseAnimation.value,
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    theme.colorScheme.error,
                    theme.colorScheme.error.withValues(alpha: 0.8),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: theme.colorScheme.error.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(2.w),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.onError.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: CustomIconWidget(
                      iconName: 'priority_high',
                      color: theme.colorScheme.onError,
                      size: 24,
                    ),
                  ),
                  SizedBox(width: 3.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'URGENT ALERTS',
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: theme.colorScheme.onError,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                          ),
                        ),
                        SizedBox(height: 0.5.h),
                        Text(
                          '${widget.urgentCount} donations expiring soon',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onError
                                .withValues(alpha: 0.9),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.onError.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${widget.urgentCount}',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: theme.colorScheme.onError,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(width: 1.w),
                        CustomIconWidget(
                          iconName: 'schedule',
                          color: theme.colorScheme.onError,
                          size: 16,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 2.w),
                  GestureDetector(
                    onTap: widget.onViewAll,
                    child: Container(
                      padding: EdgeInsets.all(2.w),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.onError.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: CustomIconWidget(
                        iconName: 'arrow_forward',
                        color: theme.colorScheme.onError,
                        size: 20,
                      ),
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
}

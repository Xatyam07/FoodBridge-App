import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class FoodInventoryCardWidget extends StatelessWidget {
  final Map<String, dynamic> foodItem;
  final VoidCallback? onDonate;
  final VoidCallback? onUpdate;
  final VoidCallback? onMarkConsumed;
  final VoidCallback? onTap;

  const FoodInventoryCardWidget({
    super.key,
    required this.foodItem,
    this.onDonate,
    this.onUpdate,
    this.onMarkConsumed,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final freshnessScore = (foodItem['freshnessScore'] as num?) ?? 85;
    final freshnessColor = _getFreshnessColor(freshnessScore, theme);
    final expirationHours = (foodItem['expirationHours'] as num?) ?? 24;

    return Slidable(
      key: ValueKey(foodItem['id']),
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        children: [
          SlidableAction(
            onPressed: (_) => onDonate?.call(),
            backgroundColor: theme.colorScheme.primary,
            foregroundColor: theme.colorScheme.onPrimary,
            icon: Icons.volunteer_activism,
            label: 'Donate',
            borderRadius: BorderRadius.circular(2.w),
          ),
          SlidableAction(
            onPressed: (_) => onUpdate?.call(),
            backgroundColor: theme.colorScheme.secondary,
            foregroundColor: theme.colorScheme.onSecondary,
            icon: Icons.edit,
            label: 'Update',
            borderRadius: BorderRadius.circular(2.w),
          ),
          SlidableAction(
            onPressed: (_) => onMarkConsumed?.call(),
            backgroundColor: AppTheme.successLight,
            foregroundColor: Colors.white,
            icon: Icons.check_circle,
            label: 'Used',
            borderRadius: BorderRadius.circular(2.w),
          ),
        ],
      ),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: EdgeInsets.only(bottom: 2.h),
          padding: EdgeInsets.all(4.w),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(3.w),
            border: Border.all(
              color: theme.colorScheme.outline.withValues(alpha: 0.1),
            ),
            boxShadow: [
              BoxShadow(
                color: theme.colorScheme.shadow.withValues(alpha: 0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              // Food Image
              ClipRRect(
                borderRadius: BorderRadius.circular(2.w),
                child: CustomImageWidget(
                  imageUrl: (foodItem['image'] as String?) ?? '',
                  width: 20.w,
                  height: 20.w,
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(width: 4.w),
              // Food Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            (foodItem['name'] as String?) ?? 'Unknown Food',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 2.w,
                            vertical: 0.5.h,
                          ),
                          decoration: BoxDecoration(
                            color: freshnessColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(1.w),
                          ),
                          child: Text(
                            '${freshnessScore.toInt()}%',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: freshnessColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 0.5.h),
                    Text(
                      (foodItem['type'] as String?) ?? 'Food Item',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color:
                            theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                    SizedBox(height: 1.h),
                    Row(
                      children: [
                        CustomIconWidget(
                          iconName: 'scale',
                          size: 4.w,
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.6),
                        ),
                        SizedBox(width: 1.w),
                        Text(
                          '${foodItem['quantity'] ?? 0} ${foodItem['unit'] ?? 'kg'}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(width: 4.w),
                        CustomIconWidget(
                          iconName: 'schedule',
                          size: 4.w,
                          color: _getExpirationColor(expirationHours, theme),
                        ),
                        SizedBox(width: 1.w),
                        Text(
                          _formatExpirationTime(expirationHours),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: _getExpirationColor(expirationHours, theme),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 1.h),
                    // Freshness Indicator
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 0.5.h,
                            decoration: BoxDecoration(
                              color: theme.colorScheme.outline
                                  .withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(0.25.h),
                            ),
                            child: FractionallySizedBox(
                              alignment: Alignment.centerLeft,
                              widthFactor: freshnessScore / 100,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: freshnessColor,
                                  borderRadius: BorderRadius.circular(0.25.h),
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 2.w),
                        Text(
                          _getFreshnessLabel(freshnessScore),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: freshnessColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getFreshnessColor(num score, ThemeData theme) {
    if (score >= 80) return AppTheme.successLight;
    if (score >= 60) return AppTheme.warningLight;
    return AppTheme.errorLight;
  }

  String _getFreshnessLabel(num score) {
    if (score >= 80) return 'Fresh';
    if (score >= 60) return 'Good';
    if (score >= 40) return 'Fair';
    return 'Poor';
  }

  Color _getExpirationColor(num hours, ThemeData theme) {
    if (hours <= 6) return AppTheme.errorLight;
    if (hours <= 24) return AppTheme.warningLight;
    return theme.colorScheme.onSurface.withValues(alpha: 0.6);
  }

  String _formatExpirationTime(num hours) {
    if (hours < 1) {
      final minutes = (hours * 60).round();
      return '${minutes}m left';
    } else if (hours < 24) {
      return '${hours.round()}h left';
    } else {
      final days = (hours / 24).round();
      return '${days}d left';
    }
  }
}

import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/custom_icon_widget.dart';
import '../../../widgets/custom_image_widget.dart';

class AlertCardWidget extends StatelessWidget {
  final Map<String, dynamic> alertData;
  final VoidCallback? onAcceptDonation;
  final VoidCallback? onViewDetails;
  final VoidCallback? onContactProvider;
  final VoidCallback? onAssignVolunteer;
  final VoidCallback? onAddToRoute;

  const AlertCardWidget({
    super.key,
    required this.alertData,
    this.onAcceptDonation,
    this.onViewDetails,
    this.onContactProvider,
    this.onAssignVolunteer,
    this.onAddToRoute,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isUrgent = (alertData['urgency'] as String).toLowerCase() == 'urgent';
    final expirationHours = alertData['expirationHours'] as int;
    final freshnessScore = alertData['freshnessScore'] as double;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: isUrgent
            ? Border.all(color: theme.colorScheme.error, width: 2)
            : null,
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isUrgent) _buildUrgentBanner(context),
          Padding(
            padding: EdgeInsets.all(4.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildProviderHeader(context),
                SizedBox(height: 2.h),
                _buildFoodDetails(context),
                SizedBox(height: 2.h),
                _buildLocationAndDistance(context),
                SizedBox(height: 2.h),
                _buildExpirationAndFreshness(context),
                SizedBox(height: 3.h),
                _buildActionButtons(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUrgentBanner(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 1.h, horizontal: 4.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.error,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Row(
        children: [
          CustomIconWidget(
            iconName: 'priority_high',
            color: theme.colorScheme.onError,
            size: 16,
          ),
          SizedBox(width: 2.w),
          Text(
            'URGENT - Expires in ${alertData['expirationHours']}h',
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.onError,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProviderHeader(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Container(
          width: 12.w,
          height: 12.w,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: theme.colorScheme.outline.withValues(alpha: 0.2),
            ),
          ),
          child: ClipOval(
            child: CustomImageWidget(
              imageUrl: alertData['providerPhoto'] as String,
              width: 12.w,
              height: 12.w,
              fit: BoxFit.cover,
            ),
          ),
        ),
        SizedBox(width: 3.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                alertData['providerName'] as String,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 0.5.h),
              Row(
                children: [
                  CustomIconWidget(
                    iconName: 'verified',
                    color: AppTheme.lightTheme.colorScheme.primary,
                    size: 14,
                  ),
                  SizedBox(width: 1.w),
                  Text(
                    'Blockchain Verified',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
          decoration: BoxDecoration(
            color: _getUrgencyColor(context).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            alertData['urgency'] as String,
            style: theme.textTheme.labelSmall?.copyWith(
              color: _getUrgencyColor(context),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFoodDetails(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(2.w),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: CustomIconWidget(
            iconName: _getFoodIcon(alertData['foodType'] as String),
            color: theme.colorScheme.primary,
            size: 20,
          ),
        ),
        SizedBox(width: 3.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                alertData['foodType'] as String,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 0.5.h),
              Text(
                '${alertData['quantity']} meals available',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
          decoration: BoxDecoration(
            color: theme.colorScheme.secondary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            '${alertData['quantity']}',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.secondary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLocationAndDistance(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        CustomIconWidget(
          iconName: 'location_on',
          color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          size: 16,
        ),
        SizedBox(width: 2.w),
        Expanded(
          child: Text(
            alertData['location'] as String,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
          decoration: BoxDecoration(
            color: theme.colorScheme.tertiary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomIconWidget(
                iconName: 'near_me',
                color: theme.colorScheme.tertiary,
                size: 12,
              ),
              SizedBox(width: 1.w),
              Text(
                '${alertData['distance']} km',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.tertiary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildExpirationAndFreshness(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Expanded(
          child: Row(
            children: [
              CustomIconWidget(
                iconName: 'schedule',
                color: _getExpirationColor(context),
                size: 16,
              ),
              SizedBox(width: 2.w),
              Text(
                'Expires in ${alertData['expirationHours']}h',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: _getExpirationColor(context),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
          decoration: BoxDecoration(
            color: _getFreshnessColor(context).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomIconWidget(
                iconName: 'eco',
                color: _getFreshnessColor(context),
                size: 12,
              ),
              SizedBox(width: 1.w),
              Text(
                '${((alertData['freshnessScore'] as double) * 100).toInt()}% Fresh',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: _getFreshnessColor(context),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: ElevatedButton(
            onPressed: onAcceptDonation,
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
              padding: EdgeInsets.symmetric(vertical: 1.5.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CustomIconWidget(
                  iconName: 'check_circle',
                  color: theme.colorScheme.onPrimary,
                  size: 16,
                ),
                SizedBox(width: 2.w),
                Text(
                  'Accept',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: theme.colorScheme.onPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(width: 3.w),
        Expanded(
          child: OutlinedButton(
            onPressed: onViewDetails,
            style: OutlinedButton.styleFrom(
              foregroundColor: theme.colorScheme.primary,
              side: BorderSide(color: theme.colorScheme.primary),
              padding: EdgeInsets.symmetric(vertical: 1.5.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Details',
              style: theme.textTheme.labelLarge?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Color _getUrgencyColor(BuildContext context) {
    final theme = Theme.of(context);
    switch ((alertData['urgency'] as String).toLowerCase()) {
      case 'urgent':
        return theme.colorScheme.error;
      case 'high':
        return AppTheme.warningLight;
      case 'medium':
        return theme.colorScheme.secondary;
      default:
        return theme.colorScheme.primary;
    }
  }

  Color _getExpirationColor(BuildContext context) {
    final theme = Theme.of(context);
    final hours = alertData['expirationHours'] as int;
    if (hours <= 2) return theme.colorScheme.error;
    if (hours <= 6) return AppTheme.warningLight;
    return theme.colorScheme.primary;
  }

  Color _getFreshnessColor(BuildContext context) {
    final theme = Theme.of(context);
    final score = alertData['freshnessScore'] as double;
    if (score >= 0.8) return AppTheme.successLight;
    if (score >= 0.6) return AppTheme.warningLight;
    return theme.colorScheme.error;
  }

  String _getFoodIcon(String foodType) {
    switch (foodType.toLowerCase()) {
      case 'prepared meals':
        return 'restaurant';
      case 'fresh produce':
        return 'eco';
      case 'bakery items':
        return 'cake';
      case 'dairy products':
        return 'local_drink';
      case 'packaged goods':
        return 'inventory_2';
      default:
        return 'restaurant_menu';
    }
  }
}
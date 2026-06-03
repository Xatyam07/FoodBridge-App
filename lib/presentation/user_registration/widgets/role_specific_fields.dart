import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

enum UserRole { provider, ngo, volunteer }

class RoleSpecificFields extends StatelessWidget {
  final UserRole selectedRole;
  final TextEditingController businessNameController;
  final TextEditingController certificationController;
  final TextEditingController organizationController;
  final TextEditingController serviceAreaController;
  final String? selectedAvailability;
  final String? selectedTransportation;
  final Function(String?) onAvailabilityChanged;
  final Function(String?) onTransportationChanged;

  const RoleSpecificFields({
    super.key,
    required this.selectedRole,
    required this.businessNameController,
    required this.certificationController,
    required this.organizationController,
    required this.serviceAreaController,
    this.selectedAvailability,
    this.selectedTransportation,
    required this.onAvailabilityChanged,
    required this.onTransportationChanged,
  });

  @override
  Widget build(BuildContext context) {
    switch (selectedRole) {
      case UserRole.provider:
        return _buildProviderFields(context);
      case UserRole.ngo:
        return _buildNgoFields(context);
      case UserRole.volunteer:
        return _buildVolunteerFields(context);
    }
  }

  Widget _buildProviderFields(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 3.h),
        Text(
          'Business Information',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.primary,
          ),
        ),
        SizedBox(height: 2.h),
        TextFormField(
          controller: businessNameController,
          decoration: InputDecoration(
            labelText: 'Business Name *',
            hintText: 'Enter your business name',
            prefixIcon: Padding(
              padding: EdgeInsets.all(3.w),
              child: CustomIconWidget(
                iconName: 'business',
                color: theme.colorScheme.primary,
                size: 5.w,
              ),
            ),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Business name is required';
            }
            return null;
          },
        ),
        SizedBox(height: 2.h),
        TextFormField(
          controller: certificationController,
          decoration: InputDecoration(
            labelText: 'Food Safety Certification',
            hintText: 'Enter certification details (optional)',
            prefixIcon: Padding(
              padding: EdgeInsets.all(3.w),
              child: CustomIconWidget(
                iconName: 'verified',
                color: theme.colorScheme.primary,
                size: 5.w,
              ),
            ),
          ),
          maxLines: 2,
        ),
        SizedBox(height: 1.h),
        Text(
          'Food safety certifications help build trust with NGOs and volunteers',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }

  Widget _buildNgoFields(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 3.h),
        Text(
          'Organization Details',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.primary,
          ),
        ),
        SizedBox(height: 2.h),
        TextFormField(
          controller: organizationController,
          decoration: InputDecoration(
            labelText: 'Organization Name *',
            hintText: 'Enter your organization name',
            prefixIcon: Padding(
              padding: EdgeInsets.all(3.w),
              child: CustomIconWidget(
                iconName: 'account_balance',
                color: theme.colorScheme.primary,
                size: 5.w,
              ),
            ),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Organization name is required';
            }
            return null;
          },
        ),
        SizedBox(height: 2.h),
        TextFormField(
          controller: serviceAreaController,
          decoration: InputDecoration(
            labelText: 'Service Areas *',
            hintText: 'Areas you serve (e.g., Downtown, East Side)',
            prefixIcon: Padding(
              padding: EdgeInsets.all(3.w),
              child: CustomIconWidget(
                iconName: 'location_city',
                color: theme.colorScheme.primary,
                size: 5.w,
              ),
            ),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Service areas are required';
            }
            return null;
          },
          maxLines: 2,
        ),
        SizedBox(height: 1.h),
        Text(
          'Specify the geographic areas where your organization provides services',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }

  Widget _buildVolunteerFields(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 3.h),
        Text(
          'Volunteer Preferences',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.primary,
          ),
        ),
        SizedBox(height: 2.h),
        Text(
          'Availability *',
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 1.h),
        DropdownButtonFormField<String>(
          value: selectedAvailability,
          decoration: InputDecoration(
            hintText: 'Select your availability',
            prefixIcon: Padding(
              padding: EdgeInsets.all(3.w),
              child: CustomIconWidget(
                iconName: 'schedule',
                color: theme.colorScheme.primary,
                size: 5.w,
              ),
            ),
          ),
          items: const [
            DropdownMenuItem(value: 'weekdays', child: Text('Weekdays')),
            DropdownMenuItem(value: 'weekends', child: Text('Weekends')),
            DropdownMenuItem(value: 'evenings', child: Text('Evenings')),
            DropdownMenuItem(value: 'flexible', child: Text('Flexible')),
            DropdownMenuItem(
                value: 'emergency_only', child: Text('Emergency Only')),
          ],
          onChanged: onAvailabilityChanged,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please select your availability';
            }
            return null;
          },
        ),
        SizedBox(height: 2.h),
        Text(
          'Transportation Method *',
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 1.h),
        DropdownButtonFormField<String>(
          value: selectedTransportation,
          decoration: InputDecoration(
            hintText: 'Select transportation method',
            prefixIcon: Padding(
              padding: EdgeInsets.all(3.w),
              child: CustomIconWidget(
                iconName: 'directions_car',
                color: theme.colorScheme.primary,
                size: 5.w,
              ),
            ),
          ),
          items: const [
            DropdownMenuItem(value: 'car', child: Text('Personal Car')),
            DropdownMenuItem(value: 'bike', child: Text('Bicycle')),
            DropdownMenuItem(value: 'motorcycle', child: Text('Motorcycle')),
            DropdownMenuItem(
                value: 'public_transport', child: Text('Public Transport')),
            DropdownMenuItem(value: 'walking', child: Text('Walking')),
          ],
          onChanged: onTransportationChanged,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please select transportation method';
            }
            return null;
          },
        ),
        SizedBox(height: 1.h),
        Text(
          'This helps us assign appropriate pickup and delivery tasks',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }
}

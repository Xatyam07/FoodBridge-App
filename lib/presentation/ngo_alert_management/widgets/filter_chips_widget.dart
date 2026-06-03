import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class FilterChipsWidget extends StatefulWidget {
  final List<String> selectedFilters;
  final ValueChanged<List<String>>? onFiltersChanged;

  const FilterChipsWidget({
    super.key,
    required this.selectedFilters,
    this.onFiltersChanged,
  });

  @override
  State<FilterChipsWidget> createState() => _FilterChipsWidgetState();
}

class _FilterChipsWidgetState extends State<FilterChipsWidget> {
  final List<Map<String, dynamic>> _filterOptions = [
    {'label': 'Distance', 'icon': 'near_me', 'count': 12},
    {'label': 'Food Type', 'icon': 'restaurant_menu', 'count': 8},
    {'label': 'Quantity', 'icon': 'inventory_2', 'count': 15},
    {'label': 'Expiration', 'icon': 'schedule', 'count': 6},
    {'label': 'Fresh Only', 'icon': 'eco', 'count': 9},
    {'label': 'Verified', 'icon': 'verified', 'count': 11},
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      height: 6.h,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 4.w),
        itemCount: _filterOptions.length,
        itemBuilder: (context, index) {
          final filter = _filterOptions[index];
          final isSelected = widget.selectedFilters.contains(filter['label']);

          return Container(
            margin: EdgeInsets.only(right: 2.w),
            child: FilterChip(
              selected: isSelected,
              onSelected: (selected) =>
                  _toggleFilter(filter['label'] as String),
              backgroundColor: theme.colorScheme.surface,
              selectedColor: theme.colorScheme.primary.withValues(alpha: 0.1),
              checkmarkColor: theme.colorScheme.primary,
              side: BorderSide(
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.outline.withValues(alpha: 0.3),
                width: isSelected ? 1.5 : 1,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              avatar: isSelected
                  ? null
                  : CustomIconWidget(
                      iconName: filter['icon'] as String,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      size: 16,
                    ),
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isSelected) ...[
                    CustomIconWidget(
                      iconName: filter['icon'] as String,
                      color: theme.colorScheme.primary,
                      size: 14,
                    ),
                    SizedBox(width: 1.w),
                  ],
                  Text(
                    filter['label'] as String,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: isSelected
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurface.withValues(alpha: 0.7),
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                  if (isSelected && filter['count'] != null) ...[
                    SizedBox(width: 1.w),
                    Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 1.5.w, vertical: 0.2.h),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${filter['count']}',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onPrimary,
                          fontWeight: FontWeight.w600,
                          fontSize: 10.sp,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _toggleFilter(String filterLabel) {
    final updatedFilters = List<String>.from(widget.selectedFilters);

    if (updatedFilters.contains(filterLabel)) {
      updatedFilters.remove(filterLabel);
    } else {
      updatedFilters.add(filterLabel);
    }

    widget.onFiltersChanged?.call(updatedFilters);
  }
}

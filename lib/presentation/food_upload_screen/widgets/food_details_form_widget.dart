import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class FoodDetailsFormWidget extends StatefulWidget {
  final Function(Map<String, dynamic>) onFormChanged;

  const FoodDetailsFormWidget({
    super.key,
    required this.onFormChanged,
  });

  @override
  State<FoodDetailsFormWidget> createState() => _FoodDetailsFormWidgetState();
}

class _FoodDetailsFormWidgetState extends State<FoodDetailsFormWidget> {
  final _formKey = GlobalKey<FormState>();
  final _categoryController = TextEditingController();
  final _quantityController = TextEditingController();
  final _notesController = TextEditingController();
  final _locationController = TextEditingController();

  String _selectedCategory = '';
  String _selectedUnit = 'servings';
  DateTime? _expirationDate;
  int _conditionRating = 5;
  TimeOfDay? _availabilityStart;
  TimeOfDay? _availabilityEnd;
  bool _isIoTConnected = false;

  final List<String> _foodCategories = [
    'Prepared Meals',
    'Fresh Produce',
    'Dairy Products',
    'Baked Goods',
    'Canned Foods',
    'Frozen Items',
    'Beverages',
    'Snacks',
    'Meat & Poultry',
    'Seafood',
    'Grains & Cereals',
    'Other',
  ];

  final List<String> _units = [
    'servings',
    'pounds',
    'kilograms',
    'boxes',
    'bags',
    'containers',
    'pieces',
    'liters',
    'gallons',
  ];

  final List<Map<String, dynamic>> _conditionLevels = [
    {'rating': 5, 'label': 'Excellent', 'icon': 'star', 'color': Colors.green},
    {
      'rating': 4,
      'label': 'Very Good',
      'icon': 'thumb_up',
      'color': Colors.lightGreen
    },
    {
      'rating': 3,
      'label': 'Good',
      'icon': 'check_circle',
      'color': Colors.orange
    },
    {
      'rating': 2,
      'label': 'Fair',
      'icon': 'warning',
      'color': Colors.deepOrange
    },
    {'rating': 1, 'label': 'Poor', 'icon': 'error', 'color': Colors.red},
  ];

  @override
  void initState() {
    super.initState();
    _locationController.text = '123 Main Street, City, State 12345';
    _availabilityStart = const TimeOfDay(hour: 9, minute: 0);
    _availabilityEnd = const TimeOfDay(hour: 17, minute: 0);
    _updateFormData();
  }

  @override
  void dispose() {
    _categoryController.dispose();
    _quantityController.dispose();
    _notesController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  void _updateFormData() {
    final formData = {
      'category': _selectedCategory,
      'quantity': _quantityController.text,
      'unit': _selectedUnit,
      'expirationDate': _expirationDate?.toIso8601String(),
      'condition': _conditionRating,
      'notes': _notesController.text,
      'location': _locationController.text,
      'availabilityStart': _availabilityStart != null
          ? '${_availabilityStart!.hour}:${_availabilityStart!.minute.toString().padLeft(2, '0')}'
          : null,
      'availabilityEnd': _availabilityEnd != null
          ? '${_availabilityEnd!.hour}:${_availabilityEnd!.minute.toString().padLeft(2, '0')}'
          : null,
      'iotConnected': _isIoTConnected,
    };
    widget.onFormChanged(formData);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCategorySection(theme),
          SizedBox(height: 3.h),
          _buildQuantitySection(theme),
          SizedBox(height: 3.h),
          _buildExpirationSection(theme),
          SizedBox(height: 3.h),
          _buildConditionSection(theme),
          SizedBox(height: 3.h),
          _buildNotesSection(theme),
          SizedBox(height: 3.h),
          _buildIoTSection(theme),
          SizedBox(height: 3.h),
          _buildLocationSection(theme),
          SizedBox(height: 3.h),
          _buildAvailabilitySection(theme),
        ],
      ),
    );
  }

  Widget _buildCategorySection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Food Category',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 1.h),
        DropdownButtonFormField<String>(
          value: _selectedCategory.isEmpty ? null : _selectedCategory,
          decoration: InputDecoration(
            hintText: 'Select food category',
            prefixIcon: CustomIconWidget(
              iconName: 'restaurant_menu',
              size: 20,
              color: theme.colorScheme.primary,
            ),
          ),
          items: _foodCategories.map((category) {
            return DropdownMenuItem(
              value: category,
              child: Text(category),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedCategory = value ?? '';
              _categoryController.text = value ?? '';
            });
            _updateFormData();
          },
          validator: (value) {
            return value == null || value.isEmpty
                ? 'Please select a category'
                : null;
          },
        ),
      ],
    );
  }

  Widget _buildQuantitySection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quantity',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 1.h),
        Row(
          children: [
            Expanded(
              flex: 2,
              child: TextFormField(
                controller: _quantityController,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                ],
                decoration: InputDecoration(
                  hintText: 'Enter quantity',
                  prefixIcon: CustomIconWidget(
                    iconName: 'scale',
                    size: 20,
                    color: theme.colorScheme.primary,
                  ),
                ),
                onChanged: (value) => _updateFormData(),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Required';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Invalid number';
                  }
                  return null;
                },
              ),
            ),
            SizedBox(width: 2.w),
            Expanded(
              flex: 1,
              child: DropdownButtonFormField<String>(
                value: _selectedUnit,
                decoration: const InputDecoration(
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                ),
                items: _units.map((unit) {
                  return DropdownMenuItem(
                    value: unit,
                    child: Text(unit),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedUnit = value ?? 'servings';
                  });
                  _updateFormData();
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildExpirationSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Expiration Date',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 1.h),
        InkWell(
          onTap: () => _selectExpirationDate(context),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              border: Border.all(color: theme.colorScheme.outline),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                CustomIconWidget(
                  iconName: 'calendar_today',
                  size: 20,
                  color: theme.colorScheme.primary,
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: Text(
                    _expirationDate != null
                        ? '${_expirationDate!.month}/${_expirationDate!.day}/${_expirationDate!.year}'
                        : 'Select expiration date',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: _expirationDate != null
                          ? theme.colorScheme.onSurface
                          : theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ),
                CustomIconWidget(
                  iconName: 'arrow_drop_down',
                  size: 24,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildConditionSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Current Condition',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 1.h),
        Container(
          padding: EdgeInsets.all(2.w),
          decoration: BoxDecoration(
            border: Border.all(
                color: theme.colorScheme.outline.withValues(alpha: 0.3)),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: _conditionLevels.map((condition) {
              final isSelected = _conditionRating == condition['rating'];
              return GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  setState(() {
                    _conditionRating = condition['rating'];
                  });
                  _updateFormData();
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 2.h),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? theme.colorScheme.primary.withValues(alpha: 0.1)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSelected
                          ? theme.colorScheme.primary
                          : Colors.transparent,
                    ),
                  ),
                  child: Row(
                    children: [
                      CustomIconWidget(
                        iconName: condition['icon'],
                        size: 24,
                        color: isSelected
                            ? theme.colorScheme.primary
                            : condition['color'],
                      ),
                      SizedBox(width: 3.w),
                      Expanded(
                        child: Text(
                          condition['label'],
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight:
                                isSelected ? FontWeight.w600 : FontWeight.w400,
                            color: isSelected
                                ? theme.colorScheme.primary
                                : theme.colorScheme.onSurface,
                          ),
                        ),
                      ),
                      if (isSelected)
                        CustomIconWidget(
                          iconName: 'check_circle',
                          size: 20,
                          color: theme.colorScheme.primary,
                        ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildNotesSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Additional Notes (Optional)',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 1.h),
        TextFormField(
          controller: _notesController,
          maxLines: 3,
          decoration: InputDecoration(
            hintText:
                'Add preparation details, special handling requirements, or other notes...',
            prefixIcon: Padding(
              padding: const EdgeInsets.only(bottom: 40),
              child: CustomIconWidget(
                iconName: 'notes',
                size: 20,
                color: theme.colorScheme.primary,
              ),
            ),
          ),
          onChanged: (value) => _updateFormData(),
        ),
      ],
    );
  }

  Widget _buildIoTSection(ThemeData theme) {
    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CustomIconWidget(
                iconName: 'sensors',
                size: 24,
                color: theme.colorScheme.primary,
              ),
              SizedBox(width: 2.w),
              Expanded(
                child: Text(
                  'IoT Sensor Pairing',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Switch(
                value: _isIoTConnected,
                onChanged: (value) {
                  setState(() {
                    _isIoTConnected = value;
                  });
                  _updateFormData();
                },
              ),
            ],
          ),
          SizedBox(height: 1.h),
          Text(
            _isIoTConnected
                ? 'Temperature and humidity sensors connected for automated freshness tracking'
                : 'Connect Bluetooth sensors for real-time freshness monitoring',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          if (!_isIoTConnected) ...[
            SizedBox(height: 2.h),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  // Simulate IoT pairing
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Searching for nearby sensors...'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
                icon: CustomIconWidget(
                  iconName: 'bluetooth',
                  size: 18,
                  color: theme.colorScheme.primary,
                ),
                label: const Text('Pair Sensors'),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLocationSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Pickup Location',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 1.h),
        TextFormField(
          controller: _locationController,
          decoration: InputDecoration(
            hintText: 'Enter pickup address',
            prefixIcon: CustomIconWidget(
              iconName: 'location_on',
              size: 20,
              color: theme.colorScheme.primary,
            ),
            suffixIcon: IconButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Using current location...'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              icon: CustomIconWidget(
                iconName: 'my_location',
                size: 20,
                color: theme.colorScheme.primary,
              ),
            ),
          ),
          onChanged: (value) => _updateFormData(),
          validator: (value) {
            return value == null || value.isEmpty
                ? 'Please enter pickup location'
                : null;
          },
        ),
      ],
    );
  }

  Widget _buildAvailabilitySection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Availability Window',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 1.h),
        Row(
          children: [
            Expanded(
              child: InkWell(
                onTap: () => _selectTime(context, true),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  decoration: BoxDecoration(
                    border: Border.all(color: theme.colorScheme.outline),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      CustomIconWidget(
                        iconName: 'access_time',
                        size: 20,
                        color: theme.colorScheme.primary,
                      ),
                      SizedBox(width: 2.w),
                      Expanded(
                        child: Text(
                          _availabilityStart != null
                              ? _availabilityStart!.format(context)
                              : 'Start time',
                          style: theme.textTheme.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(width: 2.w),
            Text(
              'to',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
            SizedBox(width: 2.w),
            Expanded(
              child: InkWell(
                onTap: () => _selectTime(context, false),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  decoration: BoxDecoration(
                    border: Border.all(color: theme.colorScheme.outline),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      CustomIconWidget(
                        iconName: 'access_time',
                        size: 20,
                        color: theme.colorScheme.primary,
                      ),
                      SizedBox(width: 2.w),
                      Expanded(
                        child: Text(
                          _availabilityEnd != null
                              ? _availabilityEnd!.format(context)
                              : 'End time',
                          style: theme.textTheme.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _selectExpirationDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate:
          _expirationDate ?? DateTime.now().add(const Duration(days: 3)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null && picked != _expirationDate) {
      setState(() {
        _expirationDate = picked;
      });
      _updateFormData();
    }
  }

  Future<void> _selectTime(BuildContext context, bool isStartTime) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isStartTime
          ? (_availabilityStart ?? const TimeOfDay(hour: 9, minute: 0))
          : (_availabilityEnd ?? const TimeOfDay(hour: 17, minute: 0)),
    );

    if (picked != null) {
      setState(() {
        if (isStartTime) {
          _availabilityStart = picked;
        } else {
          _availabilityEnd = picked;
        }
      });
      _updateFormData();
    }
  }

  bool validateForm() {
    return _formKey.currentState?.validate() ?? false;
  }
}

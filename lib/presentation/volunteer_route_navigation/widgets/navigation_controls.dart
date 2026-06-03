import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class NavigationControls extends StatefulWidget {
  final Map<String, dynamic> currentStop;
  final bool isVoiceEnabled;
  final VoidCallback onNextStop;
  final VoidCallback onCallContact;
  final VoidCallback onMarkComplete;
  final VoidCallback onReportIssue;
  final VoidCallback onToggleVoice;

  const NavigationControls({
    super.key,
    required this.currentStop,
    required this.isVoiceEnabled,
    required this.onNextStop,
    required this.onCallContact,
    required this.onMarkComplete,
    required this.onReportIssue,
    required this.onToggleVoice,
  });

  @override
  State<NavigationControls> createState() => _NavigationControlsState();
}

class _NavigationControlsState extends State<NavigationControls>
    with TickerProviderStateMixin {
  late AnimationController _voiceController;
  late Animation<double> _voiceAnimation;

  @override
  void initState() {
    super.initState();
    _voiceController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _voiceAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _voiceController,
      curve: Curves.easeInOut,
    ));

    if (widget.isVoiceEnabled) {
      _voiceController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(NavigationControls oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isVoiceEnabled != oldWidget.isVoiceEnabled) {
      if (widget.isVoiceEnabled) {
        _voiceController.repeat(reverse: true);
      } else {
        _voiceController.stop();
        _voiceController.reset();
      }
    }
  }

  @override
  void dispose() {
    _voiceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withValues(alpha: 0.1),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildCurrentStopInfo(theme),
            SizedBox(height: 3.h),
            _buildActionButtons(theme),
            SizedBox(height: 2.h),
            _buildNavigationButton(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentStopInfo(ThemeData theme) {
    final isPickup = widget.currentStop['type'] == 'pickup';

    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(2.w),
            decoration: BoxDecoration(
              color: isPickup ? Colors.blue : Colors.green,
              borderRadius: BorderRadius.circular(8),
            ),
            child: CustomIconWidget(
              iconName: isPickup ? 'restaurant' : 'delivery_dining',
              color: Colors.white,
              size: 20,
            ),
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Current Stop',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
                Text(
                  widget.currentStop['name'] as String,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 0.5.h),
                Row(
                  children: [
                    Text(
                      isPickup ? 'Pickup' : 'Delivery',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: isPickup ? Colors.blue : Colors.green,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(width: 2.w),
                    Text(
                      '•',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color:
                            theme.colorScheme.onSurface.withValues(alpha: 0.4),
                      ),
                    ),
                    SizedBox(width: 2.w),
                    Text(
                      '${widget.currentStop['quantity']} meals',
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          AnimatedBuilder(
            animation: _voiceAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: widget.isVoiceEnabled ? _voiceAnimation.value : 1.0,
                child: GestureDetector(
                  onTap: widget.onToggleVoice,
                  child: Container(
                    padding: EdgeInsets.all(2.w),
                    decoration: BoxDecoration(
                      color: widget.isVoiceEnabled
                          ? theme.colorScheme.primary
                          : theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    child: CustomIconWidget(
                      iconName:
                          widget.isVoiceEnabled ? 'volume_up' : 'volume_off',
                      color: widget.isVoiceEnabled
                          ? theme.colorScheme.onPrimary
                          : theme.colorScheme.primary,
                      size: 20,
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(ThemeData theme) {
    return Row(
      children: [
        Expanded(
          child: _buildActionButton(
            theme,
            'Call Contact',
            'phone',
            theme.colorScheme.primary,
            widget.onCallContact,
          ),
        ),
        SizedBox(width: 2.w),
        Expanded(
          child: _buildActionButton(
            theme,
            'Mark Complete',
            'check_circle',
            Colors.green,
            widget.onMarkComplete,
          ),
        ),
        SizedBox(width: 2.w),
        Expanded(
          child: _buildActionButton(
            theme,
            'Report Issue',
            'report_problem',
            Colors.orange,
            widget.onReportIssue,
          ),
        ),
        SizedBox(width: 2.w),
        _buildCameraButton(theme),
      ],
    );
  }

  Widget _buildActionButton(
    ThemeData theme,
    String label,
    String iconName,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 2.h, horizontal: 2.w),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withValues(alpha: 0.3),
          ),
        ),
        child: Column(
          children: [
            CustomIconWidget(
              iconName: iconName,
              color: color,
              size: 24,
            ),
            SizedBox(height: 1.h),
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: color,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCameraButton(ThemeData theme) {
    return GestureDetector(
      onTap: () => _showCameraOptions(context, theme),
      child: Container(
        padding: EdgeInsets.all(3.w),
        decoration: BoxDecoration(
          color: theme.colorScheme.secondary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: theme.colorScheme.secondary.withValues(alpha: 0.3),
          ),
        ),
        child: CustomIconWidget(
          iconName: 'camera_alt',
          color: theme.colorScheme.secondary,
          size: 24,
        ),
      ),
    );
  }

  Widget _buildNavigationButton(ThemeData theme) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: widget.onNextStop,
        style: ElevatedButton.styleFrom(
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: theme.colorScheme.onPrimary,
          padding: EdgeInsets.symmetric(vertical: 2.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomIconWidget(
              iconName: 'navigation',
              color: theme.colorScheme.onPrimary,
              size: 20,
            ),
            SizedBox(width: 2.w),
            Text(
              'Next Stop',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCameraOptions(BuildContext context, ThemeData theme) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: EdgeInsets.symmetric(vertical: 2.h),
                decoration: BoxDecoration(
                  color: theme.colorScheme.outline.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(4.w),
                child: Column(
                  children: [
                    Text(
                      'Delivery Confirmation',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 3.h),
                    ListTile(
                      leading: Container(
                        padding: EdgeInsets.all(2.w),
                        decoration: BoxDecoration(
                          color:
                              theme.colorScheme.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: CustomIconWidget(
                          iconName: 'camera_alt',
                          color: theme.colorScheme.primary,
                          size: 24,
                        ),
                      ),
                      title: const Text('Take Photo'),
                      subtitle: const Text('Capture delivery confirmation'),
                      onTap: () {
                        Navigator.pop(context);
                        // Handle camera capture
                      },
                    ),
                    ListTile(
                      leading: Container(
                        padding: EdgeInsets.all(2.w),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.secondary
                              .withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: CustomIconWidget(
                          iconName: 'photo_library',
                          color: theme.colorScheme.secondary,
                          size: 24,
                        ),
                      ),
                      title: const Text('Choose from Gallery'),
                      subtitle: const Text('Select existing photo'),
                      onTap: () {
                        Navigator.pop(context);
                        // Handle gallery selection
                      },
                    ),
                    SizedBox(height: 2.h),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

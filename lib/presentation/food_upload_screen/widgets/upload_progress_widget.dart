import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class UploadProgressWidget extends StatefulWidget {
  final bool isUploading;
  final double progress;
  final String currentStep;
  final VoidCallback? onCancel;

  const UploadProgressWidget({
    super.key,
    required this.isUploading,
    required this.progress,
    required this.currentStep,
    this.onCancel,
  });

  @override
  State<UploadProgressWidget> createState() => _UploadProgressWidgetState();
}

class _UploadProgressWidgetState extends State<UploadProgressWidget>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
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

    if (widget.isUploading) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(UploadProgressWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isUploading && !oldWidget.isUploading) {
      _pulseController.repeat(reverse: true);
    } else if (!widget.isUploading && oldWidget.isUploading) {
      _pulseController.stop();
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

    if (!widget.isUploading) {
      return const SizedBox.shrink();
    }

    return Container(
      color: theme.colorScheme.surface.withValues(alpha: 0.95),
      child: Center(
        child: Container(
          width: 85.w,
          padding: EdgeInsets.all(6.w),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: theme.colorScheme.shadow.withValues(alpha: 0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildProgressHeader(theme),
              SizedBox(height: 4.h),
              _buildProgressIndicator(theme),
              SizedBox(height: 3.h),
              _buildProgressSteps(theme),
              SizedBox(height: 4.h),
              _buildCancelButton(theme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressHeader(ThemeData theme) {
    return Column(
      children: [
        AnimatedBuilder(
          animation: _pulseAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _pulseAnimation.value,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: CustomIconWidget(
                    iconName: 'cloud_upload',
                    size: 40,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
            );
          },
        ),
        SizedBox(height: 2.h),
        Text(
          'Uploading Food Item',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
        SizedBox(height: 1.h),
        Text(
          'AI is analyzing your food for optimal distribution',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildProgressIndicator(ThemeData theme) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 120,
              height: 120,
              child: CircularProgressIndicator(
                value: widget.progress,
                strokeWidth: 8,
                backgroundColor:
                    theme.colorScheme.outline.withValues(alpha: 0.2),
                valueColor:
                    AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${(widget.progress * 100).toInt()}%',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.primary,
                  ),
                ),
                Text(
                  'Complete',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ],
        ),
        SizedBox(height: 2.h),
        Text(
          widget.currentStep,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
            color: theme.colorScheme.primary,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildProgressSteps(ThemeData theme) {
    final steps = [
      {'title': 'Image Analysis', 'description': 'AI analyzing food quality'},
      {
        'title': 'Blockchain Logging',
        'description': 'Securing transaction data'
      },
      {'title': 'NGO Matching', 'description': 'Finding nearby organizations'},
      {
        'title': 'Notifications',
        'description': 'Alerting potential recipients'
      },
    ];

    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Processing Steps',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
          SizedBox(height: 2.h),
          ...steps.asMap().entries.map((entry) {
            final index = entry.key;
            final step = entry.value;
            final isCompleted = widget.progress > (index + 1) / steps.length;
            final isCurrent = widget.progress >= index / steps.length &&
                widget.progress < (index + 1) / steps.length;

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: isCompleted
                          ? theme.colorScheme.primary
                          : isCurrent
                              ? theme.colorScheme.primary.withValues(alpha: 0.2)
                              : theme.colorScheme.outline
                                  .withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: isCompleted
                          ? CustomIconWidget(
                              iconName: 'check',
                              size: 14,
                              color: theme.colorScheme.onPrimary,
                            )
                          : isCurrent
                              ? SizedBox(
                                  width: 12,
                                  height: 12,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      theme.colorScheme.primary,
                                    ),
                                  ),
                                )
                              : Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.outline
                                        .withValues(alpha: 0.4),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                    ),
                  ),
                  SizedBox(width: 3.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          step['title']!,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight:
                                isCurrent ? FontWeight.w600 : FontWeight.w400,
                            color: isCompleted || isCurrent
                                ? theme.colorScheme.onSurface
                                : theme.colorScheme.onSurface
                                    .withValues(alpha: 0.6),
                          ),
                        ),
                        Text(
                          step['description']!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface
                                .withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildCancelButton(ThemeData theme) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: widget.onCancel,
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: theme.colorScheme.error),
          foregroundColor: theme.colorScheme.error,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomIconWidget(
              iconName: 'cancel',
              size: 18,
              color: theme.colorScheme.error,
            ),
            SizedBox(width: 2.w),
            const Text('Cancel Upload'),
          ],
        ),
      ),
    );
  }
}

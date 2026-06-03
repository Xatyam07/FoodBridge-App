import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class PasswordStrengthIndicator extends StatelessWidget {
  final String password;

  const PasswordStrengthIndicator({
    super.key,
    required this.password,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final strength = _calculatePasswordStrength(password);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 1.h),
        Row(
          children: [
            Expanded(
              child: Container(
                height: 4,
                decoration: BoxDecoration(
                  color: theme.colorScheme.outline.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: strength.progress,
                  child: Container(
                    decoration: BoxDecoration(
                      color: strength.color,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(width: 3.w),
            Text(
              strength.label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: strength.color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        if (password.isNotEmpty) ...[
          SizedBox(height: 1.h),
          Wrap(
            spacing: 2.w,
            runSpacing: 0.5.h,
            children: _getPasswordRequirements(password, theme),
          ),
        ],
      ],
    );
  }

  PasswordStrength _calculatePasswordStrength(String password) {
    if (password.isEmpty) {
      return PasswordStrength(
        progress: 0.0,
        label: 'Enter password',
        color: Colors.grey,
      );
    }

    int score = 0;

    // Length check
    if (password.length >= 8) score++;
    if (password.length >= 12) score++;

    // Character variety checks
    if (password.contains(RegExp(r'[a-z]'))) score++;
    if (password.contains(RegExp(r'[A-Z]'))) score++;
    if (password.contains(RegExp(r'[0-9]'))) score++;
    if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) score++;

    switch (score) {
      case 0:
      case 1:
        return PasswordStrength(
          progress: 0.2,
          label: 'Very Weak',
          color: Colors.red,
        );
      case 2:
      case 3:
        return PasswordStrength(
          progress: 0.4,
          label: 'Weak',
          color: Colors.orange,
        );
      case 4:
        return PasswordStrength(
          progress: 0.6,
          label: 'Fair',
          color: Colors.yellow[700]!,
        );
      case 5:
        return PasswordStrength(
          progress: 0.8,
          label: 'Good',
          color: Colors.lightGreen,
        );
      default:
        return PasswordStrength(
          progress: 1.0,
          label: 'Strong',
          color: Colors.green,
        );
    }
  }

  List<Widget> _getPasswordRequirements(String password, ThemeData theme) {
    final requirements = [
      _RequirementCheck(
        text: '8+ characters',
        isMet: password.length >= 8,
      ),
      _RequirementCheck(
        text: 'Lowercase',
        isMet: password.contains(RegExp(r'[a-z]')),
      ),
      _RequirementCheck(
        text: 'Uppercase',
        isMet: password.contains(RegExp(r'[A-Z]')),
      ),
      _RequirementCheck(
        text: 'Number',
        isMet: password.contains(RegExp(r'[0-9]')),
      ),
      _RequirementCheck(
        text: 'Special char',
        isMet: password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]')),
      ),
    ];

    return requirements
        .map((req) => Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomIconWidget(
                  iconName:
                      req.isMet ? 'check_circle' : 'radio_button_unchecked',
                  color: req.isMet ? Colors.green : theme.colorScheme.outline,
                  size: 3.w,
                ),
                SizedBox(width: 1.w),
                Text(
                  req.text,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: req.isMet
                        ? Colors.green
                        : theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    fontSize: 10.sp,
                  ),
                ),
              ],
            ))
        .toList();
  }
}

class PasswordStrength {
  final double progress;
  final String label;
  final Color color;

  PasswordStrength({
    required this.progress,
    required this.label,
    required this.color,
  });
}

class _RequirementCheck {
  final String text;
  final bool isMet;

  _RequirementCheck({
    required this.text,
    required this.isMet,
  });
}

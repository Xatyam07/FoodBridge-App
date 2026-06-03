import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';
import 'package:google_fonts/google_fonts.dart'; // Add this import

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class SocialLoginWidget extends StatelessWidget {
  final bool isLoading;
  final Function(String provider) onSocialLogin;

  const SocialLoginWidget({
    super.key,
    required this.isLoading,
    required this.onSocialLogin,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        // Divider with "OR" text
        Row(
          children: [
            Expanded(
              child: Divider(
                color: theme.colorScheme.outline.withValues(alpha: 0.3),
                thickness: 1,
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              child: Text(
                'OR',
                style: GoogleFonts.inter(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w500,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ),
            Expanded(
              child: Divider(
                color: theme.colorScheme.outline.withValues(alpha: 0.3),
                thickness: 1,
              ),
            ),
          ],
        ),

        SizedBox(height: 3.h),

        // Social Login Buttons
        Row(
          children: [
            // Google Login
            Expanded(
              child: _SocialLoginButton(
                provider: 'Google',
                iconName: 'g_translate',
                backgroundColor: Colors.white,
                textColor: Colors.black87,
                borderColor: theme.colorScheme.outline.withValues(alpha: 0.3),
                isLoading: isLoading,
                onTap: () {
                  HapticFeedback.lightImpact();
                  onSocialLogin('google');
                },
              ),
            ),

            SizedBox(width: 3.w),

            // Apple Login (iOS style)
            Expanded(
              child: _SocialLoginButton(
                provider: 'Apple',
                iconName: 'apple',
                backgroundColor: Colors.black,
                textColor: Colors.white,
                borderColor: Colors.black,
                isLoading: isLoading,
                onTap: () {
                  HapticFeedback.lightImpact();
                  onSocialLogin('apple');
                },
              ),
            ),
          ],
        ),

        SizedBox(height: 2.h),

        // Social Login Info Text
        Text(
          'Secure authentication powered by blockchain verification',
          style: GoogleFonts.inter(
            fontSize: 11.sp,
            fontWeight: FontWeight.w400,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _SocialLoginButton extends StatelessWidget {
  final String provider;
  final String iconName;
  final Color backgroundColor;
  final Color textColor;
  final Color borderColor;
  final bool isLoading;
  final VoidCallback onTap;

  const _SocialLoginButton({
    required this.provider,
    required this.iconName,
    required this.backgroundColor,
    required this.textColor,
    required this.borderColor,
    required this.isLoading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 6.h,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLoading ? null : onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 3.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CustomIconWidget(
                  iconName: iconName,
                  color: textColor,
                  size: 18.sp,
                ),
                SizedBox(width: 2.w),
                Flexible(
                  child: Text(
                    provider,
                    style: GoogleFonts.inter(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                      color: textColor,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
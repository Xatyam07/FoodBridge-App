import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/custom_icon_widget.dart';

class LoginFormWidget extends StatefulWidget {
  final Function(String email, String password) onLogin;
  final bool isLoading;

  const LoginFormWidget({
    super.key,
    required this.onLogin,
    required this.isLoading,
  });

  @override
  State<LoginFormWidget> createState() => _LoginFormWidgetState();
}

class _LoginFormWidgetState extends State<LoginFormWidget> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isEmailValid = false;
  bool _isPasswordValid = false;

  @override
  void initState() {
    super.initState();
    _emailController.addListener(_validateEmail);
    _passwordController.addListener(_validatePassword);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _validateEmail() {
    final email = _emailController.text;
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    setState(() {
      _isEmailValid = emailRegex.hasMatch(email);
    });
  }

  void _validatePassword() {
    setState(() {
      _isPasswordValid = _passwordController.text.length >= 6;
    });
  }

  String? _validateEmailField(String? value) {
    if (value == null || value.isEmpty) {
      return 'Fresh credentials are required to access the food network';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Please provide a valid email to ensure food safety compliance';
    }
    return null;
  }

  String? _validatePasswordField(String? value) {
    if (value == null || value.isEmpty) {
      return 'Secure access code needed to protect food distribution data';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters for food safety standards';
    }
    return null;
  }

  void _handleLogin() {
    if (_formKey.currentState!.validate() &&
        _isEmailValid &&
        _isPasswordValid) {
      HapticFeedback.lightImpact();
      widget.onLogin(_emailController.text.trim(), _passwordController.text);
    }
  }

  Future<void> _handleForgotPassword() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      Fluttertoast.showToast(msg: "Enter your email");
      return;
    }
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      Fluttertoast.showToast(msg: "Password reset email sent!");
    } catch (e) {
      Fluttertoast.showToast(msg: "Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Email Field
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            enabled: !widget.isLoading,
            decoration: InputDecoration(
              labelText: 'Email Address',
              hintText: 'Enter your registered email',
              prefixIcon: Padding(
                padding: EdgeInsets.all(12.w),
                child: CustomIconWidget(
                  iconName: 'restaurant_menu',
                  color: _isEmailValid
                      ? AppTheme.lightTheme.colorScheme.primary
                      : theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  size: 20.sp,
                ),
              ),
              suffixIcon: _emailController.text.isNotEmpty
                  ? Padding(
                padding: EdgeInsets.all(12.w),
                child: CustomIconWidget(
                  iconName: _isEmailValid ? 'check_circle' : 'error',
                  color: _isEmailValid
                      ? AppTheme.lightTheme.colorScheme.primary
                      : theme.colorScheme.error,
                  size: 20.sp,
                ),
              )
                  : null,
            ),
            validator: _validateEmailField,
            onFieldSubmitted: (_) => FocusScope.of(context).nextFocus(),
          ),

          SizedBox(height: 3.h),

          // Password Field
          TextFormField(
            controller: _passwordController,
            obscureText: !_isPasswordVisible,
            textInputAction: TextInputAction.done,
            enabled: !widget.isLoading,
            decoration: InputDecoration(
              labelText: 'Password',
              hintText: 'Enter your secure password',
              prefixIcon: Padding(
                padding: EdgeInsets.all(12.w),
                child: CustomIconWidget(
                  iconName: 'lock',
                  color: _isPasswordValid
                      ? AppTheme.lightTheme.colorScheme.primary
                      : theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  size: 20.sp,
                ),
              ),
              suffixIcon: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_passwordController.text.isNotEmpty)
                    Padding(
                      padding: EdgeInsets.only(right: 4.w),
                      child: CustomIconWidget(
                        iconName: _isPasswordValid ? 'check_circle' : 'error',
                        color: _isPasswordValid
                            ? AppTheme.lightTheme.colorScheme.primary
                            : theme.colorScheme.error,
                        size: 20.sp,
                      ),
                    ),
                  IconButton(
                    icon: CustomIconWidget(
                      iconName:
                      _isPasswordVisible ? 'visibility' : 'visibility_off',
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      size: 20.sp,
                    ),
                    onPressed: widget.isLoading
                        ? null
                        : () {
                      setState(() {
                        _isPasswordVisible = !_isPasswordVisible;
                      });
                    },
                  ),
                ],
              ),
            ),
            validator: _validatePasswordField,
            onFieldSubmitted: (_) => _handleLogin(),
          ),

          SizedBox(height: 2.h),

          // Forgot Password Link with Firebase reset
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: widget.isLoading ? null : _handleForgotPassword,
              child: Text(
                'Forgot Password?',
                style: GoogleFonts.inter(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
          ),

          SizedBox(height: 4.h),

          // Login Button
          SizedBox(
            height: 6.h,
            child: ElevatedButton(
              onPressed:
              (_isEmailValid && _isPasswordValid && !widget.isLoading)
                  ? _handleLogin
                  : null,
              child: widget.isLoading
                  ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 20.sp,
                    height: 20.sp,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        theme.colorScheme.onPrimary,
                      ),
                    ),
                  ),
                  SizedBox(width: 3.w),
                  Text(
                    'Verifying...',
                    style: GoogleFonts.inter(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              )
                  : Text(
                'Login to FoodBridge',
                style: GoogleFonts.inter(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

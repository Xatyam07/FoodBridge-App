import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sizer/sizer.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/app_export.dart';
import '../../theme/app_theme.dart';
import '../../../widgets/custom_icon_widget.dart';
import './widgets/login_form_widget.dart';
import './widgets/social_login_widget.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  bool _isLoading = false;

  /// ✅ Correct Google Sign-In WITH Android clientId
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email'],
    clientId:
    '897007121549-oj0uufhid0ggcl9usgm6vqj0a7oeobae.apps.googleusercontent.com',
  );

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  /// ✅ Email login
  Future<void> _handleLogin(String email, String password) async {
    setState(() => _isLoading = true);
    try {
      final credential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email.trim(), password: password);

      Fluttertoast.showToast(msg: "Welcome ${credential.user!.email}");
      Navigator.pushReplacementNamed(context, '/provider-dashboard');
    } on FirebaseAuthException catch (e) {
      setState(() => _isLoading = false);
      Fluttertoast.showToast(msg: e.message ?? 'Login failed');
    }
  }

  /// ✅ Fully fixed Google Sign-In
  Future<void> _handleGoogleLogin() async {
    setState(() => _isLoading = true);

    try {
      // ✅ Clear any old sessions
      await _googleSignIn.signOut();

      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        setState(() => _isLoading = false);
        return;
      }

      final googleAuth = await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await FirebaseAuth.instance.signInWithCredential(credential);

      Fluttertoast.showToast(msg: "Google login successful!");
      Navigator.pushReplacementNamed(context, '/provider-dashboard');
    } catch (e) {
      setState(() => _isLoading = false);
      Fluttertoast.showToast(msg: "Google login failed: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 4.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 4.h),

              Center(
                child: Container(
                  width: 28.w,
                  height: 28.w,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: theme.colorScheme.primary.withOpacity(0.2),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: CustomIconWidget(
                    iconName: 'restaurant',
                    color: theme.colorScheme.primary,
                    size: 14.w,
                  ),
                ),
              ),

              SizedBox(height: 3.h),

              Text(
                'Welcome to FoodBridge',
                style: GoogleFonts.inter(
                  fontSize: 26.sp,
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ),

              SizedBox(height: 1.h),

              Text(
                'Connect. Share. Reduce Waste.',
                style: GoogleFonts.inter(
                  fontSize: 14.sp,
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
                textAlign: TextAlign.center,
              ),

              SizedBox(height: 5.h),

              FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: LoginFormWidget(
                    isLoading: _isLoading,
                    onLogin: _handleLogin,
                  ),
                ),
              ),

              SizedBox(height: 4.h),

              /// ✅ Google Login Button
              SocialLoginWidget(
                isLoading: _isLoading,
                onSocialLogin: (_) => _handleGoogleLogin(),
              ),

              SizedBox(height: 4.h),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'New to FoodBridge? ',
                    style: GoogleFonts.inter(
                      fontSize: 14.sp,
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                  GestureDetector(
                    onTap: _isLoading
                        ? null
                        : () {
                      HapticFeedback.lightImpact();
                      Navigator.pushNamed(context, '/user-registration');
                    },
                    child: Text(
                      'Sign Up',
                      style: GoogleFonts.inter(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.primary,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 6.h),
            ],
          ),
        ),
      ),
    );
  }
}

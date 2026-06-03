import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sizer/sizer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/app_export.dart';
import '../../widgets/custom_icon_widget.dart';
import './widgets/password_strength_indicator.dart';
import './widgets/profile_photo_picker.dart';
import './widgets/role_selection_card.dart';
import './widgets/role_specific_fields.dart';

class UserRegistration extends StatefulWidget {
  const UserRegistration({super.key});

  @override
  State<UserRegistration> createState() => _UserRegistrationState();
}

class _UserRegistrationState extends State<UserRegistration> {
  final _formKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();

  // Form controllers
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _businessNameController = TextEditingController();
  final _certificationController = TextEditingController();
  final _organizationController = TextEditingController();
  final _serviceAreaController = TextEditingController();

  // Form state
  UserRole? _selectedRole;
  bool _isPasswordVisible = false;
  bool _acceptTerms = false;
  bool _isLoading = false;
  XFile? _profileImage;
  String? _selectedAvailability;
  String? _selectedTransportation;
  bool _locationPermissionRequested = false;

  // Mock role data
  final List<Map<String, dynamic>> _roles = [
    {
      "id": "provider",
      "title": "Food Provider",
      "description":
      "Restaurant, grocery store, or catering business with surplus food",
      "icon": "restaurant",
    },
    {
      "id": "ngo",
      "title": "NGO Partner",
      "description":
      "Non-profit organization distributing food to communities in need",
      "icon": "volunteer_activism",
    },
    {
      "id": "volunteer",
      "title": "Volunteer",
      "description":
      "Individual helping with food pickup and delivery coordination",
      "icon": "people",
    },
  ];

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _businessNameController.dispose();
    _certificationController.dispose();
    _organizationController.dispose();
    _serviceAreaController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Create Account',
          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
        leading: IconButton(
          icon: CustomIconWidget(
            iconName: 'arrow_back_ios',
            color: theme.colorScheme.onSurface,
            size: 5.w,
          ),
          onPressed: _handleBackNavigation,
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            controller: _scrollController,
            padding: EdgeInsets.symmetric(horizontal: 5.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 2.h),
                _buildWelcomeSection(theme),
                SizedBox(height: 4.h),
                _buildRoleSelection(theme),
                SizedBox(height: 4.h),
                _buildBasicInformation(theme),
                if (_selectedRole != null)
                  RoleSpecificFields(
                    selectedRole: _selectedRole!,
                    businessNameController: _businessNameController,
                    certificationController: _certificationController,
                    organizationController: _organizationController,
                    serviceAreaController: _serviceAreaController,
                    selectedAvailability: _selectedAvailability,
                    selectedTransportation: _selectedTransportation,
                    onAvailabilityChanged: (value) {
                      setState(() => _selectedAvailability = value);
                    },
                    onTransportationChanged: (value) {
                      setState(() => _selectedTransportation = value);
                    },
                  ),
                SizedBox(height: 4.h),
                _buildProfilePhotoSection(theme),
                SizedBox(height: 4.h),
                _buildLocationPermissionSection(theme),
                SizedBox(height: 3.h),
                _buildTermsAndConditions(theme),
                SizedBox(height: 4.h),
                _buildCreateAccountButton(theme),
                SizedBox(height: 3.h),
                _buildLoginRedirect(theme),
                SizedBox(height: 4.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ---------------- BUILD WIDGETS ----------------

  Widget _buildWelcomeSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Join FoodBridge',
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: theme.colorScheme.primary,
          ),
        ),
        SizedBox(height: 1.h),
        Text(
          'Connect with our community to reduce food waste and fight hunger through AI-powered coordination.',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.7),
            height: 1.4,
          ),
        ),
      ],
    );
  }

  Widget _buildRoleSelection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Your Role',
          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
        SizedBox(height: 1.h),
        Text(
          'Choose how you want to contribute to reducing food waste',
          style: theme.textTheme.bodyMedium
              ?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.6)),
        ),
        SizedBox(height: 3.h),
        ..._roles.map((role) => RoleSelectionCard(
          title: role['title'],
          description: role['description'],
          iconName: role['icon'],
          isSelected: _selectedRole?.toString().split('.').last == role['id'],
          onTap: () => _selectRole(role['id']),
        )),
      ],
    );
  }

  Widget _buildBasicInformation(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Basic Information',
          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
        SizedBox(height: 3.h),
        TextFormField(
          controller: _fullNameController,
          decoration: const InputDecoration(
              labelText: 'Full Name *', hintText: 'Enter your full name'),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Full name is required';
            }
            if (value.trim().length < 2) {
              return 'Name must be at least 2 characters';
            }
            return null;
          },
        ),
        SizedBox(height: 2.h),
        TextFormField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(
              labelText: 'Email Address *', hintText: 'Enter your email address'),
          validator: (value) {
            if (value == null || value.trim().isEmpty) return 'Email is required';
            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
              return 'Enter a valid email';
            }
            return null;
          },
        ),
        SizedBox(height: 2.h),
        TextFormField(
          controller: _passwordController,
          obscureText: !_isPasswordVisible,
          decoration: InputDecoration(
            labelText: 'Password *',
            hintText: 'Create a strong password',
            suffixIcon: IconButton(
              icon: Icon(
                  _isPasswordVisible ? Icons.visibility_off : Icons.visibility),
              onPressed: () =>
                  setState(() => _isPasswordVisible = !_isPasswordVisible),
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) return 'Password is required';
            if (value.length < 8) {
              return 'Password must be at least 8 characters';
            }
            return null;
          },
        ),
        PasswordStrengthIndicator(password: _passwordController.text),
      ],
    );
  }

  Widget _buildProfilePhotoSection(ThemeData theme) {
    return ProfilePhotoPicker(
      selectedImage: _profileImage,
      onImageSelected: (image) => setState(() => _profileImage = image),
    );
  }

  // ----------- LOCATION PERMISSION SECTION -----------
  Widget _buildLocationPermissionSection(ThemeData theme) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.primary.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CustomIconWidget(
                  iconName: 'location_on',
                  color: theme.colorScheme.primary,
                  size: 5.w),
              SizedBox(width: 3.w),
              Expanded(
                child: Text(
                  'Location Services',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          Text(
            'FoodBridge uses your location to match you with nearby food donations and optimize delivery routes.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
              height: 1.4,
            ),
          ),
          SizedBox(height: 2.h),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed:
                  _locationPermissionRequested ? null : _enableLocation,
                  child: Text(_locationPermissionRequested
                      ? 'Permission Granted'
                      : 'Enable'),
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: OutlinedButton(
                  onPressed: _skipLocation,
                  child: const Text('Skip'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ---------------- TERMS & CREATE ACCOUNT ----------------

  Widget _buildTermsAndConditions(ThemeData theme) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Checkbox(
            value: _acceptTerms,
            onChanged: (val) =>
                setState(() => _acceptTerms = val ?? false)),
        Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _acceptTerms = !_acceptTerms),
            child: Text(
              'I agree to the Terms of Service, Privacy Policy, and Food Safety Guidelines.',
              style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.7)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCreateAccountButton(ThemeData theme) {
    final isFormValid = _selectedRole != null &&
        _fullNameController.text.isNotEmpty &&
        _emailController.text.isNotEmpty &&
        _passwordController.text.isNotEmpty &&
        _acceptTerms &&
        _isRoleSpecificFieldsValid();

    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: isFormValid && !_isLoading ? _createAccount : null,
        child: _isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : const Text("Create Account"),
      ),
    );
  }

  Widget _buildLoginRedirect(ThemeData theme) {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Already have an account? ',
              style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.7))),
          GestureDetector(
            onTap: () =>
                Navigator.pushReplacementNamed(context, '/login-screen'),
            child: Text('Sign In',
                style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                    decoration: TextDecoration.underline)),
          ),
        ],
      ),
    );
  }

  // ---------------- LOGIC ----------------

  void _selectRole(String roleId) {
    setState(() {
      switch (roleId) {
        case 'provider':
          _selectedRole = UserRole.provider;
          break;
        case 'ngo':
          _selectedRole = UserRole.ngo;
          break;
        case 'volunteer':
          _selectedRole = UserRole.volunteer;
          break;
      }
    });
  }

  bool _isRoleSpecificFieldsValid() {
    if (_selectedRole == null) return false;

    switch (_selectedRole!) {
      case UserRole.provider:
        return _businessNameController.text.isNotEmpty;
      case UserRole.ngo:
        return _organizationController.text.isNotEmpty &&
            _serviceAreaController.text.isNotEmpty;
      case UserRole.volunteer:
        return _selectedAvailability != null &&
            _selectedTransportation != null;
    }
  }

  // ----------- LOCATION PERMISSION LOGIC -----------
  Future<void> _requestLocationPermission() async {
    if (kIsWeb) {
      setState(() => _locationPermissionRequested = true);
      return;
    }

    final status = await Permission.location.request();
    setState(() => _locationPermissionRequested = status.isGranted);
    if (!status.isGranted && status.isPermanentlyDenied) openAppSettings();
  }

  void _enableLocation() async {
    await _requestLocationPermission();
    if (mounted) setState(() => _locationPermissionRequested = true);
  }

  void _skipLocation() {
    setState(() => _locationPermissionRequested = false);
  }

  // ----------- ACCOUNT CREATION -----------
  Future<void> _createAccount() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text);
      final user = userCredential.user;
      if (user == null) throw Exception("User creation failed");

      final roleString = _selectedRole.toString().split('.').last;
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'fullName': _fullNameController.text.trim(),
        'email': _emailController.text.trim(),
        'phone': _phoneController.text.trim(),
        'role': roleString,
        'businessName': _businessNameController.text.trim(),
        'certification': _certificationController.text.trim(),
        'organization': _organizationController.text.trim(),
        'serviceArea': _serviceAreaController.text.trim(),
        'availability': _selectedAvailability,
        'transportation': _selectedTransportation,
        'profilePhoto': _profileImage?.path,
        'createdAt': FieldValue.serverTimestamp(),
      });

      _showSuccessSnackBar('Account created successfully!');

      // ✅ Redirect to Welcome screen instead of /biometric-setup
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/welcome');
      }
    } on FirebaseAuthException catch (e) {
      String msg = "Failed to create account. Please try again.";
      if (e.code == 'email-already-in-use') msg = "This email is already registered.";
      if (e.code == 'weak-password') msg = "Password is too weak.";
      _showErrorSnackBar(msg);
    } catch (e) {
      _showErrorSnackBar('Error: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _handleBackNavigation() {
    if (_hasUnsavedChanges()) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Unsaved Changes'),
          content: const Text('You have unsaved changes. Are you sure you want to go back?'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushReplacementNamed(context, '/login-screen');
              },
              child: const Text('Go Back'),
            ),
          ],
        ),
      );
    } else {
      Navigator.pushReplacementNamed(context, '/login-screen');
    }
  }

  bool _hasUnsavedChanges() {
    return _fullNameController.text.isNotEmpty ||
        _emailController.text.isNotEmpty ||
        _phoneController.text.isNotEmpty ||
        _passwordController.text.isNotEmpty ||
        _selectedRole != null ||
        _profileImage != null;
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(message),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating),
    );
  }
}

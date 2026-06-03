import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/camera_preview_widget.dart';
import './widgets/food_details_form_widget.dart';
import './widgets/upload_progress_widget.dart';

class FoodUploadScreen extends StatefulWidget {
  const FoodUploadScreen({super.key});

  @override
  State<FoodUploadScreen> createState() => _FoodUploadScreenState();
}

class _FoodUploadScreenState extends State<FoodUploadScreen> {
  final _scrollController = ScrollController();
  final _formKey = GlobalKey<FormState>();

  XFile? _capturedImage;
  Map<String, dynamic> _formData = {};
  bool _isUploading = false;
  double _uploadProgress = 0.0;
  String _currentUploadStep = '';
  bool _hasUnsavedChanges = false;

  final List<Map<String, dynamic>> _mockFoodData = [
    {
      "id": 1,
      "name": "Fresh Vegetable Medley",
      "category": "Fresh Produce",
      "quantity": "25.5",
      "unit": "pounds",
      "condition": 5,
      "expirationDate": "2025-01-15T00:00:00.000Z",
      "location":
          "Green Valley Restaurant, 456 Oak Street, Springfield, IL 62701",
      "notes":
          "Organic mixed vegetables including carrots, broccoli, and bell peppers. Perfect for soup kitchens.",
      "imageUrl":
          "https://images.pexels.com/photos/1640777/pexels-photo-1640777.jpeg?auto=compress&cs=tinysrgb&w=800",
      "providerId": "provider_001",
      "providerName": "Green Valley Restaurant",
      "timestamp": "2025-01-11T07:07:07.742Z",
      "status": "available",
      "blockchainId": "0x1a2b3c4d5e6f7890abcdef1234567890",
      "iotConnected": true,
      "temperature": "38°F",
      "humidity": "85%",
      "availabilityWindow": "09:00 - 17:00"
    }
  ];

  @override
  void initState() {
    super.initState();
    _initializeFormData();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _initializeFormData() {
    _formData = {
      'category': '',
      'quantity': '',
      'unit': 'servings',
      'expirationDate': null,
      'condition': 5,
      'notes': '',
      'location': '',
      'availabilityStart': null,
      'availabilityEnd': null,
      'iotConnected': false,
    };
  }

  Future<bool> _onWillPop() async {
    if (_isUploading) {
      return false;
    }

    if (_hasUnsavedChanges) {
      return await _showUnsavedChangesDialog() ?? false;
    }

    return true;
  }

  Future<bool?> _showUnsavedChangesDialog() async {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Unsaved Changes'),
        content: const Text(
            'You have unsaved changes. Are you sure you want to leave?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Stay'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Leave'),
          ),
        ],
      ),
    );
  }

  void _onImageCaptured(XFile image) {
    setState(() {
      _capturedImage = image;
      _hasUnsavedChanges = true;
    });

    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Photo captured successfully!'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _onGalleryTap() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _capturedImage = image;
          _hasUnsavedChanges = true;
        });

        HapticFeedback.lightImpact();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Image selected from gallery!'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to select image from gallery'),
        ),
      );
    }
  }

  void _onFormChanged(Map<String, dynamic> formData) {
    setState(() {
      _formData = formData;
      _hasUnsavedChanges = true;
    });
  }

  Future<void> _uploadFood() async {
    if (!_validateForm()) {
      return;
    }

    setState(() {
      _isUploading = true;
      _uploadProgress = 0.0;
    });

    try {
      // Step 1: Image Analysis
      setState(() {
        _currentUploadStep = 'Analyzing food quality and freshness...';
        _uploadProgress = 0.1;
      });
      await Future.delayed(const Duration(seconds: 2));

      setState(() {
        _uploadProgress = 0.25;
      });

      // Step 2: Blockchain Logging
      setState(() {
        _currentUploadStep = 'Securing transaction on blockchain...';
        _uploadProgress = 0.4;
      });
      await Future.delayed(const Duration(seconds: 2));

      setState(() {
        _uploadProgress = 0.6;
      });

      // Step 3: NGO Matching
      setState(() {
        _currentUploadStep = 'Finding nearby NGOs and volunteers...';
        _uploadProgress = 0.75;
      });
      await Future.delayed(const Duration(seconds: 2));

      // Step 4: Notifications
      setState(() {
        _currentUploadStep = 'Sending notifications to recipients...';
        _uploadProgress = 0.9;
      });
      await Future.delayed(const Duration(seconds: 1));

      setState(() {
        _uploadProgress = 1.0;
      });

      await Future.delayed(const Duration(milliseconds: 500));

      // Success
      setState(() {
        _isUploading = false;
        _hasUnsavedChanges = false;
      });

      _showSuccessDialog();
    } catch (e) {
      setState(() {
        _isUploading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Upload failed. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            CustomIconWidget(
              iconName: 'check_circle',
              size: 28,
              color: Theme.of(context).colorScheme.primary,
            ),
            SizedBox(width: 2.w),
            const Text('Upload Successful!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
                'Your food item has been successfully uploaded and is now available for donation.'),
            SizedBox(height: 2.h),
            Container(
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .colorScheme
                    .primary
                    .withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Blockchain ID:',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  Text(
                    '0x1a2b3c4d5e6f7890abcdef1234567890',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontFamily: 'monospace',
                          color: Theme.of(context).colorScheme.primary,
                        ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 2.h),
            Row(
              children: [
                CustomIconWidget(
                  iconName: 'notifications',
                  size: 16,
                  color: Theme.of(context).colorScheme.primary,
                ),
                SizedBox(width: 1.w),
                Expanded(
                  child: Text(
                    '3 nearby NGOs have been notified',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.pushReplacementNamed(context, '/provider-dashboard');
            },
            child: const Text('View Dashboard'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _resetForm();
            },
            child: const Text('Upload Another'),
          ),
        ],
      ),
    );
  }

  void _resetForm() {
    setState(() {
      _capturedImage = null;
      _hasUnsavedChanges = false;
    });
    _initializeFormData();
  }

  void _cancelUpload() {
    setState(() {
      _isUploading = false;
      _uploadProgress = 0.0;
      _currentUploadStep = '';
    });
  }

  bool _validateForm() {
    if (_capturedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please capture or select a photo of the food'),
        ),
      );
      return false;
    }

    if (_formData['category'] == null || _formData['category'].isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a food category'),
        ),
      );
      return false;
    }

    if (_formData['quantity'] == null || _formData['quantity'].isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter the quantity'),
        ),
      );
      return false;
    }

    if (_formData['location'] == null || _formData['location'].isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter the pickup location'),
        ),
      );
      return false;
    }

    return true;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: theme.colorScheme.surface,
        appBar: AppBar(
          title: const Text('Upload Food'),
          leading: IconButton(
            onPressed: () async {
              if (await _onWillPop()) {
                Navigator.of(context).pop();
              }
            },
            icon: CustomIconWidget(
              iconName: 'close',
              size: 24,
              color: theme.colorScheme.onSurface,
            ),
          ),
          actions: [
            if (_hasUnsavedChanges && !_isUploading)
              TextButton(
                onPressed: _uploadFood,
                child: Text(
                  'Save',
                  style: TextStyle(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
        body: Stack(
          children: [
            SingleChildScrollView(
              controller: _scrollController,
              padding: EdgeInsets.all(4.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Camera Section
                  CameraPreviewWidget(
                    onImageCaptured: _onImageCaptured,
                    onGalleryTap: _onGalleryTap,
                  ),

                  SizedBox(height: 3.h),

                  // Captured Image Preview
                  if (_capturedImage != null) ...[
                    Container(
                      width: double.infinity,
                      height: 20.h,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color:
                              theme.colorScheme.outline.withValues(alpha: 0.3),
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: CustomImageWidget(
                          imageUrl: _capturedImage!.path,
                          width: double.infinity,
                          height: 20.h,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    SizedBox(height: 3.h),
                  ],

                  // Form Section
                  FoodDetailsFormWidget(
                    onFormChanged: _onFormChanged,
                  ),

                  SizedBox(height: 4.h),

                  // Upload Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isUploading ? null : _uploadFood,
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 2.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (!_isUploading) ...[
                            CustomIconWidget(
                              iconName: 'cloud_upload',
                              size: 20,
                              color: theme.colorScheme.onPrimary,
                            ),
                            SizedBox(width: 2.w),
                          ],
                          Text(
                            _isUploading ? 'Uploading...' : 'Upload Food',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: 2.h),

                  // Help Text
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(3.w),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: theme.colorScheme.primary.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomIconWidget(
                          iconName: 'info',
                          size: 20,
                          color: theme.colorScheme.primary,
                        ),
                        SizedBox(width: 2.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'AI-Powered Analysis',
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                              SizedBox(height: 0.5.h),
                              Text(
                                'Our AI will analyze your food photo to determine freshness, estimate shelf life, and match with the most suitable NGOs in your area.',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurface
                                      .withValues(alpha: 0.7),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 10.h),
                ],
              ),
            ),

            // Upload Progress Overlay
            if (_isUploading)
              UploadProgressWidget(
                isUploading: _isUploading,
                progress: _uploadProgress,
                currentStep: _currentUploadStep,
                onCancel: _cancelUpload,
              ),
          ],
        ),
      ),
    );
  }
}

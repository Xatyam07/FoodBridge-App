import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class ProfilePhotoPicker extends StatefulWidget {
  final Function(XFile?) onImageSelected;
  final XFile? selectedImage;

  const ProfilePhotoPicker({
    super.key,
    required this.onImageSelected,
    this.selectedImage,
  });

  @override
  State<ProfilePhotoPicker> createState() => _ProfilePhotoPickerState();
}

class _ProfilePhotoPickerState extends State<ProfilePhotoPicker> {
  final ImagePicker _picker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        GestureDetector(
          onTap: _showImageSourceDialog,
          child: Container(
            width: 25.w,
            height: 25.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: theme.colorScheme.primary.withValues(alpha: 0.1),
              border: Border.all(
                color: theme.colorScheme.primary.withValues(alpha: 0.3),
                width: 2,
              ),
            ),
            child: widget.selectedImage != null
                ? ClipOval(
                    child: kIsWeb
                        ? Image.network(
                            widget.selectedImage!.path,
                            width: 25.w,
                            height: 25.w,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return _buildPlaceholder(theme);
                            },
                          )
                        : CustomImageWidget(
                            imageUrl: widget.selectedImage!.path,
                            width: 25.w,
                            height: 25.w,
                            fit: BoxFit.cover,
                          ),
                  )
                : _buildPlaceholder(theme),
          ),
        ),
        SizedBox(height: 2.h),
        Text(
          widget.selectedImage != null
              ? 'Tap to change photo'
              : 'Add profile photo',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildPlaceholder(ThemeData theme) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CustomIconWidget(
          iconName: 'add_a_photo',
          color: theme.colorScheme.primary,
          size: 8.w,
        ),
        SizedBox(height: 1.h),
        Text(
          'Photo',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
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
                  color: Theme.of(context)
                      .colorScheme
                      .outline
                      .withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Text(
                'Select Photo',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              SizedBox(height: 3.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildSourceOption(
                    context,
                    'Camera',
                    'camera_alt',
                    () => _pickImage(ImageSource.camera),
                  ),
                  _buildSourceOption(
                    context,
                    'Gallery',
                    'photo_library',
                    () => _pickImage(ImageSource.gallery),
                  ),
                  if (widget.selectedImage != null)
                    _buildSourceOption(
                      context,
                      'Remove',
                      'delete',
                      _removeImage,
                    ),
                ],
              ),
              SizedBox(height: 4.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSourceOption(
    BuildContext context,
    String title,
    String iconName,
    VoidCallback onTap,
  ) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
        onTap();
      },
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: CustomIconWidget(
              iconName: iconName,
              color: theme.colorScheme.primary,
              size: 6.w,
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            title,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      // Request permissions
      if (!kIsWeb) {
        bool hasPermission = false;
        if (source == ImageSource.camera) {
          hasPermission = await Permission.camera.request().isGranted;
        } else {
          hasPermission = await Permission.photos.request().isGranted;
        }

        if (!hasPermission) {
          _showPermissionDialog();
          return;
        }
      }

      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        if (!kIsWeb) {
          // Crop image on mobile platforms
          final croppedFile = await ImageCropper().cropImage(
            sourcePath: image.path,
            aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
            uiSettings: [
              AndroidUiSettings(
                toolbarTitle: 'Crop Profile Photo',
                toolbarColor: Theme.of(context).colorScheme.primary,
                toolbarWidgetColor: Theme.of(context).colorScheme.onPrimary,
                initAspectRatio: CropAspectRatioPreset.square,
                lockAspectRatio: true,
              ),
              IOSUiSettings(
                title: 'Crop Profile Photo',
                aspectRatioLockEnabled: true,
                resetAspectRatioEnabled: false,
              ),
            ],
          );

          if (croppedFile != null) {
            final croppedXFile = XFile(croppedFile.path);
            widget.onImageSelected(croppedXFile);
          }
        } else {
          // On web, use the image directly
          widget.onImageSelected(image);
        }
      }
    } catch (e) {
      _showErrorDialog('Failed to select image. Please try again.');
    }
  }

  void _removeImage() {
    widget.onImageSelected(null);
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Permission Required'),
        content: const Text(
          'Please grant camera and photo permissions to upload your profile picture.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              openAppSettings();
            },
            child: const Text('Settings'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}

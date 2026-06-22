import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class DashboardHeaderWidget extends StatelessWidget {
  final String userName;
  final VoidCallback? onProfileTap;
  final VoidCallback? onNotificationTap;

  const DashboardHeaderWidget({
    Key? key,
    required this.userName,
    this.onProfileTap,
    this.onNotificationTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Greeting Text
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hello,',
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w400,
                  color: Colors.grey[600],
                ),
              ),
              SizedBox(height: 0.5.h),
              Text(
                userName,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),

          // Profile & Notification Icons
          Row(
            children: [
              // Notification Bell
              GestureDetector(
                onTap: onNotificationTap,
                child: Container(
                  padding: EdgeInsets.all(1.5.h),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.grey[200],
                  ),
                  child: Icon(
                    Icons.notifications_none,
                    size: 3.h,
                    color: Colors.black87,
                  ),
                ),
              ),
              SizedBox(width: 3.w),

              // Profile Picture
              GestureDetector(
                onTap: onProfileTap,
                child: CircleAvatar(
                  radius: 3.h,
                  backgroundImage: AssetImage('assets/images/profile.png'),
                  backgroundColor: Colors.grey[200],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

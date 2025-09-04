import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class CommunicationCardWidget extends StatelessWidget {
  final Map<String, dynamic> communicationData;
  final VoidCallback onMessageTap;
  final int unreadCount;

  const CommunicationCardWidget({
    super.key,
    required this.communicationData,
    required this.onMessageTap,
    this.unreadCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onMessageTap,
      child: Container(
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
          color: AppTheme.lightTheme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                  decoration: BoxDecoration(
                    color:
                        AppTheme.lightTheme.primaryColor.transparent10,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CustomIconWidget(
                        iconName: 'chat',
                        color: AppTheme.lightTheme.primaryColor,
                        size: 16,
                      ),
                      SizedBox(width: 1.w),
                      Text(
                        "Messages",
                        style:
                            AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                          color: AppTheme.lightTheme.primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                if (unreadCount > 0)
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                    decoration: BoxDecoration(
                      color: AppTheme.lightTheme.colorScheme.error,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      unreadCount.toString(),
                      style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.onError,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(height: 2.h),
            Text(
              "Quick Communication",
              style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 1.h),
            Text(
              "Stay connected with your child's therapy team through secure messaging",
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              ),
            ),
            SizedBox(height: 2.h),
            if ((communicationData["recentMessages"] as List).isNotEmpty) ...[
              Text(
                "Recent Messages",
                style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 1.h),
              ...(communicationData["recentMessages"] as List)
                  .take(2)
                  .map((message) {
                final messageData = message as Map<String, dynamic>;
                return _buildMessagePreview(messageData);
              }),
              SizedBox(height: 2.h),
            ],
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onMessageTap,
                    icon: CustomIconWidget(
                      iconName: 'send',
                      color: AppTheme.lightTheme.colorScheme.onPrimary,
                      size: 18,
                    ),
                    label: Text(
                      "Send Message",
                      style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.onPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.lightTheme.primaryColor,
                      padding: EdgeInsets.symmetric(vertical: 2.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 3.w),
                OutlinedButton(
                  onPressed: onMessageTap,
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.all(2.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    side: BorderSide(
                      color: AppTheme.lightTheme.primaryColor,
                      width: 1.5,
                    ),
                  ),
                  child: CustomIconWidget(
                    iconName: 'history',
                    color: AppTheme.lightTheme.primaryColor,
                    size: 18,
                  ),
                ),
              ],
            ),
            SizedBox(height: 2.h),
            Row(
              children: [
                CustomIconWidget(
                  iconName: 'security',
                  color: AppTheme.lightTheme.colorScheme.tertiary,
                  size: 16,
                ),
                SizedBox(width: 1.w),
                Text(
                  "HIPAA compliant secure messaging",
                  style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.tertiary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessagePreview(Map<String, dynamic> messageData) {
    return Container(
      margin: EdgeInsets.only(bottom: 1.h),
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.3),
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                messageData["sender"] as String,
                style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Text(
                messageData["time"] as String,
                style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          SizedBox(height: 0.5.h),
          Text(
            messageData["preview"] as String,
            style: AppTheme.lightTheme.textTheme.bodySmall,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

class RegisterLinkWidget extends StatelessWidget {
  final VoidCallback? onRegisterTap;
  final bool isSignUpMode;

  const RegisterLinkWidget({
    super.key,
    this.onRegisterTap,
    this.isSignUpMode = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 2.h),
      child: Wrap(
        alignment: WrapAlignment.center,
        children: [
          Text(
            isSignUpMode ? 'Already have an account? ' : 'New user? ',
            style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            ),
          ),
          GestureDetector(
            onTap: onRegisterTap ??
                () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(isSignUpMode ? 'Sign in will be available soon' : 'Registration will be available soon'),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
            child: Text(
              isSignUpMode ? 'Sign In' : 'Register',
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.lightTheme.colorScheme.primary,
                fontWeight: FontWeight.w600,
                decoration: TextDecoration.underline,
                decorationColor: AppTheme.lightTheme.colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

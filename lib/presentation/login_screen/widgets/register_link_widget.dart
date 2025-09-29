import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final String titleText = isSignUpMode
        ? 'Already part of ThrivePath?'
        : 'New to ThrivePath?';
    final String ctaText = isSignUpMode ? 'Sign in instead' : 'Create an account';
    final IconData accentIcon =
        isSignUpMode ? Icons.login_rounded : Icons.auto_awesome_rounded;
    final List<Color> gradientColors = isSignUpMode
        ? [
            colorScheme.primary.withOpacity(0.12),
            colorScheme.primary.withOpacity(0.22),
          ]
        : [
            colorScheme.secondary.withOpacity(0.14),
            colorScheme.secondary.withOpacity(0.24),
          ];

    return Padding(
      padding: EdgeInsets.only(top: 1.6.h),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onRegisterTap ??
            () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    isSignUpMode
                        ? 'Sign in will be available soon'
                        : 'Registration will be available soon',
                  ),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
        child: Ink(
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.8.h),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: gradientColors,
            ),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: (isSignUpMode ? colorScheme.primary : colorScheme.secondary)
                  .withOpacity(0.32),
            ),
            boxShadow: [
              BoxShadow(
                color: (isSignUpMode ? colorScheme.primary : colorScheme.secondary)
                    .withOpacity(0.18),
                blurRadius: 22,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(1.8.w),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.18),
                ),
                child: Icon(
                  accentIcon,
                  size: 20,
                  color: isSignUpMode
                      ? colorScheme.primary
                      : colorScheme.secondary,
                ),
              ),
              SizedBox(width: 3.2.w),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    titleText,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 0.7.h),
                  Row(
                    children: [
                      Text(
                        ctaText,
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: isSignUpMode
                              ? colorScheme.primary
                              : colorScheme.secondary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(width: 1.w),
                      Icon(
                        Icons.arrow_forward_rounded,
                        size: 18,
                        color: isSignUpMode
                            ? colorScheme.primary
                            : colorScheme.secondary,
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}



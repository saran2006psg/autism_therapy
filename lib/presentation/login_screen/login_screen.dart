import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/app_logo_widget.dart';
import './widgets/login_form_widget.dart';
import './widgets/signup_form_widget.dart';
import './widgets/register_link_widget.dart';
import './widgets/role_indicator_widget.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isLoading = false;
  String? _userRole;
  bool _showRoleIndicator = false;
  bool _isSignUpMode = false;
  String _selectedRole = 'Therapist'; // Default role selection

  Future<void> _handleSignUp(String email, String password, String name) async {
    setState(() {
      _isLoading = true;
      _showRoleIndicator = false;
    });

    try {
      // Use Firebase Authentication to create account with selected role
      final result = await AuthService.createUserWithEmailAndPassword(
        email: email,
        password: password,
        name: name,
        role: _selectedRole, // Use selected role instead of default
      );

      if (result.success && result.user != null) {
        // Success - show role indicator
        setState(() {
          _userRole = result.userRole ?? _selectedRole;
          _showRoleIndicator = true;
          _isLoading = false;
        });

        // Haptic feedback
        HapticFeedback.lightImpact();

        // Show success message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Welcome to Thriveers, ${result.userName ?? 'User'}!'),
              backgroundColor: AppTheme.lightTheme.colorScheme.tertiary,
              duration: const Duration(seconds: 2),
            ),
          );
        }

        // Navigate based on role after delay
        await Future.delayed(const Duration(seconds: 1));

        // Initialize data service
        final dataService = DataService();
        await dataService.initialize();

        if (mounted) {
          final route = _userRole?.toLowerCase() == 'therapist'
              ? '/therapist-dashboard'
              : '/parent-dashboard';
          Navigator.pushReplacementNamed(context, route);
        }
      } else {
        // Sign-up failed
        setState(() {
          _isLoading = false;
          _showRoleIndicator = false;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result.errorMessage ?? 'Sign-up failed. Please try again.'),
              backgroundColor: AppTheme.lightTheme.colorScheme.error,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _showRoleIndicator = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('An error occurred: ${e.toString()}'),
            backgroundColor: AppTheme.lightTheme.colorScheme.error,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  void _toggleSignUpMode() {
    setState(() {
      _isSignUpMode = !_isSignUpMode;
      _showRoleIndicator = false;
    });
  }

  Future<void> _handleLogin(String email, String password) async {
    setState(() {
      _isLoading = true;
      _showRoleIndicator = false;
    });

    try {
      // Use Firebase Authentication
      final result = await AuthService.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (result.success && result.user != null) {
        // Success - show role indicator
        setState(() {
          _userRole = result.userRole ?? 'Therapist';
          _showRoleIndicator = true;
          _isLoading = false;
        });

        // Haptic feedback
        HapticFeedback.lightImpact();

        // Show success message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Welcome back, ${result.userName ?? 'User'}!'),
              backgroundColor: AppTheme.lightTheme.colorScheme.tertiary,
              duration: const Duration(seconds: 2),
            ),
          );
        }

        // Navigate based on role after delay
        await Future.delayed(const Duration(seconds: 1));

        // Initialize data service
        final dataService = DataService();
        await dataService.initialize();

        if (mounted) {
          final route = _userRole?.toLowerCase() == 'therapist'
              ? '/therapist-dashboard'
              : '/parent-dashboard';
          Navigator.pushReplacementNamed(context, route);
        }
      } else {
        // Authentication failed
        setState(() {
          _isLoading = false;
          _showRoleIndicator = false;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result.errorMessage ?? 'Login failed. Please try again.'),
              backgroundColor: AppTheme.lightTheme.colorScheme.error,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _showRoleIndicator = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
                'Network error. Please check your connection and try again.'),
            backgroundColor: AppTheme.lightTheme.colorScheme.error,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Widget _buildRoleSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Your Role',
          style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
            color: AppTheme.lightTheme.colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 2.h),
        Row(
          children: [
            Expanded(
              child: _buildRoleCard(
                'Therapist',
                'Manage therapy sessions and track student progress',
                Icons.medical_services_outlined,
                AppTheme.lightTheme.colorScheme.primary,
              ),
            ),
            SizedBox(width: 3.w),
            Expanded(
              child: _buildRoleCard(
                'Parent',
                'Monitor your child\'s therapy progress and activities',
                Icons.family_restroom_outlined,
                AppTheme.lightTheme.colorScheme.secondary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRoleCard(String role, String description, IconData icon, Color color) {
    final isSelected = _selectedRole == role;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedRole = role;
        });
        HapticFeedback.selectionClick();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
          gradient: isSelected 
              ? LinearGradient(
                  colors: [
                    color.withValues(alpha: 0.1),
                    color.withValues(alpha: 0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: isSelected ? null : AppTheme.lightTheme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected 
                ? color 
                : AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.2),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected 
              ? [
                  BoxShadow(
                    color: color.withValues(alpha: 0.2),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                gradient: isSelected 
                    ? LinearGradient(
                        colors: [color, color.withValues(alpha: 0.8)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : null,
                color: isSelected 
                    ? null 
                    : color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: isSelected ? Colors.white : color,
                size: 24,
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              role,
              style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                color: isSelected 
                    ? color
                    : AppTheme.lightTheme.colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 1.h),
            Text(
              description,
              style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                fontSize: 10,
              ),
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.1),
              AppTheme.lightTheme.colorScheme.secondary.withValues(alpha: 0.05),
              AppTheme.lightTheme.scaffoldBackgroundColor,
            ],
            stops: const [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: MediaQuery.of(context).size.height -
                      MediaQuery.of(context).padding.top -
                      MediaQuery.of(context).padding.bottom,
                ),
                child: IntrinsicHeight(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 6.w),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(height: 8.h),

                        // App Logo Section
                        const AppLogoWidget(),

                        SizedBox(height: 6.h),

                        // Main Content Card
                        Container(
                          width: double.infinity,
                          constraints: BoxConstraints(maxWidth: 90.w),
                          padding: EdgeInsets.all(6.w),
                          decoration: BoxDecoration(
                            color: AppTheme.lightTheme.colorScheme.surface,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.1),
                              width: 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 30,
                                offset: const Offset(0, 10),
                              ),
                              BoxShadow(
                                color: AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.05),
                                blurRadius: 20,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Header Section
                              Container(
                                padding: EdgeInsets.symmetric(vertical: 2.h),
                                child: Column(
                                  children: [
                                    Text(
                                      _isSignUpMode ? 'Create Account' : 'Welcome Back',
                                      style: AppTheme.lightTheme.textTheme.headlineSmall
                                          ?.copyWith(
                                        color: AppTheme.lightTheme.colorScheme.onSurface,
                                        fontWeight: FontWeight.w700,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    SizedBox(height: 1.h),
                                    Text(
                                      _isSignUpMode 
                                          ? 'Join our community of therapy professionals and families'
                                          : 'Sign in to continue your therapy management journey',
                                      style: AppTheme.lightTheme.textTheme.bodyMedium
                                          ?.copyWith(
                                        color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),

                              SizedBox(height: 4.h),

                              // Role Selection (only for sign up)
                              if (_isSignUpMode) ...[
                                _buildRoleSelector(),
                                SizedBox(height: 3.h),
                              ],

                              // Login or Sign Up Form
                              _isSignUpMode
                                  ? SignUpFormWidget(
                                      onSignUp: _handleSignUp,
                                      isLoading: _isLoading,
                                    )
                                  : LoginFormWidget(
                                      onLogin: _handleLogin,
                                      isLoading: _isLoading,
                                    ),

                              // Role Indicator
                              RoleIndicatorWidget(
                                userRole: _userRole,
                                isVisible: _showRoleIndicator,
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: 4.h),

                        // Register/Sign In Link
                        RegisterLinkWidget(
                          isSignUpMode: _isSignUpMode,
                          onRegisterTap: _toggleSignUpMode,
                        ),

                        SizedBox(height: 3.h),

                        // Demo Credentials Info
                        Container(
                          padding: EdgeInsets.all(4.w),
                          margin: EdgeInsets.symmetric(horizontal: 2.w),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppTheme.lightTheme.colorScheme.primaryContainer.withValues(alpha: 0.1),
                                AppTheme.lightTheme.colorScheme.primaryContainer.withValues(alpha: 0.05),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.2),
                              width: 1,
                            ),
                          ),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.info_outline,
                                    color: AppTheme.lightTheme.colorScheme.primary,
                                    size: 20,
                                  ),
                                  SizedBox(width: 2.w),
                                  Text(
                                    'Demo Credentials',
                                    style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
                                      color: AppTheme.lightTheme.colorScheme.primary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 2.h),
                              Container(
                                padding: EdgeInsets.all(3.w),
                                decoration: BoxDecoration(
                                  color: AppTheme.lightTheme.colorScheme.surface,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Column(
                                  children: [
                                    _buildDemoCredential(
                                      'Therapist Account',
                                      'dr.sarah.johnson@therapycenter.com',
                                      'therapist123',
                                      Icons.medical_services,
                                      AppTheme.lightTheme.colorScheme.primary,
                                    ),
                                    SizedBox(height: 2.h),
                                    _buildDemoCredential(
                                      'Parent Account',
                                      'michael.parent@email.com',
                                      'parent123',
                                      Icons.family_restroom,
                                      AppTheme.lightTheme.colorScheme.secondary,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: 4.h),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDemoCredential(String title, String email, String password, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(2.w),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(
              icon,
              color: color,
              size: 16,
            ),
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 0.5.h),
                Text(
                  '$email\n$password',
                  style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

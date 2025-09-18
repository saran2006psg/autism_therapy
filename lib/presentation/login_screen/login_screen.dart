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
  String _selectedRole = 'Therapist';
  bool _showRoleSelection = true;

  Future<void> _handleSignUp(String email, String password, String name) async {
    setState(() {
      _isLoading = true;
      _showRoleIndicator = false;
    });

    try {
      final result = await AuthService.createUserWithEmailAndPassword(
        email: email,
        password: password,
        name: name,
        role: _selectedRole,
      );

      if (result.success && result.user != null) {
        setState(() {
          _userRole = result.userRole ?? _selectedRole;
          _showRoleIndicator = true;
          _isLoading = false;
        });

        HapticFeedback.lightImpact();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Welcome to Thriveers, ${result.userName ?? 'User'}!'),
              backgroundColor: Theme.of(context).colorScheme.tertiary,
              duration: const Duration(seconds: 2),
            ),
          );
        }

        await Future.delayed(const Duration(seconds: 1));

        final dataService = DataService();
        await dataService.initialize();

        if (mounted) {
          final route = _userRole?.toLowerCase() == 'therapist'
              ? '/therapist-dashboard'
              : '/parent-dashboard';
          Navigator.pushReplacementNamed(context, route);
        }
      } else {
        setState(() {
          _isLoading = false;
          _showRoleIndicator = false;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result.errorMessage ?? 'Sign-up failed. Please try again.'),
              backgroundColor: Theme.of(context).colorScheme.error,
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
            backgroundColor: Theme.of(context).colorScheme.error,
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

  void _selectRole(String role) {
    setState(() {
      _selectedRole = role;
      _showRoleSelection = false;
    });
  }

  void _goBackToRoleSelection() {
    setState(() {
      _showRoleSelection = true;
      _isSignUpMode = false;
      _showRoleIndicator = false;
    });
  }

  Future<void> _handleLogin(String email, String password) async {
    setState(() {
      _isLoading = true;
      _showRoleIndicator = false;
    });

    try {
      final result = await AuthService.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (result.success && result.user != null) {
        setState(() {
          _userRole = result.userRole ?? 'Therapist';
          _showRoleIndicator = true;
          _isLoading = false;
        });

        HapticFeedback.lightImpact();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Welcome back, ${result.userName ?? 'User'}!'),
              backgroundColor: Theme.of(context).colorScheme.tertiary,
              duration: const Duration(seconds: 2),
            ),
          );
        }

        await Future.delayed(const Duration(seconds: 1));

        final dataService = DataService();
        await dataService.initialize();

        if (mounted) {
          final route = _userRole?.toLowerCase() == 'therapist'
              ? '/therapist-dashboard'
              : '/parent-dashboard';
          Navigator.pushReplacementNamed(context, route);
        }
      } else {
        setState(() {
          _isLoading = false;
          _showRoleIndicator = false;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result.errorMessage ?? 'Login failed. Please try again.'),
              backgroundColor: Theme.of(context).colorScheme.error,
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
            backgroundColor: Theme.of(context).colorScheme.error,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Widget _buildRoleSelectionScreen() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(height: 4.h),
        Text(
          'Welcome to ThrivePath',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        SizedBox(height: 1.h),
        Text(
          'Please select your role to get started',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        SizedBox(height: 5.h),
        _buildRoleCard(
          role: 'Therapist',
          icon: Icons.medical_services_outlined,
          description: 'Manage therapy sessions, track client progress, and create personalized treatment plans',
          color: Theme.of(context).colorScheme.primary,
        ),
        SizedBox(height: 3.h),
        _buildRoleCard(
          role: 'Parent',
          icon: Icons.family_restroom_outlined,
          description: 'Monitor your child\'s therapy progress, communicate with therapists, and access resources',
          color: Theme.of(context).colorScheme.secondary,
        ),
        SizedBox(height: 3.h),
        
        // Student login option
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(4.w),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceVariant,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
            ),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Icon(
                    Icons.school,
                    color: Theme.of(context).colorScheme.tertiary,
                    size: 24,
                  ),
                  SizedBox(width: 3.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Are you a student?',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          'Access your therapy activities and track your progress',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 2.h),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => Navigator.pushNamed(context, '/student-login'),
                  icon: const Icon(Icons.login),
                  label: const Text('Student Login'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.tertiary,
                    side: BorderSide(color: Theme.of(context).colorScheme.tertiary),
                    padding: EdgeInsets.symmetric(vertical: 1.5.h),
                  ),
                ),
              ),
            ],
          ),
        ),
        
        SizedBox(height: 4.h),
      ],
    );
  }

  Widget _buildRoleCard({
    required String role,
    required IconData icon,
    required String description,
    required Color color,
  }) {
    return GestureDetector(
      onTap: () => _selectRole(role),
      child: Container(
        padding: EdgeInsets.all(5.w),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: color.withValues(alpha: 0.3),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.1),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 15.w,
                color: color,
              ),
            ),
            SizedBox(height: 3.h),
            Text(
              role,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              description,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'I am a:',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 2.h),
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedRole = 'Therapist';
                  });
                },
                child: Container(
                  padding: EdgeInsets.all(3.w),
                  decoration: BoxDecoration(
                    color: _selectedRole == 'Therapist'
                        ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.1)
                        : Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _selectedRole == 'Therapist'
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
                      width: _selectedRole == 'Therapist' ? 2 : 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.medical_services_outlined,
                        color: _selectedRole == 'Therapist'
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.onSurfaceVariant,
                        size: 8.w,
                      ),
                      SizedBox(height: 1.h),
                      Text(
                        'Therapist',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: _selectedRole == 'Therapist'
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.onSurfaceVariant,
                          fontWeight: _selectedRole == 'Therapist'
                              ? FontWeight.w600
                              : FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(width: 4.w),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedRole = 'Parent';
                  });
                },
                child: Container(
                  padding: EdgeInsets.all(3.w),
                  decoration: BoxDecoration(
                    color: _selectedRole == 'Parent'
                        ? Theme.of(context).colorScheme.secondary.withValues(alpha: 0.1)
                        : Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _selectedRole == 'Parent'
                          ? Theme.of(context).colorScheme.secondary
                          : Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
                      width: _selectedRole == 'Parent' ? 2 : 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.family_restroom_outlined,
                        color: _selectedRole == 'Parent'
                            ? Theme.of(context).colorScheme.secondary
                            : Theme.of(context).colorScheme.onSurfaceVariant,
                        size: 8.w,
                      ),
                      SizedBox(height: 1.h),
                      Text(
                        'Parent',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: _selectedRole == 'Parent'
                              ? Theme.of(context).colorScheme.secondary
                              : Theme.of(context).colorScheme.onSurfaceVariant,
                          fontWeight: _selectedRole == 'Parent'
                              ? FontWeight.w600
                              : FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
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
              Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
              Theme.of(context).colorScheme.secondary.withValues(alpha: 0.05),
              Theme.of(context).scaffoldBackgroundColor,
            ],
            stops: const [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: MediaQuery.of(context).size.width < 400 ? 4.w : 6.w,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(height: MediaQuery.of(context).size.height < 700 ? 4.h : 8.h),

                    // App Logo Section
                    if (!_showRoleSelection) const AppLogoWidget(),

                    SizedBox(height: MediaQuery.of(context).size.height < 700 ? 3.h : 6.h),

                    // Main Content Card
                    Container(
                      width: double.infinity,
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.9,
                      ),
                      padding: EdgeInsets.all(MediaQuery.of(context).size.width < 400 ? 4.w : 6.w),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.1),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 30,
                            offset: const Offset(0, 10),
                          ),
                          BoxShadow(
                            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.05),
                            blurRadius: 20,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: _showRoleSelection
                          ? _buildRoleSelectionScreen()
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // Header Section with Back Button and Role Display
                                Row(
                                  children: [
                                    IconButton(
                                      onPressed: _goBackToRoleSelection,
                                      icon: Icon(
                                        Icons.arrow_back,
                                        color: Theme.of(context).colorScheme.primary,
                                      ),
                                    ),
                                    SizedBox(width: 2.w),
                                    Expanded(
                                      child: Text(
                                        _isSignUpMode ? 'Create Account' : 'Welcome Back',
                                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                                      decoration: BoxDecoration(
                                        color: (_selectedRole == 'Therapist' 
                                            ? Theme.of(context).colorScheme.primary 
                                            : Theme.of(context).colorScheme.secondary).withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        _selectedRole,
                                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                          color: _selectedRole == 'Therapist' 
                                              ? Theme.of(context).colorScheme.primary 
                                              : Theme.of(context).colorScheme.secondary,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 3.h),

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

                    // Register/Sign In Link (only show when not in role selection)
                    if (!_showRoleSelection)
                      RegisterLinkWidget(
                        isSignUpMode: _isSignUpMode,
                        onRegisterTap: _toggleSignUpMode,
                      ),

                    SizedBox(height: 4.h),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

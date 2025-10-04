import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import 'package:thriveers/core/app_export.dart';
import 'package:thriveers/presentation/login_screen/widgets/app_logo_widget.dart';
import 'package:thriveers/presentation/login_screen/widgets/login_form_widget.dart';
import 'package:thriveers/presentation/login_screen/widgets/signup_form_widget.dart';
import 'package:thriveers/presentation/login_screen/widgets/register_link_widget.dart';
import 'package:thriveers/presentation/login_screen/widgets/role_indicator_widget.dart';

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
  String? _hoveredRole;

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
        final resolvedRole = (result.userRole ?? _selectedRole).trim();

        setState(() {
          _userRole = resolvedRole;
          _showRoleIndicator = true;
          _isLoading = false;
          _showRoleSelection = false;
        });

        if (mounted) {
          _navigateToDashboard(resolvedRole);
        }
      } else {
        setState(() {
          _isLoading = false;
          _showRoleIndicator = false;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Sign up failed: ${result.errorMessage ?? 'Unknown error'}'),
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
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final List<Map<String, Object>> featureHighlights = [
      {
        'icon': Icons.timeline_outlined,
        'label': 'Real-time progress tracking',
      },
      {
        'icon': Icons.chat_bubble_outline,
        'label': 'Secure therapist messaging',
      },
      {
        'icon': Icons.volunteer_activism_outlined,
        'label': 'Family collaboration tools',
      },
      {
        'icon': Icons.lock_outline,
        'label': 'HIPAA-ready safeguards',
      },
    ];

    final List<Color> accentPalette = [
      colorScheme.primary,
      colorScheme.secondary,
      colorScheme.tertiary,
      colorScheme.primaryContainer,
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(height: 2.h),
        Container(
          padding: EdgeInsets.symmetric(vertical: 4.h, horizontal: 4.w),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                colorScheme.primary.withValues(alpha: 0.22),
                colorScheme.secondary.withValues(alpha: 0.14),
              ],
            ),
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: colorScheme.primary.withValues(alpha: 0.08),
                blurRadius: 24,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Align(
                alignment: Alignment.center,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 0.8.h),
                  decoration: BoxDecoration(
                    color: colorScheme.surface.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: Text(
                    'Tailored workspaces for therapists & parents',
                    style: textTheme.labelLarge?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.4,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 3.h),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welcome to ThrivePath',
                          style: textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        SizedBox(height: 1.2.h),
                        Text(
                          'Choose the workspace that fits how you support thriving journeys.',
                          style: textTheme.bodyLarge?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 3.w),
                  if (MediaQuery.of(context).size.width > 380)
                    Container(
                      padding: EdgeInsets.all(3.5.w),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: colorScheme.surface.withValues(alpha: 0.65),
                        border: Border.all(
                          color: colorScheme.primary.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Icon(
                        Icons.explore_outlined,
                        color: colorScheme.primary,
                        size: 9.w,
                      ),
                    ),
                ],
              ),
              SizedBox(height: 3.h),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 2.w,
                runSpacing: 1.4.h,
                children: List.generate(featureHighlights.length, (index) {
                  final item = featureHighlights[index];
                  final accentColor = accentPalette[index % accentPalette.length];
                  return _buildFeatureChip(
                    item['icon'] as IconData,
                    item['label'] as String,
                    accentColor,
                  );
                }),
              ),
              SizedBox(height: 3.h),
              Align(
                alignment: Alignment.center,
                child: ElevatedButton.icon(
                  onPressed: _showRoleOverviewDialog,
                  icon: const Icon(Icons.lightbulb_outline),
                  label: const Text('How each role helps'),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 1.4.h),
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 5.h),
        _buildRoleCard(
          role: 'Therapist',
          icon: Icons.medical_services_outlined,
          description: 'Manage therapy sessions, track client progress, and create personalized treatment plans',
          color: colorScheme.primary,
        ),
        SizedBox(height: 3.h),
        _buildRoleCard(
          role: 'Parent',
          icon: Icons.family_restroom_outlined,
          description: 'Monitor your child\'s therapy progress, communicate with therapists, and access resources',
          color: colorScheme.secondary,
        ),
        SizedBox(height: 3.h),

        Container(
          width: double.infinity,
          padding: EdgeInsets.all(4.2.w),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                colorScheme.secondary.withValues(alpha: 0.18),
                colorScheme.surface,
              ],
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: colorScheme.secondary.withValues(alpha: 0.24),
            ),
            boxShadow: [
              BoxShadow(
                color: colorScheme.secondary.withValues(alpha: 0.18),
                blurRadius: 20,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.all(2.6.w),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: colorScheme.secondary.withValues(alpha: 0.16),
                    ),
                    child: Icon(
                      Icons.favorite_outline,
                      color: colorScheme.secondary,
                      size: 22,
                    ),
                  ),
                  SizedBox(width: 3.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Support parents with clarity',
                          style: textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: colorScheme.secondary,
                          ),
                        ),
                        SizedBox(height: 1.h),
                        Text(
                          'Families get a compassionate home base with curated updates, therapist messaging, and printable reports for IEP meetings.',
                          style: textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 2.6.h),
              Wrap(
                spacing: 2.4.w,
                runSpacing: 1.2.h,
                children: const [
                  ParentHighlightChip(label: 'Daily progress digest'),
                  ParentHighlightChip(label: 'Secure chat threads'),
                  ParentHighlightChip(label: 'Milestone printables'),
                  ParentHighlightChip(label: 'Care team calendar'),
                ],
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
    final bool isSelected = _selectedRole == role;
    final bool isHovered = _hoveredRole == role;
    final List<String> highlights = role == 'Therapist'
        ? ['Plan sessions', 'Track goals', 'Share notes']
        : ['See daily wins', 'Chat with therapists', 'Printable reports'];

    return MouseRegion(
      onEnter: (_) => setState(() => _hoveredRole = role),
      onExit: (_) => setState(() => _hoveredRole = null),
      child: GestureDetector(
        onTap: () => _selectRole(role),
        child: AnimatedScale(
          scale: isHovered ? 1.02 : 1.0,
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 260),
            curve: Curves.easeOutCubic,
            padding: EdgeInsets.all(5.w),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isSelected
                    ? [color.withValues(alpha: 0.28), color.withValues(alpha: 0.12)]
                    : [color.withValues(alpha: 0.12), Theme.of(context).colorScheme.surface],
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: isSelected || isHovered
                    ? color
                    : color.withValues(alpha: 0.25),
                width: isSelected ? 2.4 : 1.8,
              ),
              boxShadow: [
                if (isSelected || isHovered)
                  BoxShadow(
                    color: color.withValues(alpha: 0.22),
                    blurRadius: 24,
                    offset: const Offset(0, 12),
                  )
                else
                  BoxShadow(
                    color: color.withValues(alpha: 0.08),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
              ],
            ),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned(
                  top: -18,
                  right: -12,
                  child: Icon(
                    icon,
                    size: 20.w,
                    color: color.withValues(alpha: 0.08),
                  ),
                ),
                Column(
                  children: [
                    Container(
                      padding: EdgeInsets.all(4.2.w),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: color.withValues(alpha: 0.18),
                        border: Border.all(
                          color: color.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Icon(
                        icon,
                        size: 14.w,
                        color: color,
                      ),
                    ),
                    SizedBox(height: 2.8.h),
                    Text(
                      role,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: color,
                      ),
                    ),
                    SizedBox(height: 1.6.h),
                    Text(
                      description,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        height: 1.5,
                      ),
                    ),
                    SizedBox(height: 2.2.h),
                    Divider(
                      color: color.withValues(alpha: 0.2),
                      thickness: 1,
                    ),
                    SizedBox(height: 2.2.h),
                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 2.w,
                      runSpacing: 1.2.h,
                      children: highlights
                          .map((label) => _buildMiniTag(label, color))
                          .toList(),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureChip(IconData icon, String label, Color accentColor) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 3.6.w, vertical: 1.0.h),
      decoration: BoxDecoration(
        color: accentColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: accentColor.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: accentColor),
          SizedBox(width: 1.5.w),
          Text(
            label,
            style: textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniTag(String label, Color accentColor) {
    final Color resolvedTextColor = accentColor.computeLuminance() > 0.6
        ? Theme.of(context).colorScheme.onSurface
        : Theme.of(context).colorScheme.onPrimary;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.7.h),
      decoration: BoxDecoration(
        color: accentColor.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          fontWeight: FontWeight.w600,
          color: resolvedTextColor,
        ),
      ),
    );
  }

  void _showRoleOverviewDialog() {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final List<Map<String, String>> roleSummaries = [
      {
        'title': 'Therapists',
        'details': 'Plan structured sessions, capture observations in real time, and instantly share victories with families.',
      },
      {
        'title': 'Parents',
        'details': 'Stay in the loop with daily updates, celebrate progress, and message your care team whenever you need support.',
      },
    ];

  showModalBottomSheet<void>(
      context: context,
      isScrollControlled: false,
      backgroundColor: colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (sheetContext) {
        return Padding(
          padding: EdgeInsets.fromLTRB(
            6.w,
            3.h,
            6.w,
            MediaQuery.of(sheetContext).padding.bottom + 3.h,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Align(
                alignment: Alignment.center,
                child: Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: colorScheme.outline.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(50),
                  ),
                ),
              ),
              SizedBox(height: 3.h),
              Text(
                'Designed for collaborative care',
                textAlign: TextAlign.center,
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 1.2.h),
              Text(
                'Explore how each dashboard keeps care teams and families aligned on progress and wins.',
                textAlign: TextAlign.center,
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  height: 1.45,
                ),
              ),
              SizedBox(height: 3.h),
              ...roleSummaries.map((role) {
                return Padding(
                  padding: EdgeInsets.only(bottom: 2.4.h),
                  child: Container(
                    padding: EdgeInsets.all(3.5.w),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceTint.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: colorScheme.outlineVariant.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          role['title'] ?? '',
                          style: textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: colorScheme.primary,
                          ),
                        ),
                        SizedBox(height: 1.h),
                        Text(
                          role['details'] ?? '',
                          style: textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
              SizedBox(height: 2.4.h),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(sheetContext),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 1.3.h),
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text('Got it, let me choose a role'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRoleSelector() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 1.2.w, vertical: 0.6.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'I am a:',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.2,
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
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeOutCubic,
                    padding: EdgeInsets.symmetric(vertical: 2.4.h, horizontal: 3.w),
                    decoration: BoxDecoration(
                      gradient: _selectedRole == 'Therapist'
                          ? LinearGradient(
                              colors: [
                                Theme.of(context).colorScheme.primary.withValues(alpha: 0.18),
                                Theme.of(context).colorScheme.primary.withValues(alpha: 0.08),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            )
                          : null,
                      color: _selectedRole == 'Therapist'
                          ? null
                          : Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: _selectedRole == 'Therapist'
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.outline.withValues(alpha: 0.25),
                        width: _selectedRole == 'Therapist' ? 2 : 1,
                      ),
                      boxShadow: [
                        if (_selectedRole == 'Therapist')
                          BoxShadow(
                            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.18),
                            blurRadius: 16,
                            offset: const Offset(0, 8),
                          ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.medical_services_outlined,
                          color: _selectedRole == 'Therapist'
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.onSurfaceVariant,
                          size: 7.2.w,
                        ),
                        SizedBox(height: 1.2.h),
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
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeOutCubic,
                    padding: EdgeInsets.symmetric(vertical: 2.4.h, horizontal: 3.w),
                    decoration: BoxDecoration(
                      gradient: _selectedRole == 'Parent'
                          ? LinearGradient(
                              colors: [
                                Theme.of(context).colorScheme.secondary.withValues(alpha: 0.2),
                                Theme.of(context).colorScheme.secondary.withValues(alpha: 0.1),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            )
                          : null,
                      color: _selectedRole == 'Parent'
                          ? null
                          : Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: _selectedRole == 'Parent'
                            ? Theme.of(context).colorScheme.secondary
                            : Theme.of(context).colorScheme.outline.withValues(alpha: 0.25),
                        width: _selectedRole == 'Parent' ? 2 : 1,
                      ),
                      boxShadow: [
                        if (_selectedRole == 'Parent')
                          BoxShadow(
                            color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.2),
                            blurRadius: 16,
                            offset: const Offset(0, 8),
                          ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.family_restroom_outlined,
                          color: _selectedRole == 'Parent'
                              ? Theme.of(context).colorScheme.secondary
                              : Theme.of(context).colorScheme.onSurfaceVariant,
                          size: 7.2.w,
                        ),
                        SizedBox(height: 1.2.h),
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
      ),
    );
  }

  // Missing method implementations
  void _selectRole(String role) {
    setState(() {
      _selectedRole = role;
      _showRoleSelection = false;
    });
    print('Selected role: $role');
  }

  void _goBackToRoleSelection() {
    setState(() {
      _showRoleSelection = true;
    });
    print('Going back to role selection');
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
        final resolvedRole = (result.userRole ?? _selectedRole).trim();

        setState(() {
          _userRole = resolvedRole;
          _showRoleIndicator = true;
          _isLoading = false;
          _showRoleSelection = false;
        });

        if (mounted) {
          _navigateToDashboard(resolvedRole);
        }
      } else {
        setState(() {
          _isLoading = false;
          _showRoleIndicator = false;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Login failed: ${result.errorMessage ?? 'Unknown error'}'),
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

  void _navigateToDashboard(String role) {
    final normalizedRole = role.toLowerCase();
    String targetRoute;

    switch (normalizedRole) {
      case 'parent':
        targetRoute = AppRoutes.parentDashboard;
        break;
      case 'therapist':
        targetRoute = AppRoutes.therapistDashboard;
        break;
      case 'student':
        targetRoute = AppRoutes.studentDashboard;
        break;
      case 'admin':
        targetRoute = AppRoutes.admin;
        break;
      default:
        targetRoute = AppRoutes.therapistDashboard;
        break;
    }

    Navigator.pushNamedAndRemoveUntil(context, targetRoute, (route) => false);
  }

  void _toggleSignUpMode() {
    setState(() {
      _isSignUpMode = !_isSignUpMode;
    });
    print('Toggled sign up mode: $_isSignUpMode');
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
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Theme.of(context).colorScheme.surface,
                            Theme.of(context).colorScheme.surface.withValues(alpha: 0.92),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(
                          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.12),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 32,
                            offset: const Offset(0, 16),
                          ),
                          BoxShadow(
                            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.08),
                            blurRadius: 22,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(28),
                        child: Stack(
                          children: [
                            Positioned(
                              top: -80,
                              right: -60,
                              child: Container(
                                width: 180,
                                height: 180,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: RadialGradient(
                                    colors: [
                                      Theme.of(context).colorScheme.primary.withValues(alpha: 0.18),
                                      Colors.transparent,
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: -60,
                              left: -40,
                              child: Container(
                                width: 140,
                                height: 140,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: RadialGradient(
                                    colors: [
                                      Theme.of(context).colorScheme.secondary.withValues(alpha: 0.16),
                                      Colors.transparent,
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.all(
                                MediaQuery.of(context).size.width < 400 ? 4.w : 6.w,
                              ),
                              child: _showRoleSelection
                                  ? _buildRoleSelectionScreen()
                                  : Column(
                                      crossAxisAlignment: CrossAxisAlignment.stretch,
                                      children: [
                                        Row(
                                          children: [
                                            IconButton(
                                              style: IconButton.styleFrom(
                                                backgroundColor: Theme.of(context)
                                                    .colorScheme
                                                    .primary
                                                    .withValues(alpha: 0.08),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(14),
                                                ),
                                              ),
                                              onPressed: _goBackToRoleSelection,
                                              icon: Icon(
                                                Icons.arrow_back,
                                                color: Theme.of(context).colorScheme.primary,
                                              ),
                                            ),
                                            SizedBox(width: 2.w),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    _isSignUpMode ? 'Create Account' : 'Welcome Back',
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .headlineSmall
                                                        ?.copyWith(
                                                          fontWeight: FontWeight.w600,
                                                        ),
                                                  ),
                                                  SizedBox(height: 0.6.h),
                                                  Text(
                                                    _selectedRole == 'Therapist'
                                                        ? 'Log in to orchestrate care and track progress.'
                                                        : 'Log in to stay close to every milestone.',
                                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                                          color: Theme.of(context)
                                                              .colorScheme
                                                              .onSurfaceVariant,
                                                          height: 1.3,
                                                        ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Container(
                                              padding: EdgeInsets.symmetric(
                                                horizontal: 3.w,
                                                vertical: 1.1.h,
                                              ),
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(24),
                                                gradient: LinearGradient(
                                                  colors: _selectedRole == 'Therapist'
                                                      ? [
                                                          Theme.of(context).colorScheme.primary.withValues(alpha: 0.18),
                                                          Theme.of(context).colorScheme.primary.withValues(alpha: 0.26),
                                                        ]
                                                      : [
                                                          Theme.of(context).colorScheme.secondary.withValues(alpha: 0.18),
                                                          Theme.of(context).colorScheme.secondary.withValues(alpha: 0.26),
                                                        ],
                                                ),
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Icon(
                                                    _selectedRole == 'Therapist'
                                                        ? Icons.medical_services_outlined
                                                        : Icons.family_restroom,
                                                    size: 18,
                                                    color: _selectedRole == 'Therapist'
                                                        ? Theme.of(context).colorScheme.primary
                                                        : Theme.of(context).colorScheme.secondary,
                                                  ),
                                                  SizedBox(width: 1.6.w),
                                                  Text(
                                                    _selectedRole,
                                                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                                          fontWeight: FontWeight.w600,
                                                        ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 3.h),

                                        if (_isSignUpMode) ...[
                                          _buildRoleSelector(),
                                          SizedBox(height: 3.h),
                                        ],

                                        _isSignUpMode
                                            ? SignUpFormWidget(
                                                onSignUp: _handleSignUp,
                                                isLoading: _isLoading,
                                              )
                                            : LoginFormWidget(
                                                onLogin: _handleLogin,
                                                isLoading: _isLoading,
                                              ),

                                        RoleIndicatorWidget(
                                          userRole: _userRole,
                                          isVisible: _showRoleIndicator,
                                        ),
                                      ],
                                    ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: 4.h),

                    // Register/Sign In Link (only show when not in role selection)
                    if (!_showRoleSelection)
                      RegisterLinkWidget(
                        isSignUpMode: _isSignUpMode,
                        onRegisterTap: _toggleSignUpMode,
                      ),

                    SizedBox(height: 2.h),

                    // Admin access button (for development)
                    if (!_showRoleSelection)
                      TextButton(
                        onPressed: () => Navigator.pushNamed(context, '/admin'),
                        child: Text(
                          'Admin Panel',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                            fontSize: 12,
                          ),
                        ),
                      ),

                    SizedBox(height: 2.h),
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

class ParentHighlightChip extends StatelessWidget {
  final String label;

  const ParentHighlightChip({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 3.2.w, vertical: 0.9.h),
      decoration: BoxDecoration(
        color: colorScheme.surface.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: colorScheme.secondary.withValues(alpha: 0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.secondary.withValues(alpha: 0.12),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.check_circle_outline,
            color: colorScheme.secondary,
            size: 18,
          ),
          SizedBox(width: 1.6.w),
          Text(
            label,
            style: textTheme.labelMedium?.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

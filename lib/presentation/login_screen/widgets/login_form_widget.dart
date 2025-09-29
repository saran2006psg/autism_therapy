import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import 'package:thriveers/core/app_export.dart';

class LoginFormWidget extends StatefulWidget {
  final Function(String email, String password) onLogin;
  final bool isLoading;

  const LoginFormWidget({
    super.key,
    required this.onLogin,
    required this.isLoading,
  });

  @override
  State<LoginFormWidget> createState() => _LoginFormWidgetState();
}

class _LoginFormWidgetState extends State<LoginFormWidget> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isFormValid = false;

  @override
  void initState() {
    super.initState();
    _emailController.addListener(_validateForm);
    _passwordController.addListener(_validateForm);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _validateForm() {
    final isValid = _emailController.text.isNotEmpty &&
        _passwordController.text.isNotEmpty &&
        _isValidEmail(_emailController.text);

    if (_isFormValid != isValid) {
      setState(() {
        _isFormValid = isValid;
      });
    }
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required for secure access';
    }
    if (!_isValidEmail(value)) {
      return 'Please enter a valid healthcare professional email';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required for account security';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  void _handleLogin() {
    print('DEBUG: _handleLogin called - Form valid: $_isFormValid');
    if (_formKey.currentState?.validate() ?? false) {
      print('DEBUG: Form validation passed, calling widget.onLogin');
      widget.onLogin(_emailController.text.trim(), _passwordController.text);
    } else {
      print('DEBUG: Form validation failed');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final bool isCompact = MediaQuery.of(context).size.width < 420;

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Sign in to continue',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              letterSpacing: 0.1,
            ),
          ),
          SizedBox(height: 0.8.h),
          Text(
            'Use the credentials provided by the ThrivePath team to access your dashboard.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
              height: 1.4,
            ),
          ),
          SizedBox(height: 3.h),

          _buildFieldContainer(
            context: context,
            child: TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              enabled: !widget.isLoading,
              decoration: _inputDecoration(
                context: context,
                label: 'Work Email',
                hint: 'your.name@careteam.com',
                iconName: 'email',
                accentColor: _isFormValid
                    ? colorScheme.primary
                    : colorScheme.onSurfaceVariant,
              ),
              validator: _validateEmail,
              onFieldSubmitted: (_) => FocusScope.of(context).nextFocus(),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface,
              ),
            ),
          ),

          SizedBox(height: 2.5.h),

          _buildFieldContainer(
            context: context,
            child: TextFormField(
              controller: _passwordController,
              obscureText: !_isPasswordVisible,
              textInputAction: TextInputAction.done,
              enabled: !widget.isLoading,
              decoration: _inputDecoration(
                context: context,
                label: 'Password',
                hint: 'Minimum 6 characters',
                iconName: 'lock',
                accentColor: colorScheme.primary,
              ).copyWith(
                suffixIcon: IconButton(
                  onPressed: widget.isLoading
                      ? null
                      : () {
                          setState(() {
                            _isPasswordVisible = !_isPasswordVisible;
                          });
                        },
                  icon: CustomIconWidget(
                    iconName: _isPasswordVisible ? 'visibility_off' : 'visibility',
                    color: colorScheme.onSurfaceVariant,
                    size: 20,
                  ),
                ),
              ),
              validator: _validatePassword,
              onFieldSubmitted: (_) => _handleLogin(),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface,
              ),
            ),
          ),

          SizedBox(height: 1.4.h),

          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: widget.isLoading
                  ? null
                  : () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Password reset will be available soon.'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
              icon: const Icon(Icons.help_outline, size: 18),
              label: const Text('Forgot password?'),
              style: TextButton.styleFrom(
                foregroundColor: colorScheme.primary,
              ),
            ),
          ),

          SizedBox(height: 3.4.h),

          Builder(
            builder: (context) {
              final bool canSubmit = _isFormValid && !widget.isLoading;
              final Gradient activeGradient = LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  colorScheme.primary,
                  colorScheme.primaryContainer,
                ],
              );

              return AnimatedContainer(
                duration: const Duration(milliseconds: 260),
                height: 6.2.h,
                decoration: BoxDecoration(
                  gradient: canSubmit ? activeGradient : null,
                  color: canSubmit
                      ? null
                      : colorScheme.surfaceVariant.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: canSubmit
                        ? Colors.transparent
                        : colorScheme.outline.withValues(alpha: 0.24),
                  ),
                  boxShadow: canSubmit
                      ? [
                          BoxShadow(
                            color: colorScheme.primary.withValues(alpha: 0.3),
                            blurRadius: 24,
                            offset: const Offset(0, 12),
                          ),
                        ]
                      : [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                ),
                child: ElevatedButton(
                  onPressed: canSubmit ? _handleLogin : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    disabledBackgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 4.w),
                  ),
                  child: widget.isLoading
                      ? SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.6,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              colorScheme.onPrimary,
                            ),
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 38,
                                  height: 38,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: canSubmit
                                        ? colorScheme.onPrimary.withValues(alpha: 0.2)
                                        : colorScheme.onSurfaceVariant
                                            .withValues(alpha: 0.1),
                                  ),
                                  child: Center(
                                    child: CustomIconWidget(
                                      iconName: 'login',
                                      color: canSubmit
                                          ? colorScheme.onPrimary
                                          : colorScheme.onSurfaceVariant,
                                      size: 18,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 3.w),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'Ready to log in?',
                                      style: theme.textTheme.labelSmall?.copyWith(
                                        color: canSubmit
                                            ? colorScheme.onPrimary.withValues(alpha: 0.82)
                                            : colorScheme.onSurfaceVariant,
                                        letterSpacing: 0.3,
                                      ),
                                    ),
                                    Text(
                                      'Sign in',
                                      style: theme.textTheme.titleMedium?.copyWith(
                                        color: canSubmit
                                            ? colorScheme.onPrimary
                                            : colorScheme.onSurfaceVariant,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            Icon(
                              Icons.arrow_forward_rounded,
                              color:
                                  canSubmit ? colorScheme.onPrimary : colorScheme.onSurfaceVariant,
                              size: 22,
                            ),
                          ],
                        ),
                ),
              );
            },
          ),

          SizedBox(height: 3.2.h),
          Container(
            padding: EdgeInsets.all(4.2.w),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  colorScheme.surfaceVariant.withValues(alpha: 0.42),
                  colorScheme.surface,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: colorScheme.outlineVariant.withOpacity(0.18),
              ),
              boxShadow: [
                BoxShadow(
                  color: colorScheme.primary.withOpacity(0.06),
                  blurRadius: 22,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(1.8.w),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: colorScheme.primary.withValues(alpha: 0.12),
                      ),
                      child: Icon(
                        Icons.flash_on_rounded,
                        color: colorScheme.primary,
                        size: 18,
                      ),
                    ),
                    SizedBox(width: 3.w),
                    Expanded(
                      child: Text(
                        'QA helpers for staging only',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 1.4.h),
                Text(
                  'Populate the form instantly while you validate the therapist and parent dashboards. These shortcuts are hidden in production builds.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    height: 1.5,
                  ),
                ),
                SizedBox(height: 2.4.h),
                Wrap(
                  alignment: isCompact ? WrapAlignment.center : WrapAlignment.start,
                  spacing: isCompact ? 2.4.w : 3.2.w,
                  runSpacing: 1.8.h,
                  children: [
                    _buildQuickLoginButton(
                      context,
                      isCompact: isCompact,
                      role: 'Therapist QA',
                      email: 'math@gmail.com',
                      password: 'math123',
                      icon: Icons.psychology_alt_outlined,
                      color: colorScheme.primary,
                    ),
                    _buildQuickLoginButton(
                      context,
                      isCompact: isCompact,
                      role: 'Parent QA',
                      email: 'muni@gmail.com',
                      password: 'muni123',
                      icon: Icons.family_restroom,
                      color: colorScheme.secondary,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickLoginButton(
    BuildContext context, {
    required bool isCompact,
    required String role,
    required String email,
    required String password,
    required IconData icon,
    required Color color,
  }) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: widget.isLoading
          ? null
          : () {
              setState(() {
                _emailController.text = email;
                _passwordController.text = password;
              });
              _validateForm();
              Future.delayed(const Duration(milliseconds: 350), () {
                if (mounted) {
                  _handleLogin();
                }
              });
            },
      child: Container(
        width: isCompact ? double.infinity : null,
        constraints: BoxConstraints(
          minWidth: isCompact ? 0 : 140,
          maxWidth: isCompact ? double.infinity : 200,
        ),
        padding: EdgeInsets.symmetric(
          horizontal: isCompact ? 4.w : 3.4.w,
          vertical: 1.8.h,
        ),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.28)),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.14),
              blurRadius: 14,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(1.2.w),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color.withOpacity(0.18),
              ),
              child: Icon(icon, color: color, size: 18),
            ),
            SizedBox(height: 1.2.h),
            Text(
              role,
              style: theme.textTheme.labelLarge?.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 0.6.h),
            Text(
              email,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({
    required BuildContext context,
    required String label,
    required String hint,
    required String iconName,
    required Color accentColor,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Container(
        padding: EdgeInsets.all(3.w),
        child: CustomIconWidget(
          iconName: iconName,
          color: accentColor,
          size: 20,
        ),
      ),
      filled: true,
      fillColor: colorScheme.surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(
          color: colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(
          color: colorScheme.outlineVariant.withValues(alpha: 0.4),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(
          color: colorScheme.primary,
          width: 2,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(
          color: colorScheme.error,
          width: 2,
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(
          color: colorScheme.error,
          width: 2,
        ),
      ),
      contentPadding: EdgeInsets.symmetric(
        horizontal: 4.w,
        vertical: 2.8.h,
      ),
    );
  }

  Widget _buildFieldContainer({
    required BuildContext context,
    required Widget child,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withValues(alpha: 0.06),
            blurRadius: 18,
            offset: const Offset(0, 12),
          ),
        ],
        gradient: LinearGradient(
          colors: [
            colorScheme.surface,
            colorScheme.surface.withValues(alpha: 0.94),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: child,
    );
  }
}

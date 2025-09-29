import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import 'package:thriveers/core/app_export.dart';
class SignUpFormWidget extends StatefulWidget {
  final Function(String email, String password, String name) onSignUp;
  final bool isLoading;

  const SignUpFormWidget({
    super.key,
    required this.onSignUp,
    required this.isLoading,
  });

  @override
  State<SignUpFormWidget> createState() => _SignUpFormWidgetState();
}

class _SignUpFormWidgetState extends State<SignUpFormWidget> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _nameController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isFormValid = false;

  @override
  void initState() {
    super.initState();
    _emailController.addListener(_validateForm);
    _passwordController.addListener(_validateForm);
    _confirmPasswordController.addListener(_validateForm);
    _nameController.addListener(_validateForm);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _validateForm() {
    final isValid = _emailController.text.isNotEmpty &&
        _passwordController.text.isNotEmpty &&
        _confirmPasswordController.text.isNotEmpty &&
        _nameController.text.isNotEmpty &&
        _isValidEmail(_emailController.text) &&
        _passwordController.text.length >= 6 &&
        _passwordController.text == _confirmPasswordController.text;

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
      return 'Email is required';
    }
    if (!_isValidEmail(value)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != _passwordController.text) {
      return 'Passwords do not match';
    }
    return null;
  }

  String? _validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Name is required';
    }
    if (value.length < 2) {
      return 'Name must be at least 2 characters';
    }
    return null;
  }

  void _handleSignUp() {
    if (_formKey.currentState?.validate() ?? false) {
      widget.onSignUp(
        _emailController.text.trim(),
        _passwordController.text,
        _nameController.text.trim(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final bool isCtaEnabled = _isFormValid && !widget.isLoading;

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 1.2.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Create your ThrivePath account',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 0.8.h),
                Text(
                  'We’ll tailor the experience based on the role you select above.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 3.h),

          _buildFieldContainer(
            context: context,
            child: TextFormField(
              controller: _nameController,
              enabled: !widget.isLoading,
              keyboardType: TextInputType.name,
              textCapitalization: TextCapitalization.words,
              decoration: _inputDecoration(
                context: context,
                label: 'Full name',
                hint: 'How should we greet you?',
                iconName: 'person',
              ),
              validator: _validateName,
            ),
          ),

          SizedBox(height: 2.4.h),

          _buildFieldContainer(
            context: context,
            child: TextFormField(
              controller: _emailController,
              enabled: !widget.isLoading,
              keyboardType: TextInputType.emailAddress,
              autocorrect: false,
              decoration: _inputDecoration(
                context: context,
                label: 'Work email',
                hint: 'name@careteam.com',
                iconName: 'email',
              ),
              validator: _validateEmail,
            ),
          ),

          SizedBox(height: 2.4.h),

          _buildFieldContainer(
            context: context,
            child: TextFormField(
              controller: _passwordController,
              enabled: !widget.isLoading,
              obscureText: !_isPasswordVisible,
              decoration: _inputDecoration(
                context: context,
                label: 'Password',
                hint: 'Minimum 6 characters',
                iconName: 'lock',
              ).copyWith(
                suffixIcon: IconButton(
                  icon: CustomIconWidget(
                    iconName: _isPasswordVisible ? 'visibility_off' : 'visibility',
                    color: colorScheme.onSurfaceVariant,
                  ),
                  onPressed: () {
                    setState(() {
                      _isPasswordVisible = !_isPasswordVisible;
                    });
                  },
                ),
              ),
              validator: _validatePassword,
            ),
          ),

          SizedBox(height: 2.4.h),

          _buildFieldContainer(
            context: context,
            child: TextFormField(
              controller: _confirmPasswordController,
              enabled: !widget.isLoading,
              obscureText: !_isConfirmPasswordVisible,
              decoration: _inputDecoration(
                context: context,
                label: 'Confirm password',
                hint: 'Re-enter password',
                iconName: 'lock',
              ).copyWith(
                suffixIcon: IconButton(
                  icon: CustomIconWidget(
                    iconName:
                        _isConfirmPasswordVisible ? 'visibility_off' : 'visibility',
                    color: colorScheme.onSurfaceVariant,
                  ),
                  onPressed: () {
                    setState(() {
                      _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                    });
                  },
                ),
              ),
              validator: _validateConfirmPassword,
            ),
          ),

          SizedBox(height: 3.4.h),

          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            height: 6.2.h,
            decoration: BoxDecoration(
              gradient: isCtaEnabled
                  ? LinearGradient(
                      colors: [
                        colorScheme.secondary,
                        colorScheme.primary,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : null,
              color: isCtaEnabled
                  ? null
                  : colorScheme.surfaceVariant.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isCtaEnabled
                    ? Colors.transparent
                    : colorScheme.outlineVariant.withValues(alpha: 0.24),
              ),
              boxShadow: isCtaEnabled
                  ? [
                      BoxShadow(
                        color: colorScheme.secondary.withValues(alpha: 0.28),
                        blurRadius: 20,
                        offset: const Offset(0, 12),
                      ),
                    ]
                  : [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 6),
                      ),
                    ],
            ),
            child: ElevatedButton(
              onPressed: isCtaEnabled ? _handleSignUp : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                disabledBackgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                padding: EdgeInsets.symmetric(horizontal: 4.w),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: widget.isLoading
                  ? SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.4,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          colorScheme.onPrimary,
                        ),
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 38,
                              height: 38,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isCtaEnabled
                                    ? colorScheme.onPrimary.withValues(alpha: 0.22)
                                    : colorScheme.onSurfaceVariant
                                        .withValues(alpha: 0.12),
                              ),
                              child: Center(
                                child: CustomIconWidget(
                                  iconName: 'auto_awesome',
                                  color: isCtaEnabled
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
                                  'One last step',
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: isCtaEnabled
                                        ? colorScheme.onPrimary.withValues(alpha: 0.82)
                                        : colorScheme.onSurfaceVariant,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                                Text(
                                  'Create account',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    color: isCtaEnabled
                                        ? colorScheme.onPrimary
                                        : colorScheme.onSurfaceVariant,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.4,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isCtaEnabled
                                ? colorScheme.onPrimary.withValues(alpha: 0.18)
                                : colorScheme.onSurfaceVariant.withValues(alpha: 0.1),
                          ),
                          child: Icon(
                            Icons.arrow_forward_rounded,
                            size: 20,
                            color: isCtaEnabled
                                ? colorScheme.onPrimary
                                : colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration({
    required BuildContext context,
    required String label,
    required String hint,
    required String iconName,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Container(
        padding: EdgeInsets.all(3.w),
        child: CustomIconWidget(
          iconName: iconName,
          color: colorScheme.primary,
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
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorScheme.surface,
            colorScheme.surface.withValues(alpha: 0.94),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withValues(alpha: 0.05),
            blurRadius: 18,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: child,
    );
  }
}

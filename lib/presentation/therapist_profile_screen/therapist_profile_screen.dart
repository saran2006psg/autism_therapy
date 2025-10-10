import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;

import 'package:thriveers/core/app_export.dart';
import 'package:thriveers/core/services/image_upload_service.dart';
import 'package:thriveers/widgets/navigation/therapist_bottom_navigation.dart';

class TherapistProfileScreen extends StatefulWidget {
  const TherapistProfileScreen({super.key});

  @override
  State<TherapistProfileScreen> createState() => _TherapistProfileScreenState();
}

class _TherapistProfileScreenState extends State<TherapistProfileScreen> 
    with TickerProviderStateMixin {
  bool _isLoading = false;
  final DataService _dataService = DataService();
  bool _isInitialized = false;
  late AnimationController _headerAnimationController;
  late AnimationController _floatingController;
  late Animation<double> _headerAnimation;
  late Animation<double> _floatingAnimation;

  @override
  void initState() {
    super.initState();
    _headerAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _floatingController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
    
    _headerAnimation = CurvedAnimation(
      parent: _headerAnimationController,
      curve: Curves.elasticOut,
    );
    
    _floatingAnimation = Tween<double>(begin: -10, end: 10).animate(
      CurvedAnimation(parent: _floatingController, curve: Curves.easeInOut),
    );
    
    _headerAnimationController.forward();
    _initializeDataService();
  }

  @override
  void dispose() {
    _headerAnimationController.dispose();
    _floatingController.dispose();
    super.dispose();
  }

  Future<void> _initializeDataService() async {
    try {
      if (!_dataService.isInitialized) {
        await _dataService.initialize();
      }
      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isInitialized = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to initialize: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Show loading if not initialized
    if (!_isInitialized) {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          title: Text(
            'My Profile',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    
    return Consumer<DataService>(
      builder: (context, dataService, child) {
        final currentUserProfile = dataService.currentUserProfile;
        final displayName = currentUserProfile?['displayName'] as String? ?? 'Dr. Therapist';
        final avatarUrl = dataService.currentUserAvatarUrl;
        final email = currentUserProfile?['email'] as String? ?? 'therapist@example.com';
        
        return Scaffold(
          extendBody: true,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: AppBar(
            elevation: 0,
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            title: Text(
              'My Profile',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
            ),
            actions: [
              IconButton(
                onPressed: _isLoading ? null : _onEditMyProfile,
                icon: _isLoading
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      )
                    : CustomIconWidget(
                        iconName: 'edit',
                        color: Theme.of(context).colorScheme.primary,
                      ),
              ),
            ],
          ),
          body: Stack(
            children: [
              // Animated Background
              ..._buildAnimatedBackground(),
              
              // Main Content
              SingleChildScrollView(
                padding: EdgeInsets.all(4.w),
                child: Column(
                  children: [
                    // Profile Header with crazy animations
                    ScaleTransition(
                      scale: _headerAnimation,
                      child: AnimatedBuilder(
                        animation: _floatingAnimation,
                        builder: (context, child) {
                          return Transform.translate(
                            offset: Offset(0, _floatingAnimation.value),
                            child: child,
                          );
                        },
                        child: Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(6.w),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                const Color(0xFF6A11CB),
                                const Color(0xFF2575FC),
                                Theme.of(context).colorScheme.primary,
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF6A11CB).withOpacity(0.4),
                                blurRadius: 30,
                                offset: const Offset(0, 15),
                                spreadRadius: 5,
                              ),
                              BoxShadow(
                                color: const Color(0xFF2575FC).withOpacity(0.3),
                                blurRadius: 20,
                                offset: const Offset(-10, -10),
                              ),
                            ],
                          ),
                          child: Stack(
                            children: [
                              // Decorative elements
                              Positioned(
                                top: -20,
                                right: -20,
                                child: Container(
                                  width: 100,
                                  height: 100,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white.withOpacity(0.1),
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom: -30,
                                left: -30,
                                child: Container(
                                  width: 80,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white.withOpacity(0.1),
                                  ),
                                ),
                              ),
                              
                              // Profile Content
                              Column(
                                children: [
                                  // Avatar with glow effect
                                  Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      // Outer glow rings
                                      for (var i = 0; i < 3; i++)
                                        Container(
                                          width: 32.w + (i * 4.w),
                                          height: 32.w + (i * 4.w),
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: Colors.white.withOpacity(0.3 - (i * 0.1)),
                                              width: 2,
                                            ),
                                          ),
                                        ),
                                      
                                      // Main avatar container
                                      Container(
                                        padding: EdgeInsets.all(1.w),
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          gradient: const LinearGradient(
                                            colors: [
                                              Color(0xFFFFD700),
                                              Color(0xFFFFAA00),
                                              Color(0xFFFF6B6B),
                                            ],
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.amber.withOpacity(0.6),
                                              blurRadius: 20,
                                              spreadRadius: 3,
                                            ),
                                          ],
                                        ),
                                        child: CircleAvatar(
                                          radius: 14.w,
                                          backgroundColor: Colors.white,
                                          child: _isLoading
                                              ? const CircularProgressIndicator(
                                                  color: Color(0xFF6A11CB),
                                                  strokeWidth: 3,
                                                )
                                              : avatarUrl != null
                                                  ? ClipRRect(
                                                      borderRadius: BorderRadius.circular(14.w),
                                                      child: Image.network(
                                                        avatarUrl,
                                                        width: 28.w,
                                                        height: 28.w,
                                                        fit: BoxFit.cover,
                                                        errorBuilder: (context, error, stackTrace) {
                                                          return const CustomIconWidget(
                                                            iconName: 'person',
                                                            color: Color(0xFF6A11CB),
                                                            size: 60,
                                                          );
                                                        },
                                                      ),
                                                    )
                                                  : const CustomIconWidget(
                                                      iconName: 'person',
                                                      color: Color(0xFF6A11CB),
                                                      size: 60,
                                                    ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  
                                  SizedBox(height: 3.h),
                                  
                                  // Name with gradient text effect
                                  ShaderMask(
                                    shaderCallback: (bounds) => const LinearGradient(
                                      colors: [
                                        Colors.white,
                                        Color(0xFFFFD700),
                                        Colors.white,
                                      ],
                                    ).createShader(bounds),
                                    child: Text(
                                      displayName,
                                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w900,
                                            letterSpacing: 1.5,
                                            shadows: [
                                              Shadow(
                                                color: Colors.black.withOpacity(0.3),
                                                offset: const Offset(2, 2),
                                                blurRadius: 8,
                                              ),
                                            ],
                                          ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  
                                  SizedBox(height: 1.h),
                                  
                                  // Email with icon
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const CustomIconWidget(
                                        iconName: 'email',
                                        color: Colors.white70,
                                        size: 16,
                                      ),
                                      SizedBox(width: 2.w),
                                      Flexible(
                                        child: Text(
                                          email,
                                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                                color: Colors.white.withOpacity(0.95),
                                                fontWeight: FontWeight.w500,
                                              ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                  
                                  SizedBox(height: 2.h),
                                  
                                  // Role badge with 3D effect
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 6.w,
                                      vertical: 1.5.h,
                                    ),
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [
                                          Color(0xFFFF6B6B),
                                          Color(0xFFFF8E53),
                                          Color(0xFFFECA57),
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(20),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.3),
                                          blurRadius: 10,
                                          offset: const Offset(0, 5),
                                        ),
                                        BoxShadow(
                                          color: const Color(0xFFFECA57).withOpacity(0.5),
                                          blurRadius: 15,
                                          offset: const Offset(0, 8),
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const CustomIconWidget(
                                          iconName: 'psychology',
                                          color: Colors.white,
                                          size: 20,
                                        ),
                                        SizedBox(width: 2.w),
                                        Text(
                                          'Autism Spectrum Therapist',
                                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w700,
                                                letterSpacing: 0.5,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    
                    SizedBox(height: 4.h),
                    
                    // Stats cards
                    Row(
                      children: [
                        Expanded(child: _buildStatCard('125', 'Sessions', Colors.purple, Icons.event_available)),
                        SizedBox(width: 3.w),
                        Expanded(child: _buildStatCard('48', 'Students', Colors.orange, Icons.people)),
                        SizedBox(width: 3.w),
                        Expanded(child: _buildStatCard('98%', 'Success', Colors.green, Icons.trending_up)),
                      ],
                    ),
                    
                    SizedBox(height: 4.h),
                    
                    // Profile Options with staggered animations
                    _buildProfileOption(
                      icon: 'person',
                      title: 'Personal Information',
                      subtitle: 'Update your profile details',
                      gradient: const [Color(0xFF667EEA), Color(0xFF764BA2)],
                      delay: 0,
                      onTap: () {},
                    ),
                    
                    _buildProfileOption(
                      icon: 'security',
                      title: 'Security & Privacy',
                      subtitle: 'Manage password and privacy settings',
                      gradient: const [Color(0xFFF093FB), Color(0xFFF5576C)],
                      delay: 100,
                      onTap: () {},
                    ),
                    
                    _buildProfileOption(
                      icon: 'notifications',
                      title: 'Notifications',
                      subtitle: 'Configure notification preferences',
                      gradient: const [Color(0xFF4FACFE), Color(0xFF00F2FE)],
                      delay: 200,
                      onTap: () {},
                    ),
                    
                    _buildProfileOption(
                      icon: 'help',
                      title: 'Help & Support',
                      subtitle: 'Get help and contact support',
                      gradient: const [Color(0xFF43E97B), Color(0xFF38F9D7)],
                      delay: 300,
                      onTap: () {},
                    ),
                    
                    _buildProfileOption(
                      icon: 'info',
                      title: 'About',
                      subtitle: 'App version and information',
                      gradient: const [Color(0xFFFA709A), Color(0xFFFEE140)],
                      delay: 400,
                      onTap: _showAboutDialog,
                    ),
                    
                    SizedBox(height: 4.h),
                    
                    // Logout Button with gradient and animation
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.0, end: 1.0),
                      duration: const Duration(milliseconds: 800),
                      curve: Curves.elasticOut,
                      builder: (context, value, child) {
                        return Transform.scale(
                          scale: value,
                          child: child,
                        );
                      },
                      child: Container(
                        width: double.infinity,
                        margin: EdgeInsets.symmetric(vertical: 2.h),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFFEB3349),
                              Color(0xFFF45C43),
                              Color(0xFFFF6B6B),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFEB3349).withOpacity(0.5),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(20),
                            onTap: _isLoading ? null : _logout,
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 2.h),
                              child: _isLoading
                                  ? const Center(
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 3,
                                      ),
                                    )
                                  : Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        const CustomIconWidget(
                                          iconName: 'logout',
                                          color: Colors.white,
                                          size: 24,
                                        ),
                                        SizedBox(width: 3.w),
                                        Text(
                                          'Logout',
                                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w700,
                                                letterSpacing: 1.2,
                                              ),
                                        ),
                                      ],
                                    ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    
                    SizedBox(height: 12.h),
                  ],
                ),
              ),
            ],
          ),
          bottomNavigationBar: const TherapistBottomNavigation(
            currentItem: TherapistNavItem.profile,
          ),
        );
      },
    );
  }

  List<Widget> _buildAnimatedBackground() {
    return [
      // Animated gradient blobs
      Positioned(
        top: -50,
        left: -50,
        child: AnimatedBuilder(
          animation: _floatingController,
          builder: (context, child) {
            return Transform.rotate(
              angle: _floatingController.value * 2 * math.pi,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFF667EEA).withOpacity(0.3),
                      const Color(0xFF667EEA).withOpacity(0.0),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
      Positioned(
        bottom: -80,
        right: -80,
        child: AnimatedBuilder(
          animation: _floatingController,
          builder: (context, child) {
            return Transform.rotate(
              angle: -_floatingController.value * 2 * math.pi,
              child: Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFF2575FC).withOpacity(0.3),
                      const Color(0xFF2575FC).withOpacity(0.0),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    ];
  }

  Widget _buildStatCard(String value, String label, Color color, IconData icon) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOutBack,
      builder: (context, scale, child) {
        return Transform.scale(
          scale: scale,
          child: Container(
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  color.withOpacity(0.8),
                  color,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.4),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              children: [
                Icon(icon, color: Colors.white, size: 32),
                SizedBox(height: 1.h),
                Text(
                  value,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                      ),
                ),
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.white.withOpacity(0.9),
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProfileOption({
    required String icon,
    required String title,
    required String subtitle,
    required List<Color> gradient,
    required int delay,
    required VoidCallback onTap,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 500 + delay),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(50 * (1 - value), 0),
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 2.h),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: gradient[0].withOpacity(0.4),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: onTap,
            child: Padding(
              padding: EdgeInsets.all(4.w),
              child: Row(
                children: [
                  // Icon container with white background
                  Container(
                    padding: EdgeInsets.all(3.w),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: CustomIconWidget(
                      iconName: icon,
                      color: gradient[0],
                      size: 28,
                    ),
                  ),
                  SizedBox(width: 4.w),
                  
                  // Text content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                letterSpacing: 0.5,
                              ),
                        ),
                        SizedBox(height: 0.5.h),
                        Text(
                          subtitle,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.white.withOpacity(0.9),
                                fontWeight: FontWeight.w500,
                              ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Arrow icon
                  Container(
                    padding: EdgeInsets.all(2.w),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const CustomIconWidget(
                      iconName: 'arrow_forward_ios',
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showAboutDialog() {
    showDialog<void>(
      context: context,
      barrierColor: Colors.black.withOpacity(0.7),
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: EdgeInsets.all(6.w),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color(0xFF667EEA),
                Color(0xFF764BA2),
                Color(0xFF6A11CB),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF667EEA).withOpacity(0.5),
                blurRadius: 30,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // App icon with glow
              Container(
                padding: EdgeInsets.all(4.w),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.amber.withOpacity(0.6),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: const CustomIconWidget(
                  iconName: 'favorite',
                  color: Color(0xFF6A11CB),
                  size: 50,
                ),
              ),
              
              SizedBox(height: 3.h),
              
              // Title with gradient
              ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [Colors.white, Color(0xFFFFD700), Colors.white],
                ).createShader(bounds),
                child: Text(
                  'About Thriveers',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.5,
                      ),
                ),
              ),
              
              SizedBox(height: 2.h),
              
              // Version badge
              Container(
                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.white.withOpacity(0.3), width: 2),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CustomIconWidget(
                      iconName: 'stars',
                      color: Colors.amber,
                      size: 20,
                    ),
                    SizedBox(width: 2.w),
                    Text(
                      'Version 1.0.0',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                  ],
                ),
              ),
              
              SizedBox(height: 2.h),
              
              // Description
              Text(
                'Thriveers is designed to help therapists manage autism therapy sessions and track student progress with ease and efficiency.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white.withOpacity(0.95),
                      height: 1.5,
                      fontWeight: FontWeight.w500,
                    ),
                textAlign: TextAlign.center,
              ),
              
              SizedBox(height: 3.h),
              
              // OK button
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFFD700), Color(0xFFFFAA00)],
                  ),
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.amber.withOpacity(0.5),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(15),
                    onTap: () => Navigator.pop(context),
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 1.5.h),
                      child: Text(
                        'OK',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: const Color(0xFF6A11CB),
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.5,
                            ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _onEditMyProfile() async {
    if (!_isInitialized || _dataService.currentUserId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile service not ready. Please try again.')),
      );
      return;
    }

    final currentName = _dataService.currentUserProfile?['displayName'] as String? ?? '';
    final controller = TextEditingController(text: currentName);

    await showDialog<void>(
      context: context,
      barrierColor: Colors.black.withOpacity(0.7),
      builder: (ctx) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: EdgeInsets.all(6.w),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF4FACFE),
                  Color(0xFF00F2FE),
                  Color(0xFF43E97B),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF4FACFE).withOpacity(0.5),
                  blurRadius: 30,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Title
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CustomIconWidget(
                      iconName: 'edit',
                      color: Colors.white,
                      size: 28,
                    ),
                    SizedBox(width: 2.w),
                    Text(
                      'Edit Profile',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.2,
                          ),
                    ),
                  ],
                ),
                
                SizedBox(height: 3.h),
                
                // Text field with fancy styling
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: controller,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                    decoration: InputDecoration(
                      labelText: 'Display name',
                      labelStyle: const TextStyle(
                        color: Color(0xFF4FACFE),
                        fontWeight: FontWeight.w600,
                      ),
                      prefixIcon: const Icon(
                        Icons.person,
                        color: Color(0xFF4FACFE),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: EdgeInsets.all(4.w),
                    ),
                  ),
                ),
                
                SizedBox(height: 2.h),
                
                // Change photo button
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.5),
                      width: 2,
                    ),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(15),
                      onTap: _onChangeAvatarTapped,
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 1.5.h),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const CustomIconWidget(
                              iconName: 'photo_camera',
                              color: Colors.white,
                              size: 24,
                            ),
                            SizedBox(width: 2.w),
                            Text(
                              'Change photo',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                
                SizedBox(height: 3.h),
                
                // Buttons row
                Row(
                  children: [
                    // Cancel button
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(15),
                            onTap: () => Navigator.of(ctx).pop(),
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 1.5.h),
                              child: Text(
                                'Cancel',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                    ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    
                    SizedBox(width: 3.w),
                    
                    // Save button
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFFFD700), Color(0xFFFFAA00)],
                          ),
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.amber.withOpacity(0.5),
                              blurRadius: 15,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(15),
                            onTap: () async {
                              final newName = controller.text.trim();
                              Navigator.of(ctx).pop();
                              if (newName.isEmpty) return;
                              
                              setState(() {
                                _isLoading = true;
                              });
                              
                              try {
                                // Update Firestore/profile store
                                await _dataService.updateMyProfile({'displayName': newName});
                                // Update Firebase Auth for immediate UI reflection
                                await FirebaseAuth.instance.currentUser?.updateDisplayName(newName);
                                await FirebaseAuth.instance.currentUser?.reload();
                                if (!mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Row(
                                      children: [
                                        const Icon(Icons.check_circle, color: Colors.white),
                                        SizedBox(width: 2.w),
                                        const Text('Profile updated successfully!'),
                                      ],
                                    ),
                                    backgroundColor: Colors.green,
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                );
                              } catch (e) {
                                if (!mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Failed to update: $e'),
                                    backgroundColor: Colors.red,
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                );
                              } finally {
                                if (mounted) {
                                  setState(() {
                                    _isLoading = false;
                                  });
                                }
                              }
                            },
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 1.5.h),
                              child: Text(
                                'Save',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w900,
                                    ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _onChangeAvatarTapped() async {
    if (!_isInitialized || _dataService.currentUserId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile service not ready. Please try again.')),
      );
      return;
    }

    try {
      setState(() {
        _isLoading = true;
      });

      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: ImageSource.gallery, 
        imageQuality: 85,
        maxWidth: 800,
        maxHeight: 800,
      );
      
      if (picked == null) {
        setState(() {
          _isLoading = false;
        });
        return;
      }

      final uid = _dataService.currentUserId!;
      
      // Show uploading message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Uploading photo...'),
          duration: Duration(seconds: 3),
        ),
      );

      // Use the new web-compatible upload service
      final downloadUrl = await ImageUploadService.uploadUserAvatar(
        userId: uid,
        imageFile: picked,
      );

      // Update both Firestore and Firebase Auth
      await Future.wait([
        _dataService.updateMyProfile({'avatarUrl': downloadUrl}),
        FirebaseAuth.instance.currentUser?.updatePhotoURL(downloadUrl) ?? Future<void>.value(),
      ]);
      
      // Reload user to get updated data
      await FirebaseAuth.instance.currentUser?.reload();

      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile photo updated successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update photo: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _logout() async {
    try {
      await AppResetUtility.resetAndNavigateToLogin(
        context,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error logging out: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }
}



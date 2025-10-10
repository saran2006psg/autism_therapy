import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import 'package:thriveers/core/app_export.dart';

enum TherapistNavItem {
  dashboard,
  sessions,
  students,
  profile,
}

class TherapistBottomNavigation extends StatelessWidget {
  final TherapistNavItem currentItem;

  const TherapistBottomNavigation({
    super.key,
    required this.currentItem,
  });

  static const _items = [
    _TherapistNavMeta(
      item: TherapistNavItem.dashboard,
      label: 'Dashboard',
      icon: 'dashboard',
    ),
    _TherapistNavMeta(
      item: TherapistNavItem.sessions,
      label: 'Sessions',
      icon: 'calendar_month',
    ),
    _TherapistNavMeta(
      item: TherapistNavItem.students,
      label: 'Students',
      icon: 'groups',
    ),
    _TherapistNavMeta(
      item: TherapistNavItem.profile,
      label: 'Profile',
      icon: 'account_circle',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final currentIndex = _items.indexWhere((meta) => meta.item == currentItem);
    final bottomInset = MediaQuery.of(context).padding.bottom;
    final baseBottomPadding = 0.8.h;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        2.6.w,
        0,
        2.6.w,
        bottomInset > 0 ? bottomInset + baseBottomPadding : baseBottomPadding + 0.6.h,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: colorScheme.surface.withValues(alpha: 0.82),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 14,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: BottomNavigationBar(
              elevation: 0,
              backgroundColor: Colors.transparent,
              type: BottomNavigationBarType.fixed,
              currentIndex: currentIndex < 0 ? 0 : currentIndex,
              selectedItemColor: colorScheme.primary,
              unselectedItemColor: colorScheme.onSurfaceVariant,
              selectedFontSize: 10.sp,
              unselectedFontSize: 9.6.sp,
              selectedLabelStyle: textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
              unselectedLabelStyle: textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w500,
              ),
              items: _items
                  .map((meta) => _buildNavItem(
                        context: context,
                        meta: meta,
                        isSelected: meta.item == currentItem,
                      ))
                  .toList(),
              onTap: (index) {
                if (index < 0 || index >= _items.length) return;
                final target = _items[index].item;
                if (target == currentItem) {
                  return;
                }
                TherapistNavigationHelper.navigateTo(context, target);
              },
            ),
          ),
        ),
      ),
    );
  }

  BottomNavigationBarItem _buildNavItem({
    required BuildContext context,
    required _TherapistNavMeta meta,
    required bool isSelected,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return BottomNavigationBarItem(
      icon: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
        padding: EdgeInsets.symmetric(
          horizontal: 3.w,
          vertical: 1.2.h,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? colorScheme.primary.withValues(alpha: 0.16)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: CustomIconWidget(
          iconName: meta.icon,
          color: isSelected ? colorScheme.primary : colorScheme.onSurfaceVariant,
          size: 4.6.w,
        ),
      ),
      label: meta.label,
    );
  }
}

class TherapistNavigationHelper {
  static void navigateTo(BuildContext context, TherapistNavItem destination) {
    final currentRoute = ModalRoute.of(context)?.settings.name;
    final targetRoute = _routeFor(destination);

    if (currentRoute == targetRoute) {
      return;
    }

    final navigator = Navigator.of(context);

    if (destination == TherapistNavItem.dashboard) {
      navigator.pushNamedAndRemoveUntil(
        AppRoutes.therapistDashboard,
        (route) => route.isFirst,
      );
      return;
    }

    navigator.pushNamedAndRemoveUntil(
      targetRoute,
      (route) {
        final name = route.settings.name;
        return name == AppRoutes.therapistDashboard || route.isFirst;
      },
    );
  }

  static String _routeFor(TherapistNavItem item) {
    switch (item) {
      case TherapistNavItem.dashboard:
        return AppRoutes.therapistDashboard;
      case TherapistNavItem.sessions:
        return AppRoutes.sessionPlanning;
      case TherapistNavItem.students:
        return AppRoutes.studentsList;
      case TherapistNavItem.profile:
        return AppRoutes.therapistProfile;
    }
  }
}

class _TherapistNavMeta {
  final TherapistNavItem item;
  final String label;
  final String icon;

  const _TherapistNavMeta({
    required this.item,
    required this.label,
    required this.icon,
  });
}

import 'package:flutter/material.dart';
import 'package:thriveers/presentation/session_planning_screen/session_planning_screen.dart';
import 'package:thriveers/presentation/login_screen/login_screen.dart';
import 'package:thriveers/presentation/student_profile_management_screen/student_profile_management_screen.dart';
import 'package:thriveers/presentation/therapist_dashboard/therapist_dashboard.dart';
import 'package:thriveers/presentation/parent_dashboard/parent_dashboard.dart';
import 'package:thriveers/presentation/session_execution_screen/session_execution_screen.dart';
import 'package:thriveers/presentation/profile_buddy_screen/profile_buddy_screen.dart';
import 'package:thriveers/presentation/students_list_screen/students_list_screen.dart';
import 'package:thriveers/presentation/therapist_profile_screen/therapist_profile_screen.dart';
import 'package:thriveers/presentation/forms/add_student_form.dart';
import 'package:thriveers/presentation/settings_screen/settings_screen.dart';
// import 'package:thriveers/presentation/student_login/student_login_screen.dart';
// import 'package:thriveers/presentation/student_dashboard/student_dashboard.dart';
import 'package:thriveers/presentation/admin_screen/admin_screen.dart';

class AppRoutes {
  // Route constants for navigation throughout the app
  static const String initial = '/';
  static const String sessionPlanning = '/session-planning-screen';
  static const String login = '/login-screen';
  static const String studentProfileManagement =
      '/student-profile-management-screen';
  static const String therapistDashboard = '/therapist-dashboard';
  static const String parentDashboard = '/parent-dashboard';
  static const String sessionExecution = '/session-execution-screen';
  static const String profileBuddy = '/profile-buddy';
  static const String studentsList = '/students-list';
  static const String therapistProfile = '/therapist-profile';
  static const String addStudentForm = '/add-student-form';
  static const String settings = '/settings';
  // static const String studentLogin = '/student-login';
  // static const String studentDashboard = '/student-dashboard';
  static const String admin = '/admin';

  static Map<String, WidgetBuilder> routes = {
    initial: (context) => const LoginScreen(),
    sessionPlanning: (context) => const SessionPlanningScreen(),
    login: (context) => const LoginScreen(),
    studentProfileManagement: (context) =>
        const StudentProfileManagementScreen(),
    therapistDashboard: (context) => const TherapistDashboard(),
    parentDashboard: (context) => const ParentDashboard(),
    sessionExecution: (context) => const SessionExecutionScreen(),
    profileBuddy: (context) => const ProfileBuddyScreen(),
    studentsList: (context) => const StudentsListScreen(),
    therapistProfile: (context) => const TherapistProfileScreen(),
    addStudentForm: (context) => const AddStudentForm(),
    settings: (context) => const SettingsScreen(),
    // studentLogin: (context) => const StudentLoginScreen(),
    // studentDashboard: (context) => const StudentDashboard(),
    admin: (context) => const AdminScreen(),
    // Additional routes can be added here as the app expands
  };
}

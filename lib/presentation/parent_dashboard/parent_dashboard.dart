import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../widgets/theme_toggle_widget.dart';
import './widgets/child_header_widget.dart';
import './widgets/communication_card_widget.dart';
import './widgets/empty_state_widget.dart';
import './widgets/homework_card_widget.dart';
import './widgets/progress_chart_widget.dart';
import './widgets/session_summary_card_widget.dart';
import './widgets/upcoming_session_card_widget.dart';

class ParentDashboard extends StatefulWidget {
  const ParentDashboard({super.key});

  @override
  State<ParentDashboard> createState() => _ParentDashboardState();
}

class _ParentDashboardState extends State<ParentDashboard>
    with TickerProviderStateMixin {
  late TabController _tabController;
  String _lastSyncTime = "2 minutes ago";
  final int _unreadMessages = 3;

  // Mock data for child information
  final Map<String, dynamic> _childData = {
    "id": "child_001",
    "name": "Emma Johnson",
    "age": 8,
    "diagnosis": "ASD Level 2",
    "photo":
        "https://images.pexels.com/photos/1620760/pexels-photo-1620760.jpeg?auto=compress&cs=tinysrgb&w=400",
    "currentGoals": [
      {
        "id": "goal_001",
        "title": "Improve social communication skills",
        "progress": 75.0,
      },
      {
        "id": "goal_002",
        "title": "Develop emotional regulation strategies",
        "progress": 68.0,
      },
      {
        "id": "goal_003",
        "title": "Enhance fine motor coordination",
        "progress": 82.0,
      },
    ],
  };

  // Mock data for session summaries
  final List<Map<String, dynamic>> _sessionSummaries = [
    {
      "id": "session_001",
      "type": "Speech Therapy",
      "date": "Aug 12, 2025",
      "therapist": "Dr. Sarah Mitchell",
      "duration": 45,
      "status": "Completed",
      "summary":
          "Emma showed excellent progress in verbal communication today. She successfully completed 8 out of 10 social interaction exercises and demonstrated improved eye contact during conversations.",
      "achievements": [
        "Maintained eye contact for 15+ seconds during conversation",
        "Used 'please' and 'thank you' appropriately in 9/10 instances",
        "Successfully initiated conversation with peer during group activity",
      ],
      "areasForImprovement": [
        "Continue working on turn-taking in group discussions",
        "Practice using indoor voice in quiet environments",
      ],
    },
    {
      "id": "session_002",
      "type": "Occupational Therapy",
      "date": "Aug 10, 2025",
      "therapist": "Ms. Jennifer Adams",
      "duration": 60,
      "status": "Completed",
      "summary":
          "Focused on fine motor skills development through structured play activities. Emma demonstrated improved pencil grip and completed writing exercises with minimal assistance.",
      "achievements": [
        "Improved pencil grip stability by 40%",
        "Completed 15-minute writing task without breaks",
        "Successfully used scissors to cut along curved lines",
      ],
      "areasForImprovement": [
        "Continue strengthening hand muscles through play activities",
        "Practice letter formation for lowercase letters",
      ],
    },
    {
      "id": "session_003",
      "type": "Behavioral Therapy",
      "date": "Aug 8, 2025",
      "therapist": "Dr. Michael Rodriguez",
      "duration": 50,
      "status": "Completed",
      "summary":
          "Emma worked on emotional regulation techniques and coping strategies. She successfully used breathing exercises during a challenging task and showed improved frustration tolerance.",
      "achievements": [
        "Used deep breathing technique independently 3 times",
        "Completed challenging puzzle without meltdown",
        "Asked for help appropriately when feeling overwhelmed",
      ],
      "areasForImprovement": [
        "Continue practicing calming strategies at home",
        "Work on identifying emotions before they escalate",
      ],
    },
  ];

  // Mock data for homework assignments
  final List<Map<String, dynamic>> _homeworkData = [
    {
      "id": "homework_001",
      "title": "Daily Communication Practice",
      "description":
          "Practice greeting family members and asking about their day using complete sentences.",
      "dueDate": "Aug 15, 2025",
      "assignedBy": "Dr. Sarah Mitchell",
      "requiresEvidence": true,
      "activities": [
        {
          "id": "activity_001",
          "title": "Morning greetings with family",
          "description": "Say 'Good morning' and ask one question",
          "completed": true,
        },
        {
          "id": "activity_002",
          "title": "Dinner conversation participation",
          "description": "Share one thing about your day at dinner",
          "completed": true,
        },
        {
          "id": "activity_003",
          "title": "Bedtime routine communication",
          "description": "Say goodnight and express one feeling",
          "completed": false,
        },
      ],
    },
    {
      "id": "homework_002",
      "title": "Fine Motor Skills Practice",
      "description":
          "Complete daily writing and drawing exercises to strengthen hand coordination.",
      "dueDate": "Aug 16, 2025",
      "assignedBy": "Ms. Jennifer Adams",
      "requiresEvidence": false,
      "activities": [
        {
          "id": "activity_004",
          "title": "Practice writing name 5 times",
          "description": "Focus on proper letter formation",
          "completed": false,
        },
        {
          "id": "activity_005",
          "title": "Draw shapes with ruler",
          "description": "Draw 3 squares, 3 circles, 3 triangles",
          "completed": false,
        },
        {
          "id": "activity_006",
          "title": "Cut paper strips",
          "description": "Use safety scissors to cut 10 straight lines",
          "completed": true,
        },
      ],
    },
  ];

  // Mock data for communication
  final Map<String, dynamic> _communicationData = {
    "recentMessages": [
      {
        "id": "msg_001",
        "sender": "Dr. Sarah Mitchell",
        "preview":
            "Emma did wonderfully in today's session. I'd like to discuss some strategies for home practice.",
        "time": "2 hours ago",
        "unread": true,
      },
      {
        "id": "msg_002",
        "sender": "Ms. Jennifer Adams",
        "preview":
            "Please remember to bring Emma's favorite pencil to tomorrow's OT session.",
        "time": "1 day ago",
        "unread": false,
      },
    ],
  };

  // Mock data for upcoming sessions
  final List<Map<String, dynamic>> _upcomingSessions = [
    {
      "id": "upcoming_001",
      "title": "Speech Therapy Session",
      "therapist": "Dr. Sarah Mitchell",
      "date": "Aug 14, 2025",
      "time": "10:00 AM",
      "location": "ThrivePath Therapy Center, Room 203",
      "daysUntil": 1,
      "notes":
          "Focus on conversational turn-taking and social pragmatics. Please bring Emma's communication journal.",
    },
    {
      "id": "upcoming_002",
      "title": "Occupational Therapy",
      "therapist": "Ms. Jennifer Adams",
      "date": "Aug 16, 2025",
      "time": "2:30 PM",
      "location": "ThrivePath Therapy Center, Room 105",
      "daysUntil": 3,
      "notes":
          "Working on handwriting skills and sensory integration activities.",
    },
  ];

  // Mock progress data for charts
  final List<Map<String, dynamic>> _progressData = [
    {"week": "Week 1", "progress": 65},
    {"week": "Week 2", "progress": 72},
    {"week": "Week 3", "progress": 68},
    {"week": "Week 4", "progress": 78},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _refreshData() async {
    // Simulate API call delay
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _lastSyncTime = "Just now";
    });

    Fluttertoast.showToast(
      msg: "Data refreshed successfully",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Theme.of(context).colorScheme.tertiary,
      textColor: Colors.white,
    );
  }

  void _handleHomeworkCompletion(String activityId, bool completed) {
    setState(() {
      for (var homework in _homeworkData) {
        final activities = homework["activities"] as List;
        for (var activity in activities) {
          final activityData = activity as Map<String, dynamic>;
          if (activityData["id"] == activityId) {
            activityData["completed"] = completed;
            break;
          }
        }
      }
    });

    Fluttertoast.showToast(
      msg: completed
          ? "Activity marked as completed"
          : "Activity marked as incomplete",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: completed
          ? Theme.of(context).colorScheme.tertiary
          : Theme.of(context).colorScheme.secondary,
      textColor: Colors.white,
    );
  }

  void _handlePhotoUpload(String homeworkId) {
    Fluttertoast.showToast(
      msg: "Photo upload feature coming soon",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Theme.of(context).colorScheme.primary,
      textColor: Colors.white,
    );
  }

  void _handleMessageTap() {
    Fluttertoast.showToast(
      msg: "Opening secure messaging...",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Theme.of(context).colorScheme.primary,
      textColor: Colors.white,
    );
  }

  void _handleCalendarIntegration() {
    Fluttertoast.showToast(
      msg: "Adding to calendar...",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Theme.of(context).colorScheme.secondary,
      textColor: Colors.white,
    );
  }

  void _handleRemindMe() {
    Fluttertoast.showToast(
      msg: "Reminder set successfully",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Theme.of(context).colorScheme.tertiary,
      textColor: Colors.white,
    );
  }

  void _handleSessionShare(String sessionId) {
    Fluttertoast.showToast(
      msg: "Sharing session summary...",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Theme.of(context).colorScheme.primary,
      textColor: Colors.white,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          "ThrivePath",
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        centerTitle: false,
        elevation: 0,
        backgroundColor: Colors.transparent,
        actions: [
          const ThemeToggleWidget(),
          Container(
            margin: EdgeInsets.only(right: 2.w),
            child: Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Theme.of(context).colorScheme.primary.withOpacity(0.1),
                        Theme.of(context).colorScheme.primary.withOpacity(0.05),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    onPressed: _handleMessageTap,
                    icon: CustomIconWidget(
                      iconName: 'notifications',
                      color: Theme.of(context).colorScheme.primary,
                      size: 24,
                    ),
                  ),
                ),
                if (_unreadMessages > 0)
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      padding: EdgeInsets.all(1.w),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Theme.of(context).colorScheme.error,
                            Theme.of(context).colorScheme.error.transparent80,
                          ],
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Theme.of(context).colorScheme.error.transparent30,
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      constraints: BoxConstraints(
                        minWidth: 5.w,
                        minHeight: 5.w,
                      ),
                      child: Text(
                        _unreadMessages.toString(),
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Container(
            margin: EdgeInsets.only(right: 4.w),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.onSurfaceVariant.transparent10,
                  Theme.of(context).colorScheme.onSurfaceVariant.transparent05,
                ],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              onPressed: () {
                Navigator.pushNamed(context, '/login-screen');
              },
              icon: CustomIconWidget(
                iconName: 'logout',
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                size: 24,
              ),
            ),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(
              icon: CustomIconWidget(
                iconName: 'trending_up',
                color: _tabController.index == 0
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.onSurfaceVariant,
                size: 20,
              ),
              text: "Progress",
            ),
            Tab(
              icon: CustomIconWidget(
                iconName: 'assignment',
                color: _tabController.index == 1
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.onSurfaceVariant,
                size: 20,
              ),
              text: "Homework",
            ),
            Tab(
              icon: Stack(
                children: [
                  CustomIconWidget(
                    iconName: 'chat',
                    color: _tabController.index == 2
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.onSurfaceVariant,
                    size: 20,
                  ),
                  if (_unreadMessages > 0)
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.error,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                ],
              ),
              text: "Messages",
            ),
            Tab(
              icon: CustomIconWidget(
                iconName: 'person',
                color: _tabController.index == 3
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.onSurfaceVariant,
                size: 20,
              ),
              text: "Profile",
            ),
          ],
          labelColor: Theme.of(context).colorScheme.primary,
          unselectedLabelColor:
              Theme.of(context).colorScheme.onSurfaceVariant,
          indicatorColor: Theme.of(context).colorScheme.primary,
          labelStyle: Theme.of(context).textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle:
              Theme.of(context).textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).scaffoldBackgroundColor,
              Theme.of(context).colorScheme.surface.withOpacity(0.3),
              Theme.of(context).scaffoldBackgroundColor,
            ],
            stops: const [0.0, 0.3, 1.0],
          ),
        ),
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildProgressTab(),
            _buildHomeworkTab(),
            _buildMessagesTab(),
            _buildProfileTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressTab() {
    return RefreshIndicator(
      onRefresh: _refreshData,
      color: Theme.of(context).colorScheme.primary,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ChildHeaderWidget(
              childData: _childData,
              onRefresh: _refreshData,
              lastSyncTime: _lastSyncTime,
            ),
            SizedBox(height: 3.h),
            ProgressChartWidget(
              progressData: _progressData,
              chartType: 'weekly',
            ),
            SizedBox(height: 3.h),
            if (_upcomingSessions.isNotEmpty) ...[
              Text(
                "Upcoming Sessions",
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 2.h),
              ...(_upcomingSessions.take(1).map((session) {
                return Padding(
                  padding: EdgeInsets.only(bottom: 2.h),
                  child: UpcomingSessionCardWidget(
                    sessionData: session,
                    onCalendarIntegration: _handleCalendarIntegration,
                    onRemindMe: _handleRemindMe,
                  ),
                );
              }).toList()),
              SizedBox(height: 3.h),
            ],
            Text(
              "Recent Session Summaries",
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 2.h),
            if (_sessionSummaries.isNotEmpty)
              ...(_sessionSummaries.map((session) {
                return SessionSummaryCardWidget(
                  sessionData: session,
                  onLongPress: () =>
                      _handleSessionShare(session["id"] as String),
                );
              }).toList())
            else
              EmptyStateWidget(
                title: "No Recent Sessions",
                description:
                    "Session summaries will appear here after your child's therapy appointments.",
                iconName: 'event_note',
                onAction: _refreshData,
                actionText: "Refresh",
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildHomeworkTab() {
    return RefreshIndicator(
      onRefresh: _refreshData,
      color: Theme.of(context).colorScheme.primary,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  "Homework Assignments",
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.secondary
                        .transparent10,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    "${_homeworkData.length} Active",
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: Theme.of(context).colorScheme.secondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 3.h),
            if (_homeworkData.isNotEmpty)
              ...(_homeworkData.map((homework) {
                return HomeworkCardWidget(
                  homeworkData: homework,
                  onCompletionChanged: _handleHomeworkCompletion,
                  onPhotoUpload: _handlePhotoUpload,
                );
              }).toList())
            else
              EmptyStateWidget(
                title: "No Homework Assigned",
                description:
                    "Homework assignments from your child's therapy team will appear here.",
                iconName: 'assignment',
                onAction: _refreshData,
                actionText: "Check for Updates",
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessagesTab() {
    return RefreshIndicator(
      onRefresh: _refreshData,
      color: Theme.of(context).colorScheme.primary,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CommunicationCardWidget(
              communicationData: _communicationData,
              onMessageTap: _handleMessageTap,
              unreadCount: _unreadMessages,
            ),
            SizedBox(height: 3.h),
            Text(
              "Communication Features",
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 2.h),
            _buildFeatureCard(
              "Secure Messaging",
              "Direct communication with therapy team",
              "chat",
              Theme.of(context).colorScheme.primary,
              _handleMessageTap,
            ),
            SizedBox(height: 2.h),
            _buildFeatureCard(
              "Progress Sharing",
              "Share session summaries with family",
              "share",
              Theme.of(context).colorScheme.secondary,
              () => _handleSessionShare("general"),
            ),
            SizedBox(height: 2.h),
            _buildFeatureCard(
              "Appointment Scheduling",
              "Request or reschedule therapy sessions",
              "schedule",
              Theme.of(context).colorScheme.tertiary,
              _handleCalendarIntegration,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileTab() {
    return RefreshIndicator(
      onRefresh: _refreshData,
      color: Theme.of(context).colorScheme.primary,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(13),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    width: 25.w,
                    height: 25.w,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Theme.of(context).colorScheme.primary
                            .transparent30,
                        width: 3,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(9),
                      child: CustomImageWidget(
                        imageUrl: _childData["photo"] as String?,
                        width: 25.w,
                        height: 25.w,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    _childData["name"] as String,
                    style:
                        Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 1.h),
                  Text(
                    "Age ${_childData["age"]} • ${_childData["diagnosis"]}",
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 3.h),
            Text(
              "Account Settings",
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 2.h),
            _buildSettingsItem("Edit Profile", "settings", () {}),
            _buildSettingsItem(
                "Notification Preferences", "notifications", () {}),
            _buildSettingsItem("Privacy Settings", "security", () {}),
            _buildSettingsItem("Data Export", "download", () {}),
            SizedBox(height: 3.h),
            Text(
              "Support",
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 2.h),
            _buildSettingsItem("Help Center", "help", () {}),
            _buildSettingsItem("Contact Support", "support", () {}),
            _buildSettingsItem("App Feedback", "feedback", () {}),
            SizedBox(height: 3.h),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.transparent10,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  CustomIconWidget(
                    iconName: 'security',
                    color: Theme.of(context).colorScheme.primary,
                    size: 32,
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    "HIPAA Compliant",
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  SizedBox(height: 1.h),
                  Text(
                    "Your child's therapy data is protected with enterprise-grade security and healthcare compliance standards.",
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCard(String title, String description, String iconName,
      Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(13),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                color: color.transparent10,
                borderRadius: BorderRadius.circular(12),
              ),
              child: CustomIconWidget(
                iconName: iconName,
                color: color,
                size: 24,
              ),
            ),
            SizedBox(width: 4.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 0.5.h),
                  Text(
                    description,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            CustomIconWidget(
              iconName: 'chevron_right',
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsItem(String title, String iconName, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 1.h),
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(13),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            CustomIconWidget(
              iconName: iconName,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              size: 20,
            ),
            SizedBox(width: 4.w),
            Expanded(
              child: Text(
                title,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            CustomIconWidget(
              iconName: 'chevron_right',
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}




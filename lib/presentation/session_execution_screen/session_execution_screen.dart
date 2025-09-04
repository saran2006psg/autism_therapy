import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/activity_card_widget.dart';
import './widgets/activity_progress_indicator_widget.dart';
import './widgets/data_collection_widget.dart';
import './widgets/session_controls_overlay_widget.dart';
import './widgets/session_navigation_widget.dart';
import './widgets/session_timer_widget.dart';

class SessionExecutionScreen extends StatefulWidget {
  const SessionExecutionScreen({super.key});

  @override
  State<SessionExecutionScreen> createState() => _SessionExecutionScreenState();
}

class _SessionExecutionScreenState extends State<SessionExecutionScreen>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  // Core session state
  final PageController _pageController = PageController();
  int _currentActivityIndex = 0;
  bool _isSessionPaused = false;

  // Camera and recording
  List<CameraDescription> _cameras = [];
  CameraController? _cameraController;
  final ImagePicker _imagePicker = ImagePicker();
  final AudioRecorder _audioRecorder = AudioRecorder();
  bool _isRecording = false;

  // Data collection
  final List<Map<String, dynamic>> _sessionData = [];
  final List<String> _sessionNotes = [];
  final List<XFile> _capturedPhotos = [];
  final List<String> _audioRecordings = [];

  // UI state
  bool _showDataCollection = false;

  // Mock session data
  final List<Map<String, dynamic>> _sessionActivities = [
    {
      'id': 1,
      'title': 'Social Interaction Exercise',
      'category': 'Social Skills',
      'icon': 'people',
      'instructions':
          'Encourage the child to make eye contact and respond to simple greetings. Use visual cues and positive reinforcement when the child engages appropriately.',
      'duration': '10',
      'goal': 'Eye Contact & Greetings',
    },
    {
      'id': 2,
      'title': 'Communication Building',
      'category': 'Speech Therapy',
      'icon': 'record_voice_over',
      'instructions':
          'Practice using picture cards to help the child express basic needs and wants. Allow processing time and celebrate any attempts at communication.',
      'duration': '15',
      'goal': 'Expressive Communication',
    },
    {
      'id': 3,
      'title': 'Sensory Integration Activity',
      'category': 'Occupational Therapy',
      'icon': 'touch_app',
      'instructions':
          'Guide the child through various textured materials and sensory experiences. Monitor comfort levels and adjust intensity based on responses.',
      'duration': '12',
      'goal': 'Sensory Processing',
    },
    {
      'id': 4,
      'title': 'Fine Motor Skills Practice',
      'category': 'Motor Development',
      'icon': 'pan_tool',
      'instructions':
          'Use building blocks, puzzles, or drawing activities to develop hand-eye coordination and fine motor control. Provide hand-over-hand assistance as needed.',
      'duration': '8',
      'goal': 'Motor Coordination',
    },
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeSession();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _pageController.dispose();
    _cameraController?.dispose();
    _audioRecorder.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.paused) {
      _pauseSession();
    } else if (state == AppLifecycleState.resumed && _isSessionPaused) {
      _showReturnNotification();
    }
  }

  Future<void> _initializeSession() async {
    try {
      await _initializeCamera();
      await _keepScreenAwake();
      _startSessionTimer();
    } catch (e) {
      debugPrint('Session initialization error: $e');
    }
  }

  Future<void> _initializeCamera() async {
    try {
      if (!await _requestCameraPermission()) return;

      _cameras = await availableCameras();
      if (_cameras.isEmpty) return;

      final camera = kIsWeb
          ? _cameras.firstWhere(
              (c) => c.lensDirection == CameraLensDirection.front,
              orElse: () => _cameras.first)
          : _cameras.firstWhere(
              (c) => c.lensDirection == CameraLensDirection.back,
              orElse: () => _cameras.first);

      _cameraController = CameraController(
          camera, kIsWeb ? ResolutionPreset.medium : ResolutionPreset.high);

      await _cameraController!.initialize();
      await _applyCameraSettings();
    } catch (e) {
      debugPrint('Camera initialization error: $e');
    }
  }

  Future<bool> _requestCameraPermission() async {
    if (kIsWeb) return true;
    return (await Permission.camera.request()).isGranted;
  }

  Future<void> _applyCameraSettings() async {
    if (_cameraController == null) return;

    try {
      await _cameraController!.setFocusMode(FocusMode.auto);
      if (!kIsWeb) {
        await _cameraController!.setFlashMode(FlashMode.auto);
      }
    } catch (e) {
      debugPrint('Camera settings error: $e');
    }
  }

  Future<void> _keepScreenAwake() async {
    try {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    } catch (e) {
      debugPrint('Screen wake error: $e');
    }
  }

  void _startSessionTimer() {
    // Timer logic handled by SessionTimerWidget
  }

  void _pauseSession() {
    setState(() {
      _isSessionPaused = true;
    });
    HapticFeedback.mediumImpact();
  }

  void _resumeSession() {
    setState(() {
      _isSessionPaused = false;
    });
    HapticFeedback.lightImpact();
  }

  void _showReturnNotification() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Session paused - tap to resume'),
        action: SnackBarAction(
          label: 'Resume',
          onPressed: _resumeSession,
        ),
      ),
    );
  }

  Future<void> _capturePhoto() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      await _selectFromGallery();
      return;
    }

    try {
      final XFile photo = await _cameraController!.takePicture();
      setState(() {
        _capturedPhotos.add(photo);
      });

      _collectSessionData('photo', photo.path);
      HapticFeedback.selectionClick();

      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Photo captured successfully')),
      );
    } catch (e) {
      await _selectFromGallery();
    }
  }

  Future<void> _selectFromGallery() async {
    try {
      final XFile? image =
          await _imagePicker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() {
          _capturedPhotos.add(image);
        });
        _collectSessionData('photo', image.path);
        HapticFeedback.selectionClick();
      }
    } catch (e) {
      debugPrint('Gallery selection error: $e');
    }
  }

  Future<void> _startVoiceRecording() async {
    try {
      if (await _audioRecorder.hasPermission()) {
        setState(() {
          _isRecording = true;
        });

        if (kIsWeb) {
          await _audioRecorder.start(
              const RecordConfig(encoder: AudioEncoder.wav),
              path: 'recording_${DateTime.now().millisecondsSinceEpoch}.wav');
        } else {
          final dir = await getTemporaryDirectory();
          String path =
              '${dir.path}/recording_${DateTime.now().millisecondsSinceEpoch}.m4a';
          await _audioRecorder.start(const RecordConfig(), path: path);
        }

        HapticFeedback.mediumImpact();
      }
    } catch (e) {
      setState(() {
        _isRecording = false;
      });
      debugPrint('Recording start error: $e');
    }
  }

  Future<void> _stopVoiceRecording() async {
    try {
      final String? path = await _audioRecorder.stop();
      setState(() {
        _isRecording = false;
      });

      if (path != null) {
        _audioRecordings.add(path);
        _collectSessionData('audio', path);
        HapticFeedback.lightImpact();

        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Voice note recorded')),
        );
      }
    } catch (e) {
      setState(() {
        _isRecording = false;
      });
      debugPrint('Recording stop error: $e');
    }
  }

  void _collectSessionData(String type, dynamic value) {
    final dataEntry = {
      'timestamp': DateTime.now(),
      'activity_id': _sessionActivities[_currentActivityIndex]['id'],
      'type': type,
      'value': value,
    };

    setState(() {
      _sessionData.add(dataEntry);
    });
  }

  void _onSwipeGesture(String direction) {
    HapticFeedback.selectionClick();

    switch (direction) {
      case 'up':
        _collectSessionData('behavior', 'positive');
        _showFeedbackMessage('Positive response recorded', Colors.green);
        break;
      case 'down':
        _collectSessionData('behavior', 'needs_improvement');
        _showFeedbackMessage('Needs improvement noted', Colors.orange);
        break;
      case 'right':
        _collectSessionData('behavior', 'completed');
        _showFeedbackMessage('Activity completed', Colors.blue);
        break;
    }
  }

  void _showFeedbackMessage(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _navigateToActivity(int index) {
    if (index >= 0 && index < _sessionActivities.length) {
      setState(() {
        _currentActivityIndex = index;
      });
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _completeSession() {
    setState(() {
    });

    _showSessionSummary();
  }

  void _showSessionSummary() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            CustomIconWidget(
              iconName: 'check_circle',
              color: AppTheme.lightTheme.colorScheme.tertiary,
              size: 24,
            ),
            SizedBox(width: 3.w),
            const Text('Session Complete'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Session completed successfully!'),
            SizedBox(height: 2.h),
            const Text('Data collected:'),
            Text('• ${_sessionData.length} behavioral observations'),
            Text('• ${_sessionNotes.length} notes'),
            Text('• ${_capturedPhotos.length} photos'),
            Text('• ${_audioRecordings.length} voice recordings'),
            SizedBox(height: 2.h),
            const Text(
                'All data has been saved locally and will sync when connected.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.pushReplacementNamed(context, '/therapist-dashboard');
            },
            child: const Text('Return to Dashboard'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _exportSessionData();
            },
            child: const Text('Export Data'),
          ),
        ],
      ),
    );
  }

  void _exportSessionData() {
    // Export functionality would be implemented here
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Session data exported successfully')),
    );
  }

  void _showEmergencyDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            CustomIconWidget(
              iconName: 'warning',
              color: AppTheme.lightTheme.colorScheme.error,
              size: 24,
            ),
            SizedBox(width: 3.w),
            const Text('Emergency Stop'),
          ],
        ),
        content: const Text(
            'Are you sure you want to stop the session immediately?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _completeSession();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.lightTheme.colorScheme.error,
            ),
            child: const Text('Stop Session'),
          ),
        ],
      ),
    );
  }

  void _showQuickNotesDialog() {
    final TextEditingController notesController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Quick Notes'),
        content: TextField(
          controller: notesController,
          decoration: const InputDecoration(
            hintText: 'Enter your observation or note...',
          ),
          maxLines: 3,
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (notesController.text.trim().isNotEmpty) {
                _sessionNotes.add(notesController.text.trim());
                _collectSessionData('note', notesController.text.trim());
              }
              Navigator.of(context).pop();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showEmergencyContact() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            CustomIconWidget(
              iconName: 'phone',
              color: AppTheme.lightTheme.colorScheme.error,
              size: 24,
            ),
            SizedBox(width: 3.w),
            const Text('Emergency Contact'),
          ],
        ),
        content: const Text('Contact supervisor immediately?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Emergency contact functionality would be implemented here
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Contacting supervisor...')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.lightTheme.colorScheme.error,
            ),
            child: const Text('Call Now'),
          ),
        ],
      ),
    );
  }

  void _showDetailedEntryDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          padding: EdgeInsets.all(6.w),
          constraints: BoxConstraints(maxHeight: 80.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Detailed Assessment',
                    style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: CustomIconWidget(
                      iconName: 'close',
                      color: AppTheme.lightTheme.colorScheme.onSurface,
                      size: 24,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 3.h),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ASD Assessment Scale',
                        style:
                            AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      _buildAssessmentScale('Social Interaction', 1, 5),
                      _buildAssessmentScale('Communication', 1, 5),
                      _buildAssessmentScale('Behavioral Flexibility', 1, 5),
                      _buildAssessmentScale('Sensory Processing', 1, 5),
                      SizedBox(height: 3.h),
                      const TextField(
                        decoration: InputDecoration(
                          labelText: 'Detailed Observations',
                          hintText:
                              'Enter comprehensive notes about the child\'s performance...',
                        ),
                        maxLines: 4,
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 3.h),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                  ),
                  SizedBox(width: 4.w),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Assessment saved')),
                        );
                      },
                      child: const Text('Save Assessment'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAssessmentScale(String label, int min, int max) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 1.h),
        Row(
          children: List.generate(max - min + 1, (index) {
            final value = min + index;
            return Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 1.w),
                child: Column(
                  children: [
                    Radio<int>(
                      value: value,
                      groupValue: 3, // Default middle value
                      onChanged: (val) {},
                    ),
                    Text(
                      value.toString(),
                      style: AppTheme.lightTheme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
        SizedBox(height: 2.h),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: [
              // Progress indicator at top
              ActivityProgressIndicatorWidget(
                currentActivity: _currentActivityIndex,
                totalActivities: _sessionActivities.length,
                activityTitles: _sessionActivities
                    .map((activity) => activity['title'] as String)
                    .toList(),
              ),

              // Main content area with PageView
              Expanded(
                child: GestureDetector(
                  onPanEnd: (details) {
                    final velocity = details.velocity.pixelsPerSecond;
                    if (velocity.dy.abs() > velocity.dx.abs()) {
                      if (velocity.dy > 0) {
                        _onSwipeGesture('down');
                      } else {
                        _onSwipeGesture('up');
                      }
                    } else if (velocity.dx > 0) {
                      _onSwipeGesture('right');
                    }
                  },
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: (index) {
                      setState(() {
                        _currentActivityIndex = index;
                      });
                    },
                    itemCount: _sessionActivities.length,
                    itemBuilder: (context, index) {
                      return SingleChildScrollView(
                        child: Column(
                          children: [
                            // Timer widget
                            Padding(
                              padding: EdgeInsets.all(4.w),
                              child: SessionTimerWidget(
                                initialDuration: Duration(
                                  minutes: int.tryParse(
                                          _sessionActivities[index]
                                                  ['duration'] ??
                                              '5') ??
                                      5,
                                ),
                                isPaused: _isSessionPaused,
                                onTimerComplete: () {
                                  HapticFeedback.heavyImpact();
                                  _showFeedbackMessage(
                                      'Time\'s up!',
                                      AppTheme
                                          .lightTheme.colorScheme.secondary);
                                },
                              ),
                            ),

                            // Activity card
                            ActivityCardWidget(
                              activity: _sessionActivities[index],
                              onDetailedEntry: _showDetailedEntryDialog,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),

              // Data collection panel (when visible)
              if (_showDataCollection)
                DataCollectionWidget(
                  onDataCollected: (type, value) {
                    _collectSessionData(type, value);
                  },
                  onPhotoCapture: _capturePhoto,
                  onVoiceNote:
                      _isRecording ? _stopVoiceRecording : _startVoiceRecording,
                ),

              // Bottom navigation
              SessionNavigationWidget(
                currentActivity: _currentActivityIndex,
                totalActivities: _sessionActivities.length,
                canGoBack: _currentActivityIndex > 0,
                canGoNext:
                    _currentActivityIndex < _sessionActivities.length - 1,
                onPrevious: () =>
                    _navigateToActivity(_currentActivityIndex - 1),
                onNext: () => _navigateToActivity(_currentActivityIndex + 1),
                onComplete: _completeSession,
              ),
            ],
          ),

          // Floating controls overlay
          SessionControlsOverlayWidget(
            isSessionPaused: _isSessionPaused,
            onPauseResume: _isSessionPaused ? _resumeSession : _pauseSession,
            onEmergencyStop: _showEmergencyDialog,
            onQuickNotes: _showQuickNotesDialog,
            onEmergencyContact: _showEmergencyContact,
          ),

          // Data collection toggle button
          Positioned(
            bottom: 20.h,
            left: 4.w,
            child: FloatingActionButton(
              heroTag: "data_collection",
              onPressed: () {
                setState(() {
                  _showDataCollection = !_showDataCollection;
                });
              },
              backgroundColor: _showDataCollection
                  ? AppTheme.lightTheme.colorScheme.secondary
                  : AppTheme.lightTheme.colorScheme.primary,
              child: CustomIconWidget(
                iconName: _showDataCollection
                    ? 'keyboard_arrow_down'
                    : 'keyboard_arrow_up',
                color: AppTheme.lightTheme.colorScheme.onPrimary,
                size: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

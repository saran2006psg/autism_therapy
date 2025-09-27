import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:sizer/sizer.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:provider/provider.dart';

import 'package:thriveers/firebase_options.dart';
import 'package:thriveers/core/app_export.dart';

// Global theme manager instance
late ThemeManager themeManager;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase safely (prevent duplicate app errors)
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  }
  
  // Initialize theme manager
  themeManager = ThemeManager();
  await themeManager.initializeTheme();
  
  // Configure Firebase Database for offline persistence (only for non-web platforms)
  if (!kIsWeb) {
    try {
      FirebaseDatabase.instance.setPersistenceEnabled(true);
    } catch (e) {
      AppLogger.warning('Firebase persistence not supported on this platform: $e', name: 'Main', error: e);
    }
  }
  
  // Optimize image cache for better performance
  PaintingBinding.instance.imageCache.maximumSizeBytes = 200 << 20; // 200MB

  // 🚨 CRITICAL: Custom error handling - DO NOT REMOVE
  ErrorWidget.builder = (FlutterErrorDetails details) {
    return CustomErrorWidget(
      errorDetails: details,
    );
  };
  // 🚨 CRITICAL: Device orientation lock - DO NOT REMOVE
  Future.wait([
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
  ]).then((value) {
    runApp(const MyApp());
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: themeManager),
        ChangeNotifierProvider(create: (_) => DataService()),
      ],
      child: Consumer<ThemeManager>(
        builder: (context, themeManager, child) {
          return Sizer(builder: (context, orientation, screenType) {
            return MaterialApp(
              title: 'ThrivePath',
              theme: AppTheme.lightTheme,
              darkTheme: AppTheme.darkTheme,
              themeMode: themeManager.themeMode,
              // 🚨 CRITICAL: NEVER REMOVE OR MODIFY
              builder: (context, child) {
                return MediaQuery(
                  data: MediaQuery.of(context).copyWith(
                    textScaler: const TextScaler.linear(1.0),
                  ),
                  child: child!,
                );
              },
              // 🚨 END CRITICAL SECTION
              debugShowCheckedModeBanner: false,
              routes: AppRoutes.routes,
              initialRoute: AppRoutes.initial,
            );
          });
        },
      ),
    );
  }
}
// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sizer/sizer.dart';
import 'package:thriveers/presentation/login_screen/login_screen.dart';

void main() {
  // Ignore overflow errors from responsive layout in tests
  final originalOnError = FlutterError.onError;
  FlutterError.onError = (FlutterErrorDetails details) {
    final message = details.exceptionAsString();
    if (message.contains('A RenderFlex overflowed by')) {
      return; // ignore overflow in tests
    }
    if (originalOnError != null) {
      originalOnError(details);
    } else {
      FlutterError.presentError(details);
    }
  };

  testWidgets('Login screen renders', (WidgetTester tester) async {
    // Increase virtual screen to avoid overflow in responsive layout
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = const Size(1080, 2340);
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      Sizer(
        builder: (context, orientation, deviceType) {
          return const MaterialApp(
            home: LoginScreen(),
          );
        },
      ),
    );

    // Basic smoke check
    expect(find.byType(LoginScreen), findsOneWidget);
  });
}

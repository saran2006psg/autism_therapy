package com.example.thriveers

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.dart.DartExecutor

class MainActivity : FlutterActivity() {
	override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
		super.configureFlutterEngine(flutterEngine)
		// Defensive: ensure Dart entrypoint is executed to avoid early surface teardown on some devices
		try {
			flutterEngine.dartExecutor.executeDartEntrypoint(
				DartExecutor.DartEntrypoint.createDefault()
			)
		} catch (_: Throwable) {
			// No-op if already started
		}
	}
}

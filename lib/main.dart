import 'dart:ui';
import 'package:amplitude_session_replay/amplitude_session_replay.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mixpanel_flutter_session_replay/mixpanel_flutter_session_replay.dart' hide LogLevel;
import 'package:posthog_flutter/posthog_flutter.dart';
import 'package:tracker_testing/core/tracking_service.dart';
import 'package:tracker_testing/features/home/presentation/pages/home_page.dart';
import 'package:tracker_testing/core/di/injection_container.dart' as di;

// Global RouteObserver for back-navigation tracking
final RouteObserver<ModalRoute<void>> routeObserver = RouteObserver<ModalRoute<void>>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 1. Initialize Firebase Core
  await Firebase.initializeApp();
  
  // Catch all errors that happen outside of the Flutter context
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };

  // 2. Initialize Dependency Injection (Firebase Analytics, Mixpanel, Services)
  await di.init();

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    final replayConfig = di.sl<di.ReplayConfig>();
    
    return RepositoryProvider.value(
      value: di.sl<TrackingService>(),
      // 1. Mixpanel Session Replay
      child: MixpanelSessionReplayWidget(
        instance: replayConfig.mixpanel,
        // 2. Amplitude Session Replay
        child: replayConfig.amplitude != null
            ? SessionReplayWidget(
                sessionReplay: replayConfig.amplitude!,
                app: _buildPostHogAndApp(),
              )
            : _buildPostHogAndApp(),
      ),
    );
  }

  Widget _buildPostHogAndApp() {
    return PostHogWidget(
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Tracker Testing',
        navigatorObservers: [
          routeObserver,
          PosthogObserver(),
        ],
        home: const HomePage(),
      ),
    );
  }
}

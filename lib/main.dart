import 'dart:ui';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
    return RepositoryProvider.value(
      value: di.sl<TrackingService>(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Tracker Testing',
        navigatorObservers: [routeObserver],
        home: const HomePage(),
      ),
    );
  }
}

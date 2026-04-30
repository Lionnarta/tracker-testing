import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tracker_testing/core/tracking_service.dart';
import 'package:tracker_testing/features/settings/presentation/pages/settings_page.dart';
import 'package:tracker_testing/features/profile/presentation/pages/profile_page.dart';
import 'package:tracker_testing/main.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with RouteAware {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPopNext() {
    // Called when the top route has been popped off, and this route shows up.
    _logScreen();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _logScreen();
      }
    });
  }

  void _logScreen() {
    context.read<TrackingService>().logScreen('Home Page');
  }

  @override
  Widget build(BuildContext context) {
    final trackingService = context.read<TrackingService>();

    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Welcome to Tracker Testing'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                trackingService.logEvent('button_click', params: {'button_name': 'test_event'});
              },
              child: const Text('Track Event'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SettingsPage()),
                );
              },
              child: const Text('Go to Settings'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ProfilePage()),
                );
              },
              child: const Text('Go to Profile'),
            ),
          ],
        ),
      ),
    );
  }
}

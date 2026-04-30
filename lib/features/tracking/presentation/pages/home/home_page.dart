import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tracker_testing/core/tracking_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    // Manual screen tracking
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<TrackingService>().logScreen('Home Page');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final trackingService = context.read<TrackingService>();

    return Scaffold(
      appBar: AppBar(title: const Text('Tracker Testing')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Manual Tracking: Home'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                trackingService.logEvent('test_event', params: {
                  'page': 'home',
                  'timestamp': DateTime.now().toIso8601String(),
                });
              },
              child: const Text('Track Test Event'),
            ),
          ],
        ),
      ),
    );
  }
}

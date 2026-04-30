import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tracker_testing/core/tracking_service.dart';
import 'package:tracker_testing/main.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> with RouteAware {
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
    context.read<TrackingService>().logScreen('Profile Page');
  }

  @override
  Widget build(BuildContext context) {
    final trackingService = context.read<TrackingService>();

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.person, size: 100),
            const Text('User Name: John Doe'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                trackingService.logEvent('profile_action', params: {'type': 'edit_clicked'});
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Edit Clicked tracked!')),
                );
              },
              child: const Text('Edit Profile'),
            ),
            ElevatedButton(
              onPressed: () {
                // Identifying the user
                trackingService.identify('user_12345');
                // Setting some identified properties
                trackingService.setUserProperty('full_name', 'John Doe');
                trackingService.setUserProperty('email', 'john.doe@example.com');
                
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('User Identified as "user_12345"'),
                    backgroundColor: Colors.blue,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[100],
                foregroundColor: Colors.blue[900],
              ),
              child: const Text('Simulate Login (Identify User)'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                // Setting a User Property
                trackingService.setUserProperty('user_type', 'premium');
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('User Property "user_type" set to "premium"'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber[100],
                foregroundColor: Colors.orange[900],
              ),
              child: const Text('Upgrade to Premium'),
            ),
          ],
        ),
      ),
    );
  }
}

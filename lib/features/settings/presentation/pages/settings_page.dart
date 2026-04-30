import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tracker_testing/core/tracking_service.dart';
import 'package:tracker_testing/main.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> with RouteAware {
  bool _notificationsEnabled = false;

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
    context.read<TrackingService>().logScreen('Settings Page');
  }

  @override
  Widget build(BuildContext context) {
    final trackingService = context.read<TrackingService>();

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('Enable Notifications'),
            value: _notificationsEnabled,
            onChanged: (value) {
              setState(() {
                _notificationsEnabled = value;
              });
              // Track the toggle event
              trackingService.logEvent('settings_changed', params: {
                'setting_name': 'notifications',
                'value': value,
              });
            },
          ),
          const Divider(),
          ListTile(
            title: const Text('Test Stability', style: TextStyle(color: Colors.red)),
            subtitle: const Text('This will force the app to crash'),
            trailing: const Icon(Icons.bug_report, color: Colors.red),
            onTap: () {
              // Force a crash for testing
              FirebaseCrashlytics.instance.crash();
            },
          ),
        ],
      ),
    );
  }
}

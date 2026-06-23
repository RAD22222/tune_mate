// lib/features/profile/presentation/screens/settings_screen.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_sizes.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationMute = false;
  bool _readReceipts = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings', style: TextStyle(fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: ListView(
        children: [
          _buildHeader('Account'),
          const ListTile(
            leading: Icon(Icons.key_outlined),
            title: Text('Account Info'),
            subtitle: Text('Change password, email address'),
          ),
          const ListTile(
            leading: Icon(Icons.palette_outlined),
            title: Text('Appearance'),
            subtitle: Text('Light / dark mode options'),
          ),
          _buildHeader('Notifications'),
          SwitchListTile(
            secondary: const Icon(Icons.notifications_outlined),
            title: const Text('Mute notifications'),
            value: _notificationMute,
            onChanged: (val) {
              setState(() {
                _notificationMute = val;
              });
            },
          ),
          _buildHeader('Privacy'),
          SwitchListTile(
            secondary: const Icon(Icons.remove_red_eye_outlined),
            title: const Text('Read receipts'),
            value: _readReceipts,
            onChanged: (val) {
              setState(() {
                _readReceipts = val;
              });
            },
          ),
          _buildHeader('Storage & Data'),
          ListTile(
            leading: const Icon(Icons.delete_outline),
            title: const Text('Clear Cache'),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Local SQLite cache cleared successfully!')),
              );
            },
          ),
          _buildHeader('About'),
          const ListTile(
            leading: Icon(Icons.info_outline),
            title: Text('Version'),
            trailing: Text('1.0.0'),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: AppSizes.p16, top: AppSizes.p24, bottom: AppSizes.p8),
      child: Text(
        title,
        style: TextStyle(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}

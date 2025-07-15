import 'package:flutter/material.dart';
import 'package:rx_vision/views/profile_settings/change_email.dart';
import 'package:rx_vision/views/profile_settings/change_name.dart';
import 'package:rx_vision/views/profile_settings/change_password.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Profile Settings',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        appBarTheme: const AppBarTheme(
          elevation: 0,
          centerTitle: true,
        ),
      ),
      initialRoute: '/profileSettings',
      routes: {
        '/profileSettings': (context) => const ProfileSettingsView(),
        '/changeName': (context) => const ChangeNameView(),
        '/changeEmail': (context) => const ChangeEmailView(),
        '/changePassword': (context) => const ChangePasswordView(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}

class ProfileSettingsView extends StatelessWidget {
  const ProfileSettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile Settings'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildSettingItem(
            context,
            title: 'Change Name',
            icon: Icons.person_outline,
            routeName: '/changeName',
          ),
          const Divider(height: 1),
          _buildSettingItem(
            context,
            title: 'Change Email',
            icon: Icons.email_outlined,
            routeName: '/changeEmail',
          ),
          const Divider(height: 1),
          _buildSettingItem(
            context,
            title: 'Change Password',
            icon: Icons.lock_outline,
            routeName: '/changePassword',
          ),
          const SizedBox(height: 32),
          _buildBackButton(context),
        ],
      ),
    );
  }

  Widget _buildSettingItem(
    BuildContext context, {
    required String title,
    required IconData icon,
    required String routeName,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      leading: Icon(icon, size: 24),
      title: Text(
        title,
        style: const TextStyle(fontSize: 16),
      ),
      trailing: const Icon(Icons.chevron_right, size: 24),
      onTap: () {
        Navigator.pushNamed(context, routeName);
      },
    );
  }

  Widget _buildBackButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue[800],
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        onPressed: () {
          Navigator.pop(context);
        },
        child: const Text(
          'Back',
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}
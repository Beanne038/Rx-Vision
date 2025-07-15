import 'package:flutter/material.dart';
import '../models/user_model.dart';

// Import your views
import 'views/welcome/welcome_view.dart';
import 'views/login/login_view.dart';
import 'views/register/register_view.dart';
import 'views/dashboard/dashboard_view.dart';
import 'package:rx_vision/views/inventory/inventory_view.dart';
import 'package:rx_vision/views/stock/stock_views.dart';
import 'package:rx_vision/views/notifications/notification_view.dart';
import 'package:rx_vision/views/profile/profile_view.dart';
import 'package:rx_vision/views/profile_settings/change_email.dart';
import 'package:rx_vision/views/profile_settings/change_name.dart';
import 'package:rx_vision/views/profile_settings/change_password.dart';
import 'package:rx_vision/views/profile_settings/profile_setings_view.dart';
void main() {
  runApp(const RxVisionApp());
}

class RxVisionApp extends StatelessWidget {
  const RxVisionApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Rx Vision',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      initialRoute: '/welcome',
      routes: {
        '/welcome': (context) => const WelcomeView(),
        '/login': (context) => LoginView(),
        '/register': (context) => RegistrationView(),
        '/inventory': (context) => const InventoryView(),
        '/notifications': (context) => const NotificationsView(),
        '/profile': (context) => const ProfileView(),
        '/profileSettings': (context) => const ProfileSettingsView(),
        '/changeName': (context) => const ChangeNameView(),
        '/changeEmail': (context) => const ChangeEmailView(),
        '/changePassword': (context) => const ChangePasswordView(),
        '/stock': (context) {
          final medicineNumber = ModalRoute.of(context)!.settings.arguments as String;
          return StockDetailsView(medicineNumber: medicineNumber);
        },
        '/dashboard': (context) {
          final user = ModalRoute.of(context)!.settings.arguments as User;
          return DashboardView(user: user);
        },
      },
    );
  }
}

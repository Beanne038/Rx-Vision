import 'package:flutter/material.dart';
import 'package:rx_vision/views/inventory/inventory_view.dart';
import 'package:rx_vision/views/notifications/notification_view.dart';
import 'package:rx_vision/views/prescription/prescription_view.dart';
import 'package:rx_vision/views/profile/profile_view.dart';
import 'package:rx_vision/views/supplier/supplier_view.dart';

class DashboardView extends StatelessWidget {
  const DashboardView({super.key, required user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Rx Vision'), centerTitle: true, backgroundColor: Colors.blue[800], foregroundColor: Colors.white, automaticallyImplyLeading: false),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Header
            const Text('Welcome to Rx Vision', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('Dashboard:', style: TextStyle(fontSize: 18, color: Colors.grey)),
            const SizedBox(height: 32),

            // Dashboard Items Grid
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.2,
                children: [
                  _buildDashboardItem(
                    icon: Icons.person,
                    label: 'Profile',
                    onTap: () {
                     Navigator.push(context, MaterialPageRoute(builder: (context) => ProfileView())); // Navigate to Profile
                    },
                  ),
                  _buildDashboardItem(
                    icon: Icons.inventory,
                    label: 'Inventory',
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => InventoryView())); // Navigate to Inventory
                    },
                  ),
                  _buildDashboardItem(
                    icon: Icons.notifications,
                    label: 'Notification',
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => NotificationsView())); //Navigate to Notifications
                    },
                  ),
                  _buildDashboardItem(
                    icon: Icons.local_shipping,
                    label: 'Supplier',
                    onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => SupplierView()));  // Navigate to Supplier
                    },
                  ),
                  _buildDashboardItem(
                    icon: Icons.medical_services,
                    label: 'Prescription',
                    onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => PrescriptionView()));  // Navigate to Prescription
                    },
                  ),
                  _buildDashboardItem(
                    icon: Icons.logout,
                    label: 'Log-out',
                    onTap: () {
                      _showLogoutConfirmation(context);
                    },
                    color: Colors.red,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardItem({required IconData icon, required String label, required VoidCallback onTap, Color color = Colors.blue}) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 40, color: color),
              const SizedBox(height: 12),
              Text(
                label,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              // Perform logout
              Navigator.popUntil(context, (route) => route.isFirst);
            },
            child: const Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

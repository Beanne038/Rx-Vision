import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Rx Vision - Notifications',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const NotificationsView(),
    );
  }
}

class NotificationsView extends StatelessWidget {
  const NotificationsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        centerTitle: true,
        backgroundColor: Colors.blue[800],
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: ListView(
                children: const [
                  NotificationItem(
                    title: 'Heads up!',
                    message: 'Metformin is on low stock - 12 tablets remaining.',
                    isUrgent: true,
                  ),
                  SizedBox(height: 12),
                  NotificationItem(
                    title: 'Stock Update',
                    message: 'Carlo updated the stock of Biogesic. +120 units.',
                  ),
                  SizedBox(height: 12),
                  NotificationItem(
                    title: 'Expiration Alert',
                    message: 'Brexipiprazole are expiring within 30 days at August 10.',
                    isWarning: true,
                  ),
                  SizedBox(height: 12),
                  NotificationItem(
                    title: 'New Prescription',
                    message: 'A new prescription has been added by Dr. Reyes. Check the prescription tab.',
                  ),
                  SizedBox(height: 12),
                  NotificationItem(
                    title: 'Inventory Reminder',
                    message: 'Inventory check for Vitamin B scheduled tomorrow.',
                  ),
                ],
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[800],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Back'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class NotificationItem extends StatelessWidget {
  final String title;
  final String message;
  final bool isUrgent;
  final bool isWarning;

  const NotificationItem({
    super.key,
    required this.title,
    required this.message,
    this.isUrgent = false,
    this.isWarning = false,
  });

  @override
  Widget build(BuildContext context) {
    Color borderColor = Colors.grey[300]!;
    Color titleColor = Colors.blue[800]!;
    IconData? icon;

    if (isUrgent) {
      borderColor = Colors.red[300]!;
      titleColor = Colors.red;
      icon = Icons.warning_amber;
    } else if (isWarning) {
      borderColor = Colors.orange[300]!;
      titleColor = Colors.orange[800]!;
      icon = Icons.error_outline;
    }

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: borderColor),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (icon != null)
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: Icon(icon, color: titleColor),
              ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: titleColor,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    message,
                    style: const TextStyle(
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
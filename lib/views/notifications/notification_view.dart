import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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

class NotificationsView extends StatefulWidget {
  const NotificationsView({super.key});

  @override
  State<NotificationsView> createState() => _NotificationsViewState();
}

class _NotificationsViewState extends State<NotificationsView> {
  List<dynamic> notifications = [];

  @override
  void initState() {
    super.initState();
    fetchNotifications();
  }

  Future<void> fetchNotifications() async {
    try {
      final response = await http.get(Uri.parse('http://localhost:3000/api/notifications'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          notifications = data['notifications'];
        });
      } else {
        setState(() {
          notifications = [];
        });
      }
    } catch (e) {
      print('Error fetching notifications: $e');
      setState(() {
        notifications = [];
      });
    }
  }

  Future<void> deleteNotification(int id) async {
    final response = await http.delete(Uri.parse('http://localhost:3000/api/notifications/$id'));
    if (response.statusCode == 200) {
      setState(() {
        notifications.removeWhere((notif) => notif['id'] == id);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to delete notification')),
      );
    }
  }

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
              child: notifications.isEmpty
                  ? const Center(child: Text('No notifications found.'))
                  : ListView.builder(
                      itemCount: notifications.length,
                      itemBuilder: (context, index) {
                        final notification = notifications[index];
                        final title = notification['title'] ?? 'No Title';
                        final message = notification['message'] ?? 'No Message';
                        final timestamp = notification['timestamp'] ?? '';
                        final isUrgent = title.toLowerCase().contains('deleted');
                        final isWarning = title.toLowerCase().contains('expire');
                        final id = notification['id'];

                        return Column(
                          children: [
                            NotificationItem(
                              title: title,
                              message: "$message\n($timestamp)",
                              isUrgent: isUrgent,
                              isWarning: isWarning,
                              onDelete: () => deleteNotification(id),
                            ),
                            const SizedBox(height: 12),
                          ],
                        );
                      },
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
  final VoidCallback onDelete;

  const NotificationItem({
    super.key,
    required this.title,
    required this.message,
    required this.onDelete,
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
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: onDelete,
              tooltip: 'Delete',
            ),
          ],
        ),
      ),
    );
  }
}

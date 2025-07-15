import 'package:flutter/material.dart';
import 'package:rx_vision/views/auth/auth_view.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Rx-Vision',
      theme: ThemeData(primarySwatch: Colors.blue, visualDensity: VisualDensity.adaptivePlatformDensity),
      home: const WelcomeView(),
    );
  }
}

class WelcomeView extends StatelessWidget {
  const WelcomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(40.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Spacer to push content down a bit
            const SizedBox(height: 80),

            // Welcome text
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Welcome to Rx Vision!',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w500, color: Colors.blue),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Managing Medicine Inventory has never been easier!',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w500, color: Colors.blue),
                ),
                const SizedBox(height: 8),
                Text(
                  'Push the Proceed button below to continue.',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w500, color: Colors.blue[800]),
                ),
              ],
            ),

            // Spacer to push the button to the bottom
            const Spacer(),

            // Proceed button
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => AuthView()));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[800],
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Proceed', style: TextStyle(fontSize: 18)),
                    SizedBox(width: 8),
                    Icon(Icons.arrow_forward, size: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  get medicineNumber => medicineNumber;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Rx Vision - Stock Details',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue, visualDensity: VisualDensity.adaptivePlatformDensity),
      home: StockDetailsView(medicineNumber: '$medicineNumber'),
    );
  }
}

class StockDetailsView extends StatelessWidget {
  final String medicineNumber;

  const StockDetailsView({super.key, required this.medicineNumber});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Stock Details - Medicine #$medicineNumber'), centerTitle: true, backgroundColor: Colors.blue[800], foregroundColor: Colors.white),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Stock Information for Medicine #$medicineNumber',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            SizedBox(height: 24),
            Text('Detailed stock data would appear here'),
            const SizedBox(height: 16),

            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  backgroundColor: Colors.blue[800],
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Colors.blue),
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

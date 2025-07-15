import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Prescription Details',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        dividerTheme: const DividerThemeData(
          thickness: 1,
          space: 20,
          color: Colors.grey,
        ),
      ),
      home: const PrescriptionDetailsView(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class PrescriptionDetailsView extends StatelessWidget {
  const PrescriptionDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Prescription Details'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Patient: Maria Santos',
              style: TextStyle(fontSize: 16, height: 1.5),
            ),
            const Text(
              'Doctor: Dr. Reyes',
              style: TextStyle(fontSize: 16, height: 1.5),
            ),
            const Text(
              'Date: June 24, 2025',
              style: TextStyle(fontSize: 16, height: 1.5),
            ),
            const SizedBox(height: 16),
            const Text(
              'Medicines Prescribed:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 8),
            _buildMedicineItem('Amoxicillin 500mg - 2x a day - 7days'),
            _buildMedicineItem('Paracetamol - 1 tablet - every 6 hours'),
            _buildMedicineItem('Vitamins C - 1x a day'),
            const SizedBox(height: 16),
            const Text(
              'NOTES: Take after meals. Refill after 1 week.',
              style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
            ),
            const Divider(),
            const SizedBox(height: 24),
            Center(
              child: ElevatedButton.icon(
                onPressed: () {
                  // Handle mark as dispensed
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Prescription marked as dispensed')),
                  );
                },
                icon: const Icon(Icons.check_circle_outline),
                label: const Text(
                  'Mark as Dispensed',
                  style: TextStyle(fontSize: 16),
                ),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(250, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMedicineItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 4.0, right: 8.0),
            child: Icon(Icons.circle, size: 8),
          ),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 16, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }
}
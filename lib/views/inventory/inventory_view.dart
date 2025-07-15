import 'package:flutter/material.dart';
import 'package:rx_vision/views/stock/stock_views.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Rx Vision - Inventory',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue, visualDensity: VisualDensity.adaptivePlatformDensity),
      home: InventoryView(),
    );
  }
}

class InventoryView extends StatelessWidget {
  const InventoryView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Inventory Page'), centerTitle: true, backgroundColor: Colors.blue[800], foregroundColor: Colors.white),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            _buildMedicineCard(context: context, title: 'Medicine #1', description: 'Description of Medicine #1'),
            const SizedBox(height: 16),
            _buildMedicineCard(context: context, title: 'Medicine #2', description: 'Description of Medicine #2'),
            const SizedBox(height: 16),
            _buildMedicineCard(context: context, title: 'Medicine #3', description: 'Description of Medicine #3'),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue[800], foregroundColor: Colors.white, minimumSize: const Size(double.infinity, 50)),
              child: const Text('Back'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMedicineCard({required String title, required String description, required BuildContext context}) {
    // Extract the medicine number from the title
    final medicineNumber = title.replaceAll('Medicine #', '');

    return Card(
      elevation: 4,
      margin: EdgeInsets.symmetric(horizontal: 16),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => StockDetailsView(medicineNumber: medicineNumber)));
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text(description, style: TextStyle(color: Colors.grey[600])),
            ],
          ),
        ),
      ),
    );
  }
}

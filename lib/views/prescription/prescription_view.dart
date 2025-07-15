import 'package:flutter/material.dart';
import 'package:rx_vision/views/prescription/add_prescription_view.dart';
import 'package:rx_vision/views/prescription/prescription_details_view.dart';
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Prescription Manager',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        dividerTheme: const DividerThemeData(thickness: 1, space: 0, color: Colors.grey),
      ),
      home: const PrescriptionView(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class Prescription {
  final String patientName;
  final String date;
  final String doctorName;
  final String itemCount;

  const Prescription({required this.patientName, required this.date, required this.doctorName, required this.itemCount});
}

class PrescriptionView extends StatelessWidget {
  const PrescriptionView({super.key});

  final List<Prescription> prescriptions = const [Prescription(patientName: 'Maria Santos', date: 'June 24', doctorName: 'Dr. Reyes', itemCount: '3 items')];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Prescription'),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context)),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.separated(
              itemCount: prescriptions.length,
              separatorBuilder: (context, index) => const Divider(),
              itemBuilder: (context, index) {
                final prescription = prescriptions[index];
                return _buildPrescriptionCard(prescription, context);
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => AddPrescriptionView())); // Handle upload new prescription
                  },
                  icon: const Icon(Icons.upload),
                  label: const Text('Upload New Prescription'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Back'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    side: const BorderSide(color: Colors.grey),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrescriptionCard(Prescription prescription, BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('${prescription.patientName} - ${prescription.date}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          TextButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const PrescriptionDetailsView())); // Handle view prescription details
            },
            child: const Text('View Prescription Details', style: TextStyle(color: Colors.blue)),
          ),
        ],
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 4.0),
        child: Text('${prescription.doctorName} - ${prescription.itemCount}', style: const TextStyle(fontSize: 14)),
      ),
    );
  }
}

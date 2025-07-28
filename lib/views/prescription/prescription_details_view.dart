import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PrescriptionDetailsView extends StatefulWidget {
  final Map<String, dynamic> prescription;

  const PrescriptionDetailsView({super.key, required this.prescription});

  @override
  State<PrescriptionDetailsView> createState() => _PrescriptionDetailsViewState();
}

class _PrescriptionDetailsViewState extends State<PrescriptionDetailsView> {
  Future<void> deletePrescription(BuildContext context) async {
    final id = widget.prescription['id'];
    final patientName = widget.prescription['patient_name'];

    final response = await http.delete(Uri.parse('http://localhost:3000/api/prescriptions/$id'));

    if (response.statusCode == 200) {
      // ✅ Send notification after successful deletion
      await http.post(
        Uri.parse('http://localhost:3000/api/notifications'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'title': 'Prescription Dispensed',
          'message': 'Prescription for $patientName has been marked as dispensed.',
        }),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Prescription marked as dispensed.'),
          backgroundColor: Colors.red, // 🔴 Make this red
        ),
      );
      Navigator.pop(context, true); // Send result back to trigger refresh
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to delete prescription.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final prescription = widget.prescription;

    return Scaffold(
      appBar: AppBar(title: const Text('Prescription Details')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Text("Patient Name: ${prescription['patient_name']}", style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 8),
            Text("Doctor Name: ${prescription['doctor_name']}", style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 8),
            Text("Date: ${prescription['date']}", style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 8),
            Text("Medication: ${prescription['medication']}", style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 8),
            Text("Dosage: ${prescription['dosage']}", style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 8),
            Text("Instructions: ${prescription['instructions']}", style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              icon: const Icon(Icons.check),
              label: const Text("Mark as Dispensed"),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () => deletePrescription(context),
            ),
          ],
        ),
      ),
    );
  }
}
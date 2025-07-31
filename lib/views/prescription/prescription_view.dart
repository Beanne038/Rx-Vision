// prescription_view.dart
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'add_prescription_view.dart';
import 'prescription_details_view.dart';

class PrescriptionView extends StatefulWidget {
  const PrescriptionView({super.key});

  @override
  State<PrescriptionView> createState() => _PrescriptionViewState();
}

class _PrescriptionViewState extends State<PrescriptionView> {
  List<dynamic> prescriptions = [];

  @override
  void initState() {
    super.initState();
    fetchPrescriptions();
  }

  Future<void> fetchPrescriptions() async {
    final response =
        await http.get(Uri.parse('http://192.168.1.7:3000/api/prescriptions'));

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      setState(() {
        prescriptions = jsonData['prescriptions'];
      });
    } else {
      throw Exception('Failed to load prescriptions');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Prescriptions')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: prescriptions.length,
              itemBuilder: (context, index) {
                final prescription = prescriptions[index];
                return Card(
                  margin: const EdgeInsets.all(8.0),
                  child: ListTile(
                    title: Text(prescription['patient_name']),
                    subtitle: Text(prescription['medication']),
                    trailing: ElevatedButton(
                      onPressed: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PrescriptionDetailsView(
                                prescription: prescription),
                          ),
                        );
                        if (result == true) {
                          fetchPrescriptions(); // Refresh after deletion
                        }
                      },
                      child: const Text('View Details'),
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 8),
            child: ElevatedButton.icon(
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const AddPrescriptionView()),
                );
                fetchPrescriptions(); // Refresh after adding
              },
              icon: const Icon(Icons.upload),
              label: const Text('Upload New Prescription'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                side: const BorderSide(color: Colors.grey),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 8),
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context); // Go back to previous screen
              },
              icon: const Icon(Icons.arrow_back),
              label: const Text('Back'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                side: const BorderSide(color: Colors.grey),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}


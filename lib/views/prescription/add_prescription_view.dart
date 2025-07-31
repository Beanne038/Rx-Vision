import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AddPrescriptionView extends StatefulWidget {
  const AddPrescriptionView({super.key});

  @override
  State<AddPrescriptionView> createState() => _AddPrescriptionViewState();
}

class _AddPrescriptionViewState extends State<AddPrescriptionView> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _patientNameController = TextEditingController();
  final TextEditingController _doctorNameController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _medicationController = TextEditingController();
  final TextEditingController _dosageController = TextEditingController();
  final TextEditingController _instructionsController = TextEditingController();

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    final patientName = _patientNameController.text.trim();
    final doctorName = _doctorNameController.text.trim();
    final body = jsonEncode({
      'patient_name': patientName,
      'doctor_name': doctorName,
      'date': _dateController.text.trim(),
      'medication': _medicationController.text.trim(),
      'dosage': _dosageController.text.trim(),
      'instructions': _instructionsController.text.trim(),
    });

    final response = await http.post(
      Uri.parse('http://192.168.1.7:3000/api/prescriptions'),
      headers: {'Content-Type': 'application/json'},
      body: body,
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      await http.post(
        Uri.parse('http://192.168.1.7:3000/api/notifications'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'title': 'New Prescription Added',
          'message': 'Prescription for $patientName by Dr. $doctorName has been added.',
        }),
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Prescription uploaded successfully')),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${response.body}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Upload New Prescription')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _patientNameController,
                decoration: const InputDecoration(labelText: 'Patient Name'),
                validator: (value) => value == null || value.trim().isEmpty ? 'Patient name is required' : null,
              ),
              TextFormField(
                controller: _doctorNameController,
                decoration: const InputDecoration(labelText: 'Doctor Name'),
                validator: (value) => value == null || value.trim().isEmpty ? 'Doctor name is required' : null,
              ),
              TextFormField(
                controller: _dateController,
                decoration: const InputDecoration(labelText: 'Date (e.g. June 24, 2025)'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Date is required';
                  }
                  final datePattern = RegExp(r'^[A-Z][a-z]+ \d{1,2}, \d{4}$');
                  if (!datePattern.hasMatch(value.trim())) {
                    return 'Enter date in format like: July 29, 2025';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _medicationController,
                decoration: const InputDecoration(labelText: 'Medication'),
                validator: (value) => value == null || value.trim().isEmpty ? 'Medication is required' : null,
              ),
              TextFormField(
                controller: _dosageController,
                decoration: const InputDecoration(labelText: 'Dosage'),
                validator: (value) => value == null || value.trim().isEmpty ? 'Dosage is required' : null,
              ),
              TextFormField(
                controller: _instructionsController,
                decoration: const InputDecoration(labelText: 'Instructions'),
                validator: (value) => value == null || value.trim().isEmpty ? 'Instructions are required' : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitForm,
                child: const Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

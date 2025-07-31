import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AddSupplierView extends StatefulWidget {
  final Map<String, dynamic>? supplier;
  const AddSupplierView({super.key, this.supplier});

  @override
  State<AddSupplierView> createState() => _AddSupplierViewState();
}

class _AddSupplierViewState extends State<AddSupplierView> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _contactPersonController = TextEditingController();
  final TextEditingController _contactNumberController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _lastDeliveryController = TextEditingController();
  final TextEditingController _productTypeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.supplier != null) {
      _nameController.text = widget.supplier!['name'] ?? '';
      _contactPersonController.text = widget.supplier!['contact_person'] ?? '';
      _contactNumberController.text = widget.supplier!['contact_number'] ?? '';
      _emailController.text = widget.supplier!['email'] ?? '';
      _addressController.text = widget.supplier!['address'] ?? '';
      _lastDeliveryController.text = widget.supplier!['last_delivery'] ?? '';
      _productTypeController.text = widget.supplier!['product_type'] ?? '';
    }
  }

Future<void> submitSupplier() async {
  if (_formKey.currentState!.validate()) {
    final supplier = {
      'name': _nameController.text,
      'contact_person': _contactPersonController.text,
      'contact_number': _contactNumberController.text,
      'email': _emailController.text,
      'address': _addressController.text.isEmpty ? null : _addressController.text,
      'last_delivery': _lastDeliveryController.text.isEmpty ? null : _lastDeliveryController.text,
      'product_type': _productTypeController.text.isEmpty ? null : _productTypeController.text,
    };

    final uri = widget.supplier == null
        ? Uri.parse('http://192.168.1.7:3000/api/suppliers')
        : Uri.parse('http://192.168.1.7:3000/api/suppliers/${widget.supplier!['id']}');

    final response = widget.supplier == null
        ? await http.post(uri, body: jsonEncode(supplier), headers: {'Content-Type': 'application/json'})
        : await http.put(uri, body: jsonEncode(supplier), headers: {'Content-Type': 'application/json'});

    if (response.statusCode == 200 || response.statusCode == 201) {
      // ✅ Send notification after successful add or update
      await http.post(
        Uri.parse('http://192.168.1.7:3000/api/notifications'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'title': widget.supplier == null ? 'New Supplier Added' : 'Supplier Updated',
          'message': 'Supplier ${_nameController.text} has been ${widget.supplier == null ? 'added' : 'updated'}.',
        }),
      );

      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to submit supplier')));
    }
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.supplier == null ? 'Add Supplier' : 'Edit Supplier')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
  controller: _nameController,
  decoration: const InputDecoration(labelText: 'Supplier Name'),
  validator: (value) => value == null || value.trim().isEmpty ? 'Supplier name is required' : null,
),
TextFormField(
  controller: _contactPersonController,
  decoration: const InputDecoration(labelText: 'Contact Person'),
  validator: (value) => value == null || value.trim().isEmpty ? 'Contact person is required' : null,
),
TextFormField(
  controller: _contactNumberController,
  decoration: const InputDecoration(labelText: 'Contact Number'),
  validator: (value) => value == null || value.trim().isEmpty ? 'Contact number is required' : null,
),
TextFormField(
  controller: _emailController,
  decoration: const InputDecoration(labelText: 'Email'),
  validator: (value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!emailRegex.hasMatch(value)) {
      return 'Enter a valid email';
    }
    return null;
  },
),
TextFormField(
  controller: _addressController,
  decoration: const InputDecoration(labelText: 'Address'),
),
TextFormField(
  controller: _lastDeliveryController,
  decoration: const InputDecoration(labelText: 'Last Delivery (YYYY-MM-DD)'),
  validator: (value) {
    if (value != null && value.trim().isNotEmpty) {
      final dateRegex = RegExp(r'^\d{4}-\d{2}-\d{2}$');
      if (!dateRegex.hasMatch(value)) {
        return 'Enter a valid date (YYYY-MM-DD)';
      }
    }
    return null;
  },
),
TextFormField(
  controller: _productTypeController,
  decoration: const InputDecoration(labelText: 'Product Type'),
),

                const SizedBox(height: 20),
                Padding(
  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 6),
  child: ElevatedButton.icon(
    onPressed: submitSupplier,
    icon: const Icon(Icons.check),
    label: Text(widget.supplier == null ? 'Add Supplier' : 'Update Supplier'),
    style: ElevatedButton.styleFrom(
      minimumSize: const Size(double.infinity, 50),
      backgroundColor: Colors.blue,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
  ),
),
Padding(
  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 6),
  child: OutlinedButton.icon(
    onPressed: () => Navigator.pop(context),
    icon: const Icon(Icons.cancel),
    label: const Text('Cancel'),
    style: OutlinedButton.styleFrom(
      minimumSize: const Size(double.infinity, 50),
      side: const BorderSide(color: Colors.grey),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
  ),
),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


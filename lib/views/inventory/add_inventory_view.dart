import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AddInventoryView extends StatefulWidget {
  final Map<String, dynamic>? inventory;
  const AddInventoryView({super.key, this.inventory});

  @override
  State<AddInventoryView> createState() => _AddInventoryViewState();
}

class _AddInventoryViewState extends State<AddInventoryView> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _supplierIdController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.inventory != null) {
      _nameController.text = widget.inventory!['item_name'] ?? '';
      _quantityController.text = widget.inventory!['quantity']?.toString() ?? '';
      _dateController.text = widget.inventory!['date_received'] ?? '';
      _supplierIdController.text = widget.inventory!['supplier_id']?.toString() ?? '';
    }
  }

  // ✅ Notification function
  Future<void> sendNotification(String title, String message) async {
    final uri = Uri.parse('http://192.168.1.7:3000/api/notifications');
    await http.post(uri,
      body: jsonEncode({'title': title, 'message': message}),
      headers: {'Content-Type': 'application/json'},
    );
  }

  Future<void> submitInventory() async {
    if (_formKey.currentState!.validate()) {
      final inventoryData = {
        'item_name': _nameController.text,
        'quantity': int.tryParse(_quantityController.text) ?? 0,
        'date_received': _dateController.text,
        'supplier_id': int.tryParse(_supplierIdController.text) ?? 0,
      };

      final uri = widget.inventory == null
          ? Uri.parse('http://192.168.1.7:3000/api/inventory')
          : Uri.parse('http://192.168.1.7:3000/api/inventory/${widget.inventory!['id']}');

      final response = widget.inventory == null
          ? await http.post(uri, body: jsonEncode(inventoryData), headers: {'Content-Type': 'application/json'})
          : await http.put(uri, body: jsonEncode(inventoryData), headers: {'Content-Type': 'application/json'});

      if (response.statusCode == 200 || response.statusCode == 201) {
        // ✅ Notification logic
        final action = widget.inventory == null ? 'added' : 'updated';
        final qty = inventoryData['quantity'];
        await sendNotification(
          'Stock $action',
          '${_nameController.text} was $action. Quantity: $qty.',
        );

        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to submit inventory (${response.statusCode})')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.inventory == null ? 'Add Inventory' : 'Edit Inventory'),
        backgroundColor: Colors.blue[800],
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
TextFormField(
  controller: _nameController,
  decoration: const InputDecoration(labelText: 'Item Name'),
  validator: (value) {
    if (value == null || value.trim().isEmpty) return 'Item name is required';
    return null;
  },
),
TextFormField(
  controller: _quantityController,
  decoration: const InputDecoration(labelText: 'Quantity'),
  keyboardType: TextInputType.number,
  validator: (value) {
    if (value == null || value.trim().isEmpty) return 'Quantity is required';
    final qty = int.tryParse(value);
    if (qty == null || qty < 0) return 'Enter a valid non-negative number';
    return null;
  },
),
TextFormField(
  controller: _dateController,
  decoration: const InputDecoration(labelText: 'Date Received (YYYY-MM-DD)'),
  validator: (value) {
    if (value == null || value.trim().isEmpty) return 'Date is required';
    final regex = RegExp(r'^\d{4}-\d{2}-\d{2}$');
    if (!regex.hasMatch(value)) return 'Enter date as YYYY-MM-DD';
    return null;
  },
),
TextFormField(
  controller: _supplierIdController,
  decoration: const InputDecoration(labelText: 'Supplier ID'),
  keyboardType: TextInputType.number,
  validator: (value) {
    if (value == null || value.trim().isEmpty) return 'Supplier ID is required';
    final id = int.tryParse(value);
    if (id == null || id <= 0) return 'Enter a valid positive Supplier ID';
    return null;
  },
),

              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 6),
                child: ElevatedButton.icon(
                  onPressed: submitInventory,
                  icon: const Icon(Icons.check),
                  label: Text(widget.inventory == null ? 'Add Item' : 'Update Item'),
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
    );
  }
}

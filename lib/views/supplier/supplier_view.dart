import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'add_supplier_view.dart';

class SupplierView extends StatefulWidget {
  const SupplierView({super.key});

  @override
  State<SupplierView> createState() => _SupplierViewState();
}

class _SupplierViewState extends State<SupplierView> {
  List<dynamic> suppliers = [];

  @override
  void initState() {
    super.initState();
    fetchSuppliers();
  }

  Future<void> fetchSuppliers() async {
    final response = await http.get(Uri.parse('http://192.168.1.7:3000/api/suppliers'));
    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      setState(() {
        suppliers = jsonData['suppliers'];
      });
    } else {
      throw Exception('Failed to load suppliers');
    }
  }

  Future<void> deleteSupplier(int id) async {
  final supplier = suppliers.firstWhere((s) => s['id'] == id);
  
  final response = await http.delete(Uri.parse('http://192.168.1.7:3000/api/suppliers/$id'));
  if (response.statusCode == 200) {
    // Send notification
    await http.post(
      Uri.parse('http://192.168.1.7:3000/api/notifications'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'title': 'Supplier Deleted',
        'message': 'Supplier ${supplier['name']} has been deleted.',
      }),
    );
    fetchSuppliers();
  } else {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to delete supplier')));
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Suppliers')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: suppliers.length,
              itemBuilder: (context, index) {
                final supplier = suppliers[index];
                return Card(
                  margin: const EdgeInsets.all(8),
                  child: ListTile(
                    title: Text(supplier['name']),
                    subtitle: Text(
                      'Contact: ${supplier['contact_person']}\n'
                      'Email: ${supplier['email']}',
                    ),
                    trailing: Row(
  mainAxisSize: MainAxisSize.min,
  children: [
    IconButton(
      icon: const Icon(Icons.visibility, color: Colors.green),
      onPressed: () {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Supplier Details'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Name: ${supplier['name']}'),
                Text('Contact Person: ${supplier['contact_person']}'),
                Text('Contact Number: ${supplier['contact_number']}'),
                Text('Email: ${supplier['email']}'),
                Text('Address: ${supplier['address']}'),
                Text('Last Delivery: ${supplier['last_delivery'] ?? 'N/A'}'),
                Text('Product Type: ${supplier['product_type'] ?? 'N/A'}'),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          ),
        );
      },
    ),
    IconButton(
      icon: const Icon(Icons.edit, color: Colors.blue),
      onPressed: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AddSupplierView(supplier: supplier),
          ),
        );
        fetchSuppliers();
      },
    ),
    IconButton(
      icon: const Icon(Icons.delete, color: Colors.red),
      onPressed: () => deleteSupplier(supplier['id']),
    ),
  ],
),
                  ),
                );
              },
            ),
          ),

          // ✅ Add Supplier Button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 6),
            child: ElevatedButton.icon(
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AddSupplierView()),
                );
                fetchSuppliers();
              },
              icon: const Icon(Icons.add),
              label: const Text('Add Supplier'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: Colors.blue,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ),

          // ✅ Back Button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 6),
            child: OutlinedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back),
              label: const Text('Back'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                side: const BorderSide(color: Colors.grey),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

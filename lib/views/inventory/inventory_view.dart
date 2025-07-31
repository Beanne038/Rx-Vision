// inventory_view.dart

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'add_inventory_view.dart';

class InventoryView extends StatefulWidget {
  const InventoryView({super.key});

  @override
  State<InventoryView> createState() => _InventoryViewState();
}

class _InventoryViewState extends State<InventoryView> {
  List<Map<String, dynamic>> _inventory = [];

  @override
  void initState() {
    super.initState();
    fetchInventory();
  }

  Future<void> fetchInventory() async {
    final response = await http.get(Uri.parse('http://192.168.1.7:3000/api/inventory'));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        _inventory = List<Map<String, dynamic>>.from(data['inventory']);
      });
    } else {
      setState(() {
        _inventory = [];
      });
    }
  }

  Future<void> deleteInventory(int id) async {
  final response = await http.delete(Uri.parse('http://192.168.1.7:3000/api/inventory/$id'));
  if (response.statusCode == 200) {
    // Send notification
    await http.post(
      Uri.parse('http://192.168.1.7:3000/api/notifications'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'title': 'Inventory Deleted',
        'message': 'An inventory item was deleted.',
        'timestamp': DateTime.now().toIso8601String(),
      }),
    );
    fetchInventory();
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Failed to delete item (${response.statusCode})')),
    );
  }
}


  void showInventoryDetails(Map<String, dynamic> item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Inventory Details'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Item Name: ${item['item_name'] ?? 'N/A'}'),
            Text('Quantity: ${item['quantity'] ?? 'N/A'}'),
            Text('Date Received: ${item['date_received'] ?? 'N/A'}'),
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventory Page'),
        centerTitle: true,
        backgroundColor: Colors.blue[800],
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: _inventory.isEmpty
                  ? const Center(child: Text('No inventory found.'))
                  : ListView.builder(
                      itemCount: _inventory.length,
                      itemBuilder: (context, index) {
                        final item = _inventory[index];
                        return Card(
                          elevation: 4,
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          child: ListTile(
                            title: Text(item['item_name'] ?? 'Unknown Item'),
                            subtitle: Text(
                              'Quantity: ${item['quantity']} | '
                              'Date: ${item['date_received'] ?? 'N/A'}',
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.visibility, color: Colors.green),
                                  onPressed: () => showInventoryDetails(item),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.edit, color: Colors.blue),
                                  onPressed: () async {
                                    await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => AddInventoryView(inventory: item),
                                      ),
                                    );
                                    fetchInventory();
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () => deleteInventory(item['id']),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ),

          // ✅ Add Inventory Button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 6),
            child: ElevatedButton.icon(
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AddInventoryView()),
                );
                fetchInventory();
              },
              icon: const Icon(Icons.add),
              label: const Text('Add Inventory'),
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

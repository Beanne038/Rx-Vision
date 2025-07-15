import 'package:flutter/material.dart';
import 'package:rx_vision/views/supplier/add_supplier_view.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Supplier Management',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        cardTheme: CardThemeData(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        ),
      ),
      home: const SupplierView(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class Supplier {
  final String name;
  final String email;
  final String phone;
  final String address;
  final String lastDelivery;
  final Color cardColor;

  Supplier({
    required this.name,
    required this.email,
    required this.phone,
    required this.address,
    required this.lastDelivery,
    this.cardColor = Colors.white,
  });

  Supplier copyWith({
    String? name,
    String? email,
    String? phone,
    String? address,
    String? lastDelivery,
    Color? cardColor,
  }) {
    return Supplier(
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      lastDelivery: lastDelivery ?? this.lastDelivery,
      cardColor: cardColor ?? this.cardColor,
    );
  }
}

class SupplierView extends StatefulWidget {
  const SupplierView({super.key});

  @override
  State<SupplierView> createState() => _SupplierViewState();
}

class _SupplierViewState extends State<SupplierView> {
  List<Supplier> suppliers = [
    Supplier(
      name: 'MedTrustPharma',
      email: 'medtrust@email.com',
      phone: '0917-4378-123',
      address: '123 Pharma St, Medicine City',
      lastDelivery: 'June 20',
      cardColor: const Color(0xFFE3F2FD),
    ),
    Supplier(
      name: 'BioPlus Distributions',
      email: 'bioplus@email.com',
      phone: '0928-9876-456',
      address: '456 Bio Ave, Science Park',
      lastDelivery: 'June 15',
      cardColor: const Color(0xFFE8F5E9),
    ),
  ];

  void _editSupplier(int index) {
    final supplier = suppliers[index];
    final nameController = TextEditingController(text: supplier.name);
    final emailController = TextEditingController(text: supplier.email);
    final phoneController = TextEditingController(text: supplier.phone);
    final addressController = TextEditingController(text: supplier.address);
    final deliveryController = TextEditingController(text: supplier.lastDelivery);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Supplier'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Name'),
                ),
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(labelText: 'Email'),
                ),
                TextField(
                  controller: phoneController,
                  decoration: const InputDecoration(labelText: 'Phone'),
                ),
                TextField(
                  controller: addressController,
                  decoration: const InputDecoration(labelText: 'Address'),
                ),
                TextField(
                  controller: deliveryController,
                  decoration: const InputDecoration(labelText: 'Last Delivery'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  suppliers[index] = supplier.copyWith(
                    name: nameController.text,
                    email: emailController.text,
                    phone: phoneController.text,
                    address: addressController.text,
                    lastDelivery: deliveryController.text,
                  );
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Supplier updated successfully')),
                );
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _deleteSupplier(int index) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Supplier'),
          content: Text('Are you sure you want to delete ${suppliers[index].name}?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white
              ),
              onPressed: () {
                setState(() {
                  suppliers.removeAt(index);
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Supplier deleted successfully')),
                );
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Suppliers'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: suppliers.length,
              itemBuilder: (context, index) {
                final supplier = suppliers[index];
                return _buildSupplierCard(context, supplier, index);
              },
            ),
          ),
          _buildAddSupplierButton(context),
          _buildBackButton(context),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

 Widget _buildSupplierCard(BuildContext context, Supplier supplier, int index) {
  return Card(
    color: supplier.cardColor,
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                supplier.name,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () {
                  _showSupplierProfile(context, supplier);
                },
                child: const Text(
                  'Supplier Profile',
                  style: TextStyle(color: Colors.blue),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.email, size: 16),
              const SizedBox(width: 8),
              Text(supplier.email),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.phone, size: 16),
              const SizedBox(width: 8),
              Text(supplier.phone),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.location_on, size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  supplier.address,
                  softWrap: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.local_shipping, size: 16),
              const SizedBox(width: 8),
              Text('Last Delivery: ${supplier.lastDelivery}'),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                icon: const Icon(Icons.edit, size: 20),
                color: Colors.blue,
                onPressed: () => _editSupplier(index),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.delete, size: 20),
                color: Colors.red,
                onPressed: () => _deleteSupplier(index),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

  Widget _buildAddSupplierButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: ElevatedButton.icon(
        icon: const Icon(Icons.add),
        label: const Text('Add New Supplier'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue[800],
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => AddSupplierView())); // Navigate to add new supplier screen
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Add New Supplier clicked')),
          );
        },
      ),
    );
  }

  Widget _buildBackButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(double.infinity, 50),
          side: const BorderSide(color: Colors.grey),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        onPressed: () {
          Navigator.pop(context);
        },
        child: const Text('Back'),
      ),
    );
  }

  void _showSupplierProfile(BuildContext context, Supplier supplier) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(supplier.name),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Email: ${supplier.email}'),
              const SizedBox(height: 8),
              Text('Phone: ${supplier.phone}'),
              const SizedBox(height: 8),
              Text('Address: ${supplier.address}'),
              const SizedBox(height: 8),
              Text('Last Delivery: ${supplier.lastDelivery}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }
}
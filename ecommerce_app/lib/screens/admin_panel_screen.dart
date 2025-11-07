import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecommerce_app/screens/admin_order_screen.dart'; // 1. ADD THIS

class AdminPanelScreen extends StatefulWidget {
  const AdminPanelScreen({super.key});

  @override
  State<AdminPanelScreen> createState() => _AdminPanelScreenState();
}

class _AdminPanelScreenState extends State<AdminPanelScreen> {
  // 1. A key to validate our Form
  final _formKey = GlobalKey<FormState>();

  // 2. Controllers for each text field
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _imageUrlController = TextEditingController(); // For the image link

  // 3. A variable to show a loading spinner
  bool _isLoading = false;

  // 4. An instance of Firestore to save data
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 5. Clean up the controllers
  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  Future<void> _uploadProduct() async {
    // 1. First, check if all form fields are valid
    if (!_formKey.currentState!.validate()) {
      return; // If not, do nothing
    }

    // 2. Show the loading spinner
    setState(() {
      _isLoading = true;
    });

    try {
      // 3. Get the text from our URL controller
      String imageUrl = _imageUrlController.text.trim();

      // 4. Add the data to a new 'products' collection
      await _firestore.collection('products').add({
        'name': _nameController.text.trim(),
        'description': _descriptionController.text.trim(),
        // 5. Try to parse the price text as a number
        'price': double.tryParse(_priceController.text.trim()) ?? 0.0,
        'imageUrl': imageUrl, // 6. Save the URL string
        'createdAt': FieldValue.serverTimestamp(),
      });

      // 7. If successful, show a confirmation message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Product uploaded successfully!')),
      );

      // 8. Clear all the text fields
      _formKey.currentState!.reset();
      _nameController.clear();
      _descriptionController.clear();
      _priceController.clear();
      _imageUrlController.clear();
    } catch (e) {
      // 9. If something went wrong, show an error
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to upload product: $e')));
    } finally {
      // 10. ALWAYS hide the loading spinner
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // 1. Let's change the title to be more general
        title: const Text('Admin Panel'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            // 2. Find this Column
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 3. --- ADD THIS NEW BUTTON ---
              ElevatedButton.icon(
                icon: const Icon(Icons.list_alt),
                label: const Text('Manage All Orders'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo, // A different color
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(fontSize: 16),
                ),
                onPressed: () {
                  // 4. Navigate to our new screen
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const AdminOrderScreen(),
                    ),
                  );
                },
              ),

              // 5. A divider to separate it
              const Divider(height: 30, thickness: 1),

              const Text(
                'Add New Product',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),

              // 6. The rest of your form (wrapped in its own Form widget)
              Form(
                key: _formKey,
                child: Column(
                  // ... (your existing form with Image URL, Name, Price, etc.)
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

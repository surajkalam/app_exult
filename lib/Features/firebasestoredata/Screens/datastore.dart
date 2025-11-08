import 'dart:io';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:coffee_exult_app/Features/Home/models/items_model.dart';

class Datadstore extends StatefulWidget {
  const Datadstore({super.key});

  @override
  State<Datadstore> createState() => _DatadstoreState();
}

class _DatadstoreState extends State<Datadstore> {
  TextEditingController namecontroller = TextEditingController();
  TextEditingController typecontroller = TextEditingController();
  TextEditingController ratingcontroller = TextEditingController();
  TextEditingController descriptioncontroller = TextEditingController();
  TextEditingController pricecontroller = TextEditingController();

  File? _selectedImage;
  String? _imageUrl;
  bool _isUploading = false;
  bool _isSubmitting = false;
  String _selectedCategory = 'Coffee'; // Default category

  // List of available categories
  final List<String> _categories = [
    'Coffee',
    'Tea',
    'Cooler',
    'Snacks',
    'Frozen',
    'Crispy Delicious',
    'Breadcraft',
    'House specials',
    'Continental',
    'DessertDuo',
  ];

  @override
  Widget build(BuildContext context) {
    // var height = MediaQuery.of(context).size.height;
    // var width = MediaQuery.of(context).size.width;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.grey[100],
      body: Padding(
        padding: EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Text(
                'Items store',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 10),
              // Category Selection Section
              Text(
                'Select Category:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _categories.map((category) {
                  return ChoiceChip(
                    label: Text(category),
                    selected: _selectedCategory == category,
                    selectedColor: Colors.blue,
                    labelStyle: TextStyle(
                      color: _selectedCategory == category
                          ? Colors.white
                          : Colors.black,
                    ),
                    onSelected: (selected) {
                      setState(() {
                        _selectedCategory = category;
                      });
                    },
                  );
                }).toList(),
              ),

              SizedBox(height: 20),

              // Selected Category Display
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  // ignore: deprecated_member_use
                  color: Colors.blue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue),
                ),
                child: Text(
                  'Selected: $_selectedCategory',
                  style: TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              SizedBox(height: 20),

              // Image Upload Section
              GestureDetector(
                onTap: _pickImageFromGallery,
                child: Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(
                      color: _selectedImage != null
                          ? Colors.green
                          : Colors.blue,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 6,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: _selectedImage != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(13),
                          child: Image.file(_selectedImage!, fit: BoxFit.cover),
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.camera_alt,
                              size: 40,
                              color: Colors.blue,
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Tap to upload image',
                              style: TextStyle(
                                color: Colors.blue,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                ),
              ),

              SizedBox(height: 20),

              // Upload Status
              if (_isUploading)
                Column(
                  children: [
                    CircularProgressIndicator(color: Colors.blue),
                    SizedBox(height: 8),
                    Text(
                      'Uploading image...',
                      style: TextStyle(color: Colors.blue),
                    ),
                  ],
                ),

              if (_imageUrl != null)
                Text(
                  '✓ Image uploaded successfully',
                  style: TextStyle(color: Colors.green, fontSize: 12),
                ),

              SizedBox(height: 20),

              // Form Fields with proper styling
              _buildTextField(
                controller: namecontroller,
                hintText: 'Item name',
                icon: Icons.fastfood,
              ),

              SizedBox(height: 12),

              _buildTextField(
                controller: typecontroller,
                hintText: 'Type name',
                icon: Icons.category,
              ),

              SizedBox(height: 12),

              _buildTextField(
                controller: ratingcontroller,
                hintText: 'Rating (e.g., 4.5)',
                icon: Icons.star,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
              ),

              SizedBox(height: 12),

              _buildTextField(
                controller: descriptioncontroller,
                hintText: 'Description',
                icon: Icons.description,
                maxLines: 3,
              ),

              SizedBox(height: 12),

              _buildTextField(
                controller: pricecontroller,
                hintText: 'Price (e.g., 12.99)',
                icon: Icons.attach_money,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
              ),

              SizedBox(height: 25),

              // Submit Button
              _isSubmitting
                  ? CircularProgressIndicator(color: Colors.blue)
                  : ElevatedButton(
                      onPressed: _submitForm,
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(double.infinity, 55),
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 4,
                      ),
                      child: Text(
                        'Submit Item',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper method to create styled TextFields
  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      style: TextStyle(color: Colors.black87, fontSize: 16),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: Colors.black),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.blue, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.blue, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.blue, width: 2.0),
        ),
        filled: true,
        fillColor: Colors.white,
        prefixIcon: Icon(icon, color: Colors.blue),
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }

  // Method to pick image from gallery
  Future<void> _pickImageFromGallery() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
          _imageUrl = null;
        });
        await _uploadImageToFirebase();
      }
    } catch (e) {
      log('Error picking image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error accessing gallery: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Method to upload image to Firebase Storage
  Future<void> _uploadImageToFirebase() async {
    if (_selectedImage == null) return;

    setState(() {
      _isUploading = true;
    });

    try {
      final storageRef = FirebaseStorage.instance.ref();
      String fileName =
          'items/image_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final imageRef = storageRef.child(fileName);

      final uploadTask = imageRef.putFile(_selectedImage!);
      final snapshot = await uploadTask.whenComplete(() {});

      _imageUrl = await snapshot.ref.getDownloadURL();

      log('Image URL: $_imageUrl');
      log('Upload completed at: ${DateTime.now()}');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Image uploaded successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      log('Error uploading image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error uploading image: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  // Method to submit form data to Firestore
  void _submitForm() async {
    if (namecontroller.text.isEmpty ||
        typecontroller.text.isEmpty ||
        ratingcontroller.text.isEmpty ||
        descriptioncontroller.text.isEmpty ||
        pricecontroller.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please fill all fields'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_imageUrl == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please upload an image first'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final newItem = Item(
        name: namecontroller.text.trim(),
        type: typecontroller.text.trim(),
        rating: double.parse(ratingcontroller.text.trim()),
        image: _imageUrl!,
        description: descriptioncontroller.text.trim(),
        price: double.parse(pricecontroller.text.trim()),
        category: _selectedCategory.toLowerCase(),
        timestamp: Timestamp.now(),
        itemType: 'normal',
      );

      await addItem(newItem, customCategory: _selectedCategory);

      _clearForm();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Item added successfully!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      log('Error submitting form: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error submitting item: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  // Method to clear form
  void _clearForm() {
    namecontroller.clear();
    typecontroller.clear();
    ratingcontroller.clear();
    descriptioncontroller.clear();
    pricecontroller.clear();
    setState(() {
      _selectedImage = null;
      _imageUrl = null;
      _selectedCategory = 'Coffee'; // Reset to default category
    });
  }

  // Firestore method to add item
  Future<void> addItem(Item item, {String? customCategory}) async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    try {
      final String category = customCategory ?? item.category;

      await firestore
          .collection('items')
          .doc('1757264051191711')
          .collection(category)
          .add(item.toMap());

      log('Item added successfully: ${item.name}');
      log('Image URL: ${item.image}');
      log('Category: $category');
    } catch (e) {
      log('Error adding item: $e');
      rethrow;
    }
  }

  @override
  void dispose() {
    namecontroller.dispose();
    typecontroller.dispose();
    ratingcontroller.dispose();
    descriptioncontroller.dispose();
    pricecontroller.dispose();
    super.dispose();
  }
}

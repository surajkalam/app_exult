// ignore: file_names
import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class VoucherdataStoreScreen extends StatefulWidget {
  const VoucherdataStoreScreen({super.key});

  @override
  State<VoucherdataStoreScreen> createState() => _VoucherdataStoreScreeState();
}

class _VoucherdataStoreScreeState extends State<VoucherdataStoreScreen> {
  File? _selectedImage;
  String? _imageUrl;
  bool _isUploading = false;
  bool _isSubmitting = false;
  String _selectedCategory = 'Coffee';
  TextEditingController _offerPercentageController = TextEditingController();
  TextEditingController _validUntilController = TextEditingController();
  TextEditingController _voucherIdController = TextEditingController();
  DateTime? _selectedDate;

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
  void initState() {
    super.initState();
    _offerPercentageController = TextEditingController();
    _validUntilController = TextEditingController();
    _voucherIdController = TextEditingController(text: _generateVoucherId());
  }

  @override
  void dispose() {
    _offerPercentageController.dispose();
    _validUntilController.dispose();
    _voucherIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.grey[100],
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Text(
                'voucher items',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 10),
              // Category Selection
              Text(
                'Select Category:',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 10),
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
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue),
                ),
                child: Text(
                  'Selected: $_selectedCategory',
                  style: const TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Voucher ID Field
              _buildTextField(
                controller: _voucherIdController,
                hintText: 'Voucher ID (auto-generated)',
                icon: Icons.tag,
                keyboardType: TextInputType.text,
              ),
              const SizedBox(height: 20),

              // Offer Percentage Field
              _buildTextField(
                controller: _offerPercentageController,
                hintText: 'Offer Percentage (e.g., 20)',
                icon: Icons.percent,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 20),

              // Valid Until Date Field
              TextField(
                controller: _validUntilController,
                readOnly: true,
                decoration: InputDecoration(
                  labelText: 'Valid Until',
                  labelStyle: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                  ),
                  hintText: 'Select date',
                  hintStyle: TextStyle(color: Colors.black, fontSize: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: Icon(Icons.calendar_today, color: Colors.blue),
                  suffixIcon: IconButton(
                    icon: Icon(Icons.calendar_month, color: Colors.blue),
                    onPressed: () => _selectDate(context),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Colors.blue,
                      width: 1.5,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Colors.blue,
                      width: 2.0,
                    ),
                  ),
                ),
                onTap: () => _selectDate(context),
              ),
              const SizedBox(height: 20),

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
                    boxShadow: const [
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
                      : const Column(
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
              const SizedBox(height: 20),

              // Upload Status
              if (_isUploading)
                const Column(
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
                const Text(
                  '✓ Image uploaded successfully',
                  style: TextStyle(color: Colors.green, fontSize: 12),
                ),
              const SizedBox(height: 20),

              // Submit Button
              _isSubmitting
                  ? const CircularProgressIndicator(color: Colors.blue)
                  : ElevatedButton(
                      onPressed: _submitForm,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 55),
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 4,
                      ),
                      child: const Text(
                        'Create Voucher',
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

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.blue,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
            dialogBackgroundColor: Colors.white,
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _validUntilController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

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
    style: const TextStyle(color: Colors.black, fontSize: 16),
    decoration: InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(color: Colors.grey, fontSize: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.black, width: 1.5), // ✅ Changed to black
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.black, width: 1.5), // ✅ Changed to black
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.black, width: 2.0), // ✅ Changed to black
      ),
      filled: true,
      fillColor: Colors.white,
      prefixIcon: Icon(icon, color: Colors.black), // ✅ Changed to black
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 14,
      ),
    ),
  );
}

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

  String _generateVoucherId() {
    final random = DateTime.now().millisecondsSinceEpoch;
    return 'VOUCH${random.toString().substring(8)}';
  }

  Future<void> _uploadImageToFirebase() async {
    if (_selectedImage == null) return;

    setState(() {
      _isUploading = true;
    });

    try {
      final storageRef = FirebaseStorage.instance.ref();
      String fileName =
          'items/Voucher/image_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final imageRef = storageRef.child(fileName);

      log('Starting image upload...');
      final uploadTask = imageRef.putFile(_selectedImage!);

      // Monitor upload progress
      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        log('Upload progress: ${snapshot.bytesTransferred}/${snapshot.totalBytes}');
      });

      final snapshot = await uploadTask.whenComplete(() {});
      log('Upload task completed');

      _imageUrl = await snapshot.ref.getDownloadURL();
      log('Image URL obtained: $_imageUrl');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Image uploaded successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      log('Error uploading image: $e');
      setState(() {
        _imageUrl = null; // Reset URL on error
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error uploading image: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }

  void _submitForm() async {
    // Check if image is still uploading
    if (_isUploading) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please wait for image upload to complete'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (_selectedImage != null && _imageUrl == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Image upload failed. Please try uploading again'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_imageUrl == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please upload an image first'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_voucherIdController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a voucher ID'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_offerPercentageController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter offer percentage'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a valid until date'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      // Store category, image URL, and offer percentage in Firestore
      await _storeCategoryData();

      _clearForm();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Voucher "${_voucherIdController.text.trim()}" created successfully!'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      log('Error storing data: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error storing data: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  Future<void> _storeCategoryData() async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    try {
      // Parse offer percentage to double
      double offerPercentage = double.parse(
        _offerPercentageController.text.trim(),
      );

      // Store category, image, offer data, voucher ID and valid until date
      final data = {
        'category': _selectedCategory,
        'imageUrl': _imageUrl,
        'offerPercentage': offerPercentage,
        'voucherId': _voucherIdController.text.trim(),
        'validUntil': Timestamp.fromDate(_selectedDate!),
        'timestamp': Timestamp.now(),
      };

      await firestore
          .collection('items')
          .doc('voucher')
          .collection('categories')
          .add(data);

      log('Category data stored successfully: $_selectedCategory');
      log('Image URL: $_imageUrl');
      log('Voucher ID: ${_voucherIdController.text.trim()}');
      log('Offer Percentage: $offerPercentage%');
      log('Valid Until: ${_selectedDate!.toString()}');
    } catch (e) {
      log('Error storing category data: $e');
      rethrow;
    }
  }

  void _clearForm() {
    setState(() {
      _selectedImage = null;
      _imageUrl = null;
      _selectedCategory = 'Coffee';
      _voucherIdController.text = _generateVoucherId(); // Generate new voucher ID
      _offerPercentageController.clear();
      _validUntilController.clear();
      _selectedDate = null;
    });
  }
}

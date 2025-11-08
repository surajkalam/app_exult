// screens/add_edit_item_screen.dart
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:coffee_exult_app/Features/Home/models/models.dart';
import 'package:coffee_exult_app/Features/firebasestoredata/provider/admin_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

class AddEditItemScreen extends ConsumerStatefulWidget {
  final Item? item;

  const AddEditItemScreen({super.key, this.item});

  @override
  ConsumerState<AddEditItemScreen> createState() => _AddEditItemScreenState();
}

class _AddEditItemScreenState extends ConsumerState<AddEditItemScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _typeController = TextEditingController();
  final TextEditingController _ratingController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();

  File? _selectedImage;
  String _selectedCategory = 'Coffee';
  bool _isSubmitting = false;
  String _selectedItemType = 'normal';

  final List<String> _categories = [
    'Coffee',
    'Tea',
    'Cooler',
    'Snacks',
    'Frozen',
    'Crispy Delicious',
    'Breadcraft',
    'House Specials',
    'Continental',
    'DessertDuo',
  ];
  final List<String> _itemTypes = ['normal', 'new_arrivals', 'seasonal'];
  @override
  void initState() {
    super.initState();
    if (widget.item != null) {
      // Editing existing item
      _nameController.text = widget.item!.name;
      _typeController.text = widget.item!.type;
      _ratingController.text = widget.item!.rating.toString();
      _descriptionController.text = widget.item!.description;
      _priceController.text = widget.item!.price.toString();
      _selectedCategory = widget.item!.category;
      _selectedItemType = widget.item!.itemType;
    }
  }

  @override
  Widget build(BuildContext context) {
    final imageState = ref.watch(imageUploadProvider);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(widget.item == null ? 'Add New Item' : 'Edit Item'),
        backgroundColor: const Color(0xFF6D4C41),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Image Upload Section
              _buildImageUploadSection(imageState),
              const SizedBox(height: 24),

              // Category Selection
              _buildCategorySection(),
              const SizedBox(height: 20),

              // Item Type Selection
              _buildItemTypeSection(),
              const SizedBox(height: 20),

              // Form Fields
              _buildFormFields(),
              const SizedBox(height: 30),

              // Submit Button
              _buildSubmitButton(imageState),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageUploadSection(ImageUploadState imageState) {
    final currentImage = widget.item?.image;

    return Column(
      children: [
        GestureDetector(
          onTap: _pickImageFromGallery,
          child: Container(
            width: 150,
            height: 150,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(
                color: (_selectedImage != null || currentImage != null)
                    ? Colors.green
                    : const Color(0xFF6D4C41),
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
                : currentImage != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(13),
                    child: Image.network(currentImage, fit: BoxFit.cover),
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.camera_alt,
                        size: 40,
                        color: const Color(0xFF6D4C41),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Tap to upload image',
                        style: TextStyle(
                          color: const Color(0xFF6D4C41),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
        const SizedBox(height: 10),
        if (imageState.isUploading)
          Column(
            children: [
              const CircularProgressIndicator(color: Color(0xFF6D4C41)),
              const SizedBox(height: 8),
              Text(
                'Uploading image...',
                style: TextStyle(color: const Color(0xFF6D4C41)),
              ),
            ],
          ),
        if (imageState.imageUrl != null)
          Text(
            '✓ Image uploaded successfully',
            style: TextStyle(color: Colors.green, fontSize: 12),
          ),
        if (imageState.error != null)
          Text(
            'Error: ${imageState.error}',
            style: const TextStyle(color: Colors.red, fontSize: 12),
          ),
      ],
    );
  }

  Widget _buildCategorySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Category:',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF5D4037),
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _categories.map((category) {
            return ChoiceChip(
              label: Text(category),
              selected: _selectedCategory == category,
              selectedColor: const Color(0xFF6D4C41),
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
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFF6D4C41).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFF6D4C41)),
          ),
          child: Text(
            'Selected: $_selectedCategory',
            style: const TextStyle(
              color: Color(0xFF6D4C41),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFormFields() {
    return Column(
      children: [
        _buildTextField(
          controller: _nameController,
          hintText: 'Item name',
          icon: Icons.coffee,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter item name';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _typeController,
          hintText: 'Type name',
          icon: Icons.category,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter type';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _ratingController,
          hintText: 'Rating (1.0 - 5.0)',
          icon: Icons.star,
          keyboardType: TextInputType.numberWithOptions(decimal: true),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter rating';
            }
            final rating = double.tryParse(value);
            if (rating == null || rating < 1.0 || rating > 5.0) {
              return 'Please enter valid rating (1.0 - 5.0)';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _descriptionController,
          hintText: 'Description',
          icon: Icons.description,
          maxLines: 3,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter description';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _priceController,
          hintText: 'Price (e.g., 12.99)',
          icon: Icons.attach_money,
          keyboardType: TextInputType.numberWithOptions(decimal: true),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter price';
            }
            if (double.tryParse(value) == null) {
              return 'Please enter valid price';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      style: const TextStyle(color: Colors.black87, fontSize: 16),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(color: Colors.grey),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF6D4C41), width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF6D4C41), width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF6D4C41), width: 2.0),
        ),
        filled: true,
        fillColor: Colors.white,
        prefixIcon: Icon(icon, color: const Color(0xFF6D4C41)),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
      validator: validator,
    );
  }

  Widget _buildSubmitButton(ImageUploadState imageState) {
    return _isSubmitting
        ? const CircularProgressIndicator(color: Color(0xFF6D4C41))
        : SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton(
              onPressed: () => _submitForm(imageState),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6D4C41),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 4,
              ),
              child: Text(
                widget.item == null ? 'Add Item' : 'Update Item',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
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
        });
        await ref
            .read(imageUploadProvider.notifier)
            .uploadImage(_selectedImage!);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error accessing gallery: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _submitForm(ImageUploadState imageState) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final imageUrl = imageState.imageUrl ?? widget.item?.image;
    if (imageUrl == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
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
      final item = Item(
        id: widget.item?.id,
        name: _nameController.text.trim(),
        type: _typeController.text.trim(),
        rating: double.parse(_ratingController.text.trim()),
        image: imageUrl,
        description: _descriptionController.text.trim(),
        price: double.parse(_priceController.text.trim()),
        category: _selectedCategory.toLowerCase(),
        timestamp: widget.item?.timestamp ?? Timestamp.now(),
        itemType: _selectedItemType,
      );

      if (widget.item == null) {
        // Add new item
        await ref.read(itemsProvider.notifier).addItem(item, _selectedCategory);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Item added successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        // Update existing item
        await ref
            .read(itemsProvider.notifier)
            .updateItem(item, _selectedCategory);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Item updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }

      // Clear image state if it was a new upload
      if (imageState.imageUrl != null) {
        ref.read(imageUploadProvider.notifier).clearImage();
      }

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  Widget _buildItemTypeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Item Type:',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF5D4037),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: const Color(0xFF6D4C41), width: 1.5),
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedItemType,
              isExpanded: true,
              icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF6D4C41)),
              style: const TextStyle(color: Colors.black87, fontSize: 16),
              items: _itemTypes.map((String type) {
                return DropdownMenuItem<String>(
                  value: type,
                  child: Text(
                    _getItemTypeDisplayName(type),
                    style: const TextStyle(fontSize: 16),
                  ),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedItemType = newValue!;
                });
              },
            ),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFF6D4C41).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFF6D4C41)),
          ),
          child: Text(
            'Type: ${_getItemTypeDisplayName(_selectedItemType)}',
            style: const TextStyle(
              color: Color(0xFF6D4C41),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  // Helper method to get display name for item type
  String _getItemTypeDisplayName(String type) {
    switch (type) {
      case 'new_arrivals':
        return 'New Arrivals';
      case 'seasonal':
        return 'Seasonal Items';
      case 'normal':
        return 'Normal Items';
      default:
        return 'Normal Items';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _typeController.dispose();
    _ratingController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    super.dispose();
  }
}

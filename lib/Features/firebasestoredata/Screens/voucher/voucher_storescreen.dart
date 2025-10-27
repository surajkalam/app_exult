// screens/voucher_store_screen.dart
import 'dart:io';
import 'package:coffee_exult_app/Features/firebasestoredata/Screens/voucher/editvoucher_bottomsheet.dart';
import 'package:coffee_exult_app/Features/firebasestoredata/provider/voucher_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class VoucherStoreScreen extends ConsumerStatefulWidget {
  const VoucherStoreScreen({super.key});

  @override
  ConsumerState<VoucherStoreScreen> createState() => _VoucherStoreScreenState();
}

class _VoucherStoreScreenState extends ConsumerState<VoucherStoreScreen> {
  final TextEditingController _offerPercentageController = TextEditingController();
  final TextEditingController _validUntilController = TextEditingController();
  DateTime? _selectedDate;
  File? _selectedImage;
  String _selectedCategory = 'Coffee';

  @override
  void initState() {
    super.initState();
    // Fetch vouchers when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(voucherProvider.notifier).fetchAllVouchers();
    });
  }

  @override
  void dispose() {
    _offerPercentageController.dispose();
    _validUntilController.dispose();
    super.dispose();
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
      }
    } catch (e) {
      _showErrorSnackBar('Error accessing gallery: $e');
    }
  }

  Future<void> _uploadImageAndCreateVoucher() async {
    if (_selectedImage == null) {
      _showErrorSnackBar('Please select an image');
      return;
    }

    if (_offerPercentageController.text.isEmpty) {
      _showErrorSnackBar('Please enter offer percentage');
      return;
    }

    if (_selectedDate == null) {
      _showErrorSnackBar('Please select a valid until date');
      return;
    }

    try {
      // Upload image first
      await ref.read(voucherImageUploadProvider.notifier).uploadVoucherImage(_selectedImage!);
      
      final imageState = ref.read(voucherImageUploadProvider);
      if (imageState.imageUrl == null) {
        _showErrorSnackBar('Failed to upload image');
        return;
      }

      // Create voucher
      final voucher = Voucher(
        category: _selectedCategory,
        imageUrl: imageState.imageUrl!,
        offerPercentage: double.parse(_offerPercentageController.text.trim()),
        validUntil: _selectedDate!,
        createdAt: DateTime.now(),
      );

      await ref.read(voucherProvider.notifier).addVoucher(voucher);
      
      _clearForm();
      _showSuccessSnackBar('Voucher created successfully!');
      
    } catch (e) {
      _showErrorSnackBar('Error creating voucher: $e');
    }
  }

  void _clearForm() {
    setState(() {
      _selectedImage = null;
      _selectedCategory = 'Coffee';
      _offerPercentageController.clear();
      _validUntilController.clear();
      _selectedDate = null;
    });
    ref.read(voucherImageUploadProvider.notifier).clearImage();
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _validUntilController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final voucherState = ref.watch(voucherProvider);
    final imageState = ref.watch(voucherImageUploadProvider);
    final categories = ref.watch(voucherCategoriesProvider);
    
    // Debug output
    ref.read(voucherDebugProvider);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: AppBar(
          title:Text('Voucher Management'),
          backgroundColor: const Color(0xFF6D4C41),
          foregroundColor: Colors.white,
          bottom:TabBar(
            tabs: [
              Tab(icon: Icon(Icons.list), text: 'View Vouchers'),
              Tab(icon: Icon(Icons.add), text: 'Add Voucher'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Tab 1: View Vouchers
            _buildVouchersList(voucherState),
            
            // Tab 2: Add Voucher
            _buildAddVoucherForm(categories, imageState),
          ],
        ),
      ),
    );
  }

  Widget _buildVouchersList(VoucherState voucherState) {
    if (voucherState.isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Color(0xFF6D4C41)),
            SizedBox(height: 16),
            Text('Loading vouchers...'),
          ],
        ),
      );
    }

    if (voucherState.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text('Error: ${voucherState.error}'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => ref.read(voucherProvider.notifier).fetchAllVouchers(),
              child: const Text('Try Again'),
            ),
          ],
        ),
      );
    }

    if (voucherState.vouchers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.confirmation_number, size: 80, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'No vouchers found',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            const Text('Create your first voucher in the Add tab'),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: voucherState.vouchers.length,
      itemBuilder: (context, index) {
        final voucher = voucherState.vouchers[index];
        return _buildVoucherCard(voucher);
      },
    );
  }

  Widget _buildVoucherCard(Voucher voucher) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Voucher Image
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                image: DecorationImage(
                  image: NetworkImage(voucher.imageUrl),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 16),
            
            // Voucher Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    voucher.category,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${voucher.offerPercentage}% OFF',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Valid until: ${DateFormat('MMM dd, yyyy').format(voucher.validUntil)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: voucher.isExpired ? Colors.red : Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: voucher.isExpired ? Colors.red.withOpacity(0.1) : Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      voucher.isExpired ? 'EXPIRED' : 'ACTIVE',
                      style: TextStyle(
                        fontSize: 10,
                        color: voucher.isExpired ? Colors.red : Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Action Buttons
            PopupMenuButton<String>(
              onSelected: (value) => _handleVoucherAction(value, voucher),
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit, size: 18),
                      SizedBox(width: 8),
                      Text('Edit',
                      style: TextStyle(color: Colors.brown),
                      ),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, size: 18, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Delete', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _handleVoucherAction(String action, Voucher voucher) {
    switch (action) {
      case 'edit':
        _showEditVoucherDialog(voucher);
        break;
      case 'delete':
        _showDeleteVoucherDialog(voucher);
        break;
    }
  }

  void _showDeleteVoucherDialog(Voucher voucher) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Voucher'),
        content: Text('Are you sure you want to delete ${voucher.category} voucher?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(voucherProvider.notifier).deleteVoucher(voucher.id!);
              _showSuccessSnackBar('Voucher deleted successfully');
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  // void _showEditVoucherDialog(Voucher voucher) {
  //     _showEditVoucherDialog(voucher);
  //   _showSuccessSnackBar('Edit functionality for ${voucher.category}');
  // }
 void _showEditVoucherDialog(Voucher voucher) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => _buildEditVoucherBottomSheet(voucher),
  );
}

Widget _buildEditVoucherBottomSheet(Voucher voucher) {
  return Consumer(
    builder: (context, ref, child) {
      return EditVoucherBottomSheet(
        voucher: voucher,
        onVoucherUpdated: () {
          ref.read(voucherProvider.notifier).fetchAllVouchers();
        },
      );
    },
  );
}
  Widget _buildAddVoucherForm(List<String> categories, VoucherImageUploadState imageState) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: SingleChildScrollView(
        child: Column(
          children: [
            // Category Selection
            _buildCategorySelection(categories),
            const SizedBox(height: 20),

            // Offer Percentage
            _buildTextField(
              controller: _offerPercentageController,
              hintText: 'Offer Percentage (e.g., 20)',
              icon: Icons.percent,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),

            // Valid Until Date
            TextField(
              controller: _validUntilController,
              readOnly: true,
              decoration: InputDecoration(
                labelText: 'Valid Until',
                prefixIcon: const Icon(Icons.calendar_today),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.calendar_month),
                  onPressed: () => _selectDate(context),
                ),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onTap: () => _selectDate(context),
            ),
            const SizedBox(height: 20),

            // Image Upload
            _buildImageUploadSection(imageState),
            const SizedBox(height: 20),

            // Create Voucher Button
            imageState.isUploading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _uploadImageAndCreateVoucher,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                      backgroundColor: const Color(0xFF6D4C41),
                    ),
                    child: const Text(
                      'Create Voucher',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategorySelection(List<String> categories) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select Category:',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: categories.map((category) {
            return ChoiceChip(
              label: Text(category),
              selected: _selectedCategory == category,
              selectedColor: const Color(0xFF6D4C41),
              labelStyle: TextStyle(
                color: _selectedCategory == category ? Colors.white : Colors.black,
              ),
              onSelected: (selected) {
                setState(() {
                  _selectedCategory = category;
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildImageUploadSection(VoucherImageUploadState imageState) {
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
                color: _selectedImage != null ? Colors.green : Colors.blue,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(15),
            ),
            child: _selectedImage != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(13),
                    child: Image.file(_selectedImage!, fit: BoxFit.cover),
                  )
                : const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.camera_alt, size: 40, color: Colors.blue),
                      SizedBox(height: 8),
                      Text('Tap to upload image', style: TextStyle(color: Colors.blue)),
                    ],
                  ),
          ),
        ),
        const SizedBox(height: 10),
        if (imageState.isUploading) ...[
          const CircularProgressIndicator(),
          const SizedBox(height: 8),
          const Text('Uploading image...'),
        ] else if (imageState.imageUrl != null) ...[
          const Icon(Icons.check_circle, color: Colors.green),
          const SizedBox(height: 4),
          const Text('Image ready for voucher', style: TextStyle(color: Colors.green)),
        ],
        if (imageState.error != null)
          Text('Error: ${imageState.error}', style: const TextStyle(color: Colors.red)),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
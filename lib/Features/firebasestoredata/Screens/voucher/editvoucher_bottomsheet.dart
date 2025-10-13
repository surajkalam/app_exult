import 'dart:developer';
import 'dart:io';
import 'package:coffee_shop/Features/firebasestoredata/provider/voucher_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';


class EditVoucherBottomSheet extends ConsumerStatefulWidget {
  final Voucher voucher;
  final VoidCallback onVoucherUpdated;

  const EditVoucherBottomSheet({
    super.key,
    required this.voucher,
    required this.onVoucherUpdated,
  });

  @override
  ConsumerState<EditVoucherBottomSheet> createState() => _EditVoucherBottomSheetState();
}

class _EditVoucherBottomSheetState extends ConsumerState<EditVoucherBottomSheet> {
  late TextEditingController _offerPercentageController;
  late TextEditingController _validUntilController;
  DateTime? _selectedDate;
  File? _selectedImage;
  String _selectedCategory = 'Coffee';
  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    _offerPercentageController = TextEditingController(text: widget.voucher.offerPercentage.toStringAsFixed(0));
    _validUntilController = TextEditingController(text: DateFormat('yyyy-MM-dd').format(widget.voucher.validUntil));
    _selectedDate = widget.voucher.validUntil;
    _selectedCategory = widget.voucher.category;
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

  Future<void> _selectDate(BuildContext context) async {
  log('📅 Opening date picker...');
  
  // Get today's date at midnight for accurate comparison
  final DateTime today = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
  final DateTime currentVoucherDate = _selectedDate ?? widget.voucher.validUntil;
  
  log('📆 Today: $today');
  log('📆 Current voucher date: $currentVoucherDate');
  
  // Determine the initial date - use the later of today or current voucher date
  final DateTime initialDate = currentVoucherDate.isAfter(today) ? currentVoucherDate : today;
  
  log('📆 Initial date for picker: $initialDate');

  final DateTime? picked = await showDatePicker(
    context: context,
    initialDate: initialDate,
    firstDate: today, // Always start from today
    lastDate: DateTime(2101),
    builder: (BuildContext context, Widget? child) {
      return Theme(
        data: ThemeData.light().copyWith(
          colorScheme: const ColorScheme.light(
            primary: Color(0xFF6D4C41),
            onPrimary: Colors.white,
            onSurface: Colors.black,
          ),
          dialogTheme: DialogThemeData(backgroundColor: Colors.white),
        ),
        child: child!,
      );
    },
  );

  if (picked != null && mounted) {
    log('✅ Selected new date: $picked');
    setState(() {
      _selectedDate = picked;
      _validUntilController.text = DateFormat('yyyy-MM-dd').format(picked);
    });
    
    // Show status update
    final status = picked.isAfter(DateTime.now()) ? 'ACTIVE' : 'EXPIRED';
    log('🔄 Voucher status: $status');
  } else {
    await Future.delayed(const Duration(milliseconds: 200));
    if (mounted) {
      showModalBottomSheet(
        // ignore: use_build_context_synchronously
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => EditVoucherBottomSheet(
          voucher: widget.voucher,
          onVoucherUpdated: widget.onVoucherUpdated,
        ),
      );
    }
  }
}

  Future<void> _updateVoucher() async {
    if (_offerPercentageController.text.isEmpty) {
      _showErrorSnackBar('Please enter offer percentage');
      return;
    }

    if (_selectedDate == null) {
      _showErrorSnackBar('Please select a valid until date');
      return;
    }

    final offerPercentage = double.tryParse(_offerPercentageController.text.trim());
    if (offerPercentage == null || offerPercentage <= 0 || offerPercentage > 100) {
      _showErrorSnackBar('Please enter a valid offer percentage (1-100)');
      return;
    }

    setState(() {
      _isUpdating = true;
    });

    try {
      String imageUrl = widget.voucher.imageUrl;

      if (_selectedImage != null) {
        await ref.read(voucherImageUploadProvider.notifier).uploadVoucherImage(_selectedImage!);
        final imageState = ref.read(voucherImageUploadProvider);
        if (imageState.imageUrl != null) {
          imageUrl = imageState.imageUrl!;
        }
      }

      final updatedVoucher = widget.voucher.copyWith(
        category: _selectedCategory,
        imageUrl: imageUrl,
        offerPercentage: offerPercentage,
        validUntil: _selectedDate!,
      );

      await ref.read(voucherProvider.notifier).updateVoucher(updatedVoucher);
      
      widget.onVoucherUpdated();
      Navigator.pop(context);
      
      final status = _selectedDate!.isAfter(DateTime.now()) ? 'active' : 'expired';
      _showSuccessSnackBar('Voucher updated successfully! Status: $status');
      
    } catch (e) {
      _showErrorSnackBar('Error updating voucher: $e');
    } finally {
      setState(() {
        _isUpdating = false;
      });
    }
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

  String _getVoucherStatus() {
    if (_selectedDate == null) return 'NO_DATE';
    return _selectedDate!.isAfter(DateTime.now()) ? 'ACTIVE' : 'EXPIRED';
  }

  Color _getStatusColor() {
    final status = _getVoucherStatus();
    switch (status) {
      case 'ACTIVE':
        return Colors.green;
      case 'EXPIRED':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getStatusMessage() {
    final status = _getVoucherStatus();
    switch (status) {
      case 'ACTIVE':
        return 'Active - Customers can use this voucher';
      case 'EXPIRED':
        return 'Expired - Select a future date to activate';
      default:
        return 'Please select a valid date';
    }
  }

  @override
  Widget build(BuildContext context) {
    final categories = ref.watch(voucherCategoriesProvider);
    final imageState = ref.watch(voucherImageUploadProvider);

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Edit Voucher',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF6D4C41),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 20),

            const Text(
              'Current Voucher Image:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                image: DecorationImage(
                  image: NetworkImage(widget.voucher.imageUrl),
                  fit: BoxFit.cover,
                ),
                border: Border.all(color: Colors.grey.shade300),
              ),
            ),
            const SizedBox(height: 20),

            const Text(
              'Update Image (Optional):',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: _pickImageFromGallery,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  border: Border.all(
                    color: _selectedImage != null ? Colors.green : Colors.blue,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: _selectedImage != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.file(_selectedImage!, fit: BoxFit.cover),
                      )
                    : const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.camera_alt, size: 30, color: Colors.blue),
                          SizedBox(height: 8),
                          Text(
                            'New Image',
                            style: TextStyle(fontSize: 12, color: Colors.blue),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 10),
            if (imageState.isUploading) ...[
              const Row(
                children: [
                  CircularProgressIndicator(),
                  SizedBox(width: 8),
                  Text('Uploading new image...', style: TextStyle(fontSize: 12)),
                ],
              ),
            ] else if (imageState.imageUrl != null) ...[
              const Row(
                children: [
                  Icon(Icons.check_circle, size: 16, color: Colors.green),
                  SizedBox(width: 8),
                  Text('New image ready', style: TextStyle(fontSize: 12, color: Colors.green)),
                ],
              ),
            ],
            const SizedBox(height: 20),

            const Text(
              'Category:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 50,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final category = categories[index];
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(category),
                      selected: _selectedCategory == category,
                      selectedColor: const Color(0xFF6D4C41),
                      labelStyle: TextStyle(
                        color: _selectedCategory == category ? Colors.white : Colors.black,
                        fontSize: 12,
                      ),
                      onSelected: (selected) {
                        setState(() {
                          _selectedCategory = category;
                        });
                      },
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),

            const Text(
              'Offer Percentage *',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _offerPercentageController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: 'Enter offer percentage (1-100)',
                prefixIcon: const Icon(Icons.percent, color: Color(0xFF6D4C41)),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF6D4C41), width: 2),
                ),
              ),
            ),
            const SizedBox(height: 20),

            const Text(
              'Valid Until Date *',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () => _selectDate(context),
              child: AbsorbPointer(
                child: TextField(
                  controller: _validUntilController,
                  readOnly: true,
                  decoration: InputDecoration(
                    hintText: 'Tap to select date',
                    prefixIcon: const Icon(Icons.calendar_today, color: Color(0xFF6D4C41)),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.edit, color: Color(0xFF6D4C41)),
                      onPressed: () => _selectDate(context),
                    ),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF6D4C41), width: 2),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            if (_selectedDate != null) ...[
              Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 16,
                    color: _getStatusColor(),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _getStatusMessage(),
                    style: TextStyle(
                      fontSize: 12,
                      color: _getStatusColor(),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 20),

            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _getStatusColor().withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: _getStatusColor()),
              ),
              child: Row(
                children: [
                  Icon(
                    _getVoucherStatus() == 'ACTIVE' ? Icons.check_circle : Icons.warning,
                    color: _getStatusColor(),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _getStatusMessage(),
                      style: TextStyle(
                        color: _getStatusColor(),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            _isUpdating
                ? const Center(child: CircularProgressIndicator(color: Color(0xFF6D4C41)))
                : ElevatedButton(
                    onPressed: _updateVoucher,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                      backgroundColor: const Color(0xFF6D4C41),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Update Voucher',
                      style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
            const SizedBox(height: 10),

            OutlinedButton(
              onPressed: () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                side: const BorderSide(color: Colors.grey),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
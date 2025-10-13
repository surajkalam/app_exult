// give_voucher_screen.dart
import 'package:coffee_exult_app/Features/Profile/data/voucher_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/core.dart';
import '../Provider/voucher_provider.dart';


class GiveVoucherScreen extends ConsumerWidget {
  const GiveVoucherScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final voucherData = ref.watch(voucherCategoriesProvider);
    
    return Scaffold(
      appBar: CustomAppBar(
         titleText: 'Voucher',
         centerTitle: true,
      ),
      body: voucherData.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                'Error loading vouchers',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              Text(
                error.toString(),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => ref.refresh(voucherCategoriesProvider),
                child: const Text('Try Again'),
              ),
            ],
          ),
        ),
        data: (vouchers) {
          if (vouchers.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.receipt_long, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No vouchers available',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            );
          }
          
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Available Vouchers',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Tap on any voucher to share it',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 0.8,
                    ),
                    itemCount: vouchers.length,
                    itemBuilder: (context, index) {
                      final voucher = vouchers[index];
                      return _buildVoucherCard(context, ref, voucher);
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildVoucherCard(BuildContext context, WidgetRef ref, VoucherProduct voucher) {
    // Check validity directly from the model (no need for async call since we have the data)
    final isValid = voucher.isValid;
    
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () => _shareVoucher(context, voucher),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.blue.shade100, Colors.blue.shade50],
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 40,
              width:90,
              child:
               voucher.imageUrl.isNotEmpty
               ? ClipRRect(
                borderRadius: BorderRadius.all(Radius.circular(13)),
                child: Image.network(voucher.imageUrl,fit: BoxFit.cover,))
               : const Icon(Icons.local_offer, color: Colors.white, size: 20)
              ),
               const SizedBox(height: 8),
              // Category
              // Text(
              //   voucher.category,
              //   style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              //   textAlign: TextAlign.center,
              //   maxLines: 2,
              // ),
              // const SizedBox(height: 4),
              
              // Offer Percentage
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${voucher.offerPercentage}% OFF',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              // Validity Status
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isValid ? Colors.green : Colors.red,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  isValid ? 'VALID' : 'EXPIRED',
                  style: const TextStyle(
                    fontSize: 10,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              
              // Valid Until Date
              if (voucher.validUntil != null) ...[
                const SizedBox(height: 4),
                Text(
                  'Until: ${DateFormat('MMM dd, yyyy').format(voucher.validUntil!)}',
                  style: TextStyle(
                    fontSize: 8,
                    color: isValid ? Colors.green : Colors.red,
                  ),
                ),
              ],
              const SizedBox(height: 4),
              // Voucher ID
              Text(
                voucher.voucherId ?? 'No ID',
                style: const TextStyle(
                  fontSize: 10,
                  color: Colors.grey,
                  fontFamily: 'monospace',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _shareVoucher(BuildContext context, VoucherProduct voucher) {
    final validityText = voucher.validUntil != null
        ? 'Valid until: ${DateFormat('MMM dd, yyyy').format(voucher.validUntil!)}'
        : 'No expiry date';
    final shareText = '''
🎉 Special Offer! 🎉

Get ${voucher.offerPercentage}% OFF on ${voucher.category}!

Use voucher code: ${voucher.voucherId}

$validityText

Enjoy your discount! 🎊
''';
    Share.share(
      shareText,
      subject: '${voucher.offerPercentage}% OFF Voucher for ${voucher.category}',
    );
  }
}

// Navigation function
void navigateToGiveVoucherScreen(BuildContext context) {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => const GiveVoucherScreen()),
  );
}
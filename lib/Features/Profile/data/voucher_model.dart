// voucher_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class VoucherProduct {
  final String id;
  final String category;
  final String imageUrl;
  final double offerPercentage;
  final String? voucherId;
  final DateTime? validUntil;

  VoucherProduct({
    required this.id,
    required this.category,
    required this.imageUrl,
    required this.offerPercentage,
    this.voucherId,
    this.validUntil,
  });

  bool get isValid {
    if (validUntil == null) return true;
    return DateTime.now().isBefore(validUntil!);
  }

  factory VoucherProduct.fromMap(Map<String, dynamic> map) {
    DateTime? validUntil;
    
    if (map['validUntil'] != null) {
      if (map['validUntil'] is Timestamp) {
        validUntil = (map['validUntil'] as Timestamp).toDate();
      } else if (map['validUntil'] is DateTime) {
        validUntil = map['validUntil'] as DateTime;
      }
    }

    return VoucherProduct(
      id: map['id']?.toString() ?? '',
      category: map['category']?.toString() ?? '',
      imageUrl: map['imageUrl']?.toString() ?? '',
      offerPercentage: (map['offerPercentage'] ?? 0.0).toDouble(),
      voucherId: map['voucherId']?.toString(),
      validUntil: validUntil,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'category': category,
      'imageUrl': imageUrl,
      'offerPercentage': offerPercentage,
      'voucherId': voucherId,
      'validUntil': validUntil != null ? Timestamp.fromDate(validUntil!) : null,
    };
  }

  String get formattedValidUntil {
    if (validUntil == null) return 'No expiry';
    return DateFormat('MMM dd, yyyy').format(validUntil!);
  }

  // Proper copyWith method
  VoucherProduct copyWith({
    String? id,
    String? category,
    String? imageUrl,
    double? offerPercentage,
    String? voucherId,
    DateTime? validUntil,
  }) {
    return VoucherProduct(
      id: id ?? this.id,
      category: category ?? this.category,
      imageUrl: imageUrl ?? this.imageUrl,
      offerPercentage: offerPercentage ?? this.offerPercentage,
      voucherId: voucherId ?? this.voucherId,
      validUntil: validUntil ?? this.validUntil,
    );
  }
}
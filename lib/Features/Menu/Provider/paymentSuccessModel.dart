
import 'package:cloud_firestore/cloud_firestore.dart';

class PaymentSuccessModel {
  final double amount;
  final DateTime completedAt;
  final String orderId;
  final String paymentId;
  final String productName;
  final int quantity;
  final String? signature;
  final String status;
  final DateTime timestamp;
  

  PaymentSuccessModel({
    required this.amount,
    required this.completedAt,
    required this.orderId,
    required this.paymentId,
    required this.productName,
    required this.quantity,
    this.signature,
    required this.status,
    required this.timestamp,
   
  });

  factory PaymentSuccessModel.fromMap(Map<String, dynamic> map) {
    return PaymentSuccessModel(
      amount: _parseDouble(map['amount']),
      completedAt: _parseTimestamp(map['completedAt']),
      orderId: map['orderId'] as String? ?? 'N/A',
      paymentId: map['paymentId'] as String? ?? 'N/A',
      productName: map['productName'] as String? ?? 'Unknown Product',
      quantity: _parseInt(map['quantity']),
      signature: map['signature'] as String?,
      status: map['status'] as String? ?? 'completed',
      timestamp: _parseTimestamp(map['timestamp']),
    );
  }

  static DateTime _parseTimestamp(dynamic timestamp) {
    if (timestamp == null) return DateTime.now();
    
    if (timestamp is Timestamp) {
      return timestamp.toDate();
    } else if (timestamp is DateTime) {
      return timestamp;
    } else if (timestamp is String) {
      return DateTime.tryParse(timestamp) ?? DateTime.now();
    }
    return DateTime.now();
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  static int _parseInt(dynamic value) {
    if (value == null) return 1;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 1;
    return 1;
  }

  Map<String, dynamic> toMap() {
    return {
      'amount': amount,
      'completedAt': Timestamp.fromDate(completedAt),
      'orderId': orderId,
      'paymentId': paymentId,
      'productName': productName,
      'quantity': quantity,
      'signature': signature,
      'status': status,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }
}
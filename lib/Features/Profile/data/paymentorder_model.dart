class PaymentData {
  final String productName;
  final int quantity;
  final double price;
  final double totalPrice;
  final String status;
  final DateTime completedAt;

  PaymentData({
    required this.productName,
    required this.quantity,
    required this.price,
    required this.totalPrice,
    required this.status,
    required this.completedAt,
  });

  // Convert PaymentData to Map for database storage
  Map<String, dynamic> toMap() {
    return {
      'productName': productName,
      'quantity': quantity,
      'price': price,
      'totalPrice': totalPrice,
      'status': status,
      'completedAt': completedAt.toIso8601String(),
    };
  }

  // Create PaymentData from Map
  factory PaymentData.fromMap(Map<String, dynamic> map) {
    return PaymentData(
      productName: map['productName'] ?? 'Unknown Product',
      quantity: map['quantity'] ?? 1,
      price: map['price']?.toDouble() ?? 0.0,
      totalPrice: map['totalPrice']?.toDouble() ?? 0.0,
      status: map['status'] ?? 'completed',
      completedAt: DateTime.parse(map['completedAt'] ?? DateTime.now().toIso8601String()),
    );
  }
}
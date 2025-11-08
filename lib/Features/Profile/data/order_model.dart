class OrderItem {
  final String name;
  final int quantity;
  final double price;
  final double totalPrice;

  OrderItem({
    required this.name,
    required this.quantity,
    required this.price,
    required this.totalPrice,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'quantity': quantity,
      'price': price,
      'totalPrice': totalPrice,
    };
  }

  factory OrderItem.fromMap(Map<String, dynamic> map) {
    return OrderItem(
      name: map['name'] ?? 'Unknown Item',
      quantity: map['quantity'] ?? 1,
      price: (map['price'] ?? 0.0).toDouble(),
      totalPrice: (map['totalPrice'] ?? 0.0).toDouble(),
    );
  }
}

class OrderData {
  final String orderId;
  final String orderType;
  final String? customerName;
  final int? tableNumber;
  final List<OrderItem> items;
  final double subtotal;
  final double tax;
  final double totalAmount;
  final String status;
  final DateTime orderDate;
  final String? userPhone;
  final String? paymentId;
  final String? adminResponseMessage;
  final String? adminResponseTag;
  final DateTime? adminResponseTimestamp;

  OrderData({
    required this.orderId,
    required this.orderType,
    this.customerName,
    this.tableNumber,
    required this.items,
    required this.subtotal,
    required this.tax,
    required this.totalAmount,
    required this.status,
    required this.orderDate,
    this.userPhone,
    this.paymentId,
    this.adminResponseMessage,
    this.adminResponseTag,
    this.adminResponseTimestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'orderId': orderId,
      'orderType': orderType,
      'customerName': customerName,
      'tableNumber': tableNumber,
      'items': items.map((item) => item.toMap()).toList(),
      'subtotal': subtotal,
      'tax': tax,
      'totalAmount': totalAmount,
      'status': status,
      'orderDate': orderDate.toIso8601String(),
      'userPhone': userPhone,
      'paymentId': paymentId,
      'adminResponseMessage': adminResponseMessage,
      'adminResponseTag': adminResponseTag,
      'adminResponseTimestamp': adminResponseTimestamp?.toIso8601String(),
    };
  }

  factory OrderData.fromMap(Map<String, dynamic> map) {
    return OrderData(
      orderId: map['orderId'] ?? '',
      orderType: map['orderType'] ?? 'Coffee Hub',
      customerName: map['customerName'],
      tableNumber: map['tableNumber'],
      items:
          (map['items'] as List<dynamic>?)
              ?.map((item) => OrderItem.fromMap(item as Map<String, dynamic>))
              .toList() ??
          [],
      subtotal: (map['subtotal'] ?? 0.0).toDouble(),
      tax: (map['tax'] ?? 0.0).toDouble(),
      totalAmount: (map['totalAmount'] ?? 0.0).toDouble(),
      status: map['status'] ?? 'completed',
      orderDate: DateTime.parse(
        map['orderDate'] ?? DateTime.now().toIso8601String(),
      ),
      userPhone: map['userPhone'],
      paymentId: map['paymentId'],
      adminResponseMessage: map['adminResponseMessage'],
      adminResponseTag: map['adminResponseTag'],
      adminResponseTimestamp: map['adminResponseTimestamp'] != null
          ? DateTime.parse(map['adminResponseTimestamp'])
          : null,
    );
  }

  // Helper method to get item names as a string
  String get itemNames => items.map((item) => item.name).join(', ');

  // Helper method to get total quantity
  int get totalQuantity => items.fold(0, (sum, item) => sum + item.quantity);
}

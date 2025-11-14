// models/product_model.dart (or similar)
class ProductData {
  final String id;
  final String name;
  final double price;
  // other fields...

  ProductData({
    required this.id,
    required this.name,
    required this.price,
    // other required fields...
  });
  
  // You might also have a fromMap factory method
  factory ProductData.fromMap(Map<String, dynamic> map) {
    return ProductData(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      price: (map['price'] ?? 0.0).toDouble(),
      // map other fields...
    );
  }

  Map<String, Object> toMap() {
        return {
      'name': name,
      'price': price,
    };
  }
}
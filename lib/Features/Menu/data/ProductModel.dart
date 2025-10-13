// ignore: file_names
class Product {
  final String id;
  final String name;
  final double price;
  final double rating;
  final String? image;
  final String? description;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.rating,
    this.image,
    this.description,
  });

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'] ?? '',
      name: map['name'] ?? 'No Name',
      price: (map['price'] ?? 0).toDouble(),
      rating: (map['rating'] ?? 0).toDouble(),
      image: map['image'],
      description: map['description'],
    );
  }
   Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'rating': rating,
      'image': image,
      'description': description,
    };
  }
}
import 'product_model.dart';

class Wishlist {
  final String id;
  final String user;
  final List<Product> products;
  final DateTime createdAt;
  final DateTime updatedAt;

  Wishlist({
    required this.id,
    required this.user,
    required this.products,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Wishlist.fromJson(Map<String, dynamic> json) {
    if (json.containsKey('message') && json['message'] == 'Wishlist is empty') {
      return Wishlist.empty();
    }
    return Wishlist(
      id: json['_id'],
      user: json['user'],
      products: (json['products'] as List?)
              ?.map((item) => Product.fromJson(item))
              .toList() ??
          [],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  factory Wishlist.empty() {
    return Wishlist(
        products: List.empty(),
        updatedAt: DateTime.now(),
        createdAt: DateTime.now(),
        id: '',
        user: '');
  }

  Wishlist copyWith({
    String? id,
    String? user,
    List<Product>? products,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Wishlist(
      id: id ?? this.id,
      user: user ?? this.user,
      products: products ?? this.products,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

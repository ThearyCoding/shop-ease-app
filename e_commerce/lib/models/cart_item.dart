import 'product_model.dart';

class CartItem {
  final String id;
  final Product product;
  final int quantity;

  CartItem({
    required this.id,
    required this.product,
    required this.quantity,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    final itemId = json['_id'] ?? '';
    final product = Product.fromJson(json['product']);

    return CartItem(
      id: itemId,
      product: product,
      quantity: json['quantity'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'product': product.toJson(),
      'quantity': quantity,
    };
  }
}
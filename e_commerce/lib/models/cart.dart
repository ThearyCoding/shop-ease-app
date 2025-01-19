import 'cart_item.dart';

class Cart {
  final String id;
  final String userId;
  final List<CartItem> items;

  Cart({
    required this.id,
    required this.userId,
    required this.items,
  });
  factory Cart.fromJson(Map<String, dynamic> json) {
    var items =
        (json['items'] as List).map((item) => CartItem.fromJson(item)).toList();
    final cartId = json['_id'] ?? '';
    final userId = json['user'] ?? '';

    return Cart(
      id: cartId,
      userId: userId,
      items: items,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'user': userId,
      'items': items.map((item) => item.toJson()).toList(),
    };
  }
}

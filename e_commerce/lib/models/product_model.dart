class Product {
  final String? id;
  final String? name;
  final String? description;
  final double price;
  final String? brand;
  final double ratings;
  final String? categoryId;
  final List<String> images;

  Product({
    this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.ratings,
    required this.brand,
    required this.categoryId,
    required this.images,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Product && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json["_id"],
      name: json["name"],
      description: json["description"],
      price: (json["price"] as num).toDouble(),
      brand: json["brand"],
      ratings: (json["ratings"] as num).toDouble(),
      categoryId: json["categoryId"],
      images: (json["images"] as List).map((image) => image["url"] as String).toList(), 
    );
  }

   Map<String, dynamic> toJson() {
    return {
      "_id": id,
      "name": name,
      "description": description,
      "price": price,
      "brand": brand,
      "ratings": ratings,
      "categoryId": categoryId,
      "images": images.map((url) => {"url": url}).toList(),
    };
  }
}

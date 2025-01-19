class User {
  final String id;
  final String name;
  final String email;
  final String imageUrl;

  User({required this.id, required this.name, required this.email,required this.imageUrl});

   factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json["_id"] ?? '', 
      name: json["name"] ?? '', 
      email: json["email"] ?? '',
      imageUrl: json["imageUrl"] ?? '',
    );
  }
  factory User.emptyJson() {
    return User(id: '', name: '', email: '',imageUrl: '');
  }
  Map<String, dynamic> toJson(Map<String, dynamic> json) {
    return {'_id': id, 'name': name, 'email': email, 'imageUrl': imageUrl};
  }
}

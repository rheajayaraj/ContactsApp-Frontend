class User {
  final String id;
  final String name;
  final String email;
  final String phoneNumber;
  final String imageId;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phoneNumber': phoneNumber,
      'imageId': imageId,
    };
  }

  User(
      {required this.id,
      required this.name,
      required this.email,
      required this.phoneNumber,
      required this.imageId});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phoneNumber: json['contact'] ?? '',
      imageId: json['image'] ?? '',
    );
  }
}

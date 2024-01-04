class Contact {
  final String id;
  final String name;
  final String phoneNumber;
  final String? email;
  final String? imagePath;
  final List<String>? tags;

  Contact({
    required this.id,
    required this.name,
    required this.phoneNumber,
    required this.email,
    this.imagePath,
    this.tags,
  });

  factory Contact.fromJson(Map<String, dynamic> json) {
    return Contact(
      id: json['_id'],
      name: json['name'],
      phoneNumber: json['contact'],
      email: json['email'],
      imagePath: json['image'],
      tags: json['tags'] != null ? List<String>.from(json['tags']) : null,
    );
  }
}

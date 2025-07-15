// lib/models/user_model.dart
class User {
  final String id;
  final String name;
  final String email;

  User({required this.id, required this.name, required this.email});

  factory User.fromJson(Map<String, dynamic> json) {
    if (json['id'] == null) throw ArgumentError('Missing user ID');
    return User(id: json['id'].toString(), name: json['name']?.toString() ?? 'Guest', email: json['email']?.toString() ?? '');
  }
}
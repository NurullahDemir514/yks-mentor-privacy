import 'package:mongo_dart/mongo_dart.dart';

class User {
  final ObjectId id;
  final String email;
  final String name;
  final DateTime createdAt;
  String? profileImageUrl;
  String? phoneNumber;
  final String? profilePhoto;
  final String displayName;

  User({
    required this.id,
    required this.email,
    required this.name,
    required this.createdAt,
    this.profileImageUrl,
    this.phoneNumber,
    this.profilePhoto,
    required this.displayName,
  });

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['_id'] as ObjectId,
      email: map['email'] as String,
      name: map['name'] as String,
      createdAt: DateTime.parse(map['createdAt'].toString()),
      profileImageUrl: map['profileImageUrl'] as String?,
      phoneNumber: map['phoneNumber'] as String?,
      profilePhoto: map['profilePhoto'] as String?,
      displayName: map['name'] ?? 'Kullanıcı',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      '_id': id,
      'email': email,
      'name': name,
      'createdAt': createdAt.toIso8601String(),
      'profileImageUrl': profileImageUrl,
      'phoneNumber': phoneNumber,
      'profilePhoto': profilePhoto,
    };
  }

  User copyWith({
    ObjectId? id,
    String? email,
    String? name,
    DateTime? createdAt,
    String? profileImageUrl,
    String? phoneNumber,
    String? profilePhoto,
    String? displayName,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      profilePhoto: profilePhoto ?? this.profilePhoto,
      displayName: displayName ?? this.displayName,
    );
  }
}

import 'package:equatable/equatable.dart';

enum Role { admin, user }

class UserModel extends Equatable {
  final String id;
  final String email;
  final String name;
  final Role role;
  final bool isActive;
  final String? createdAt;

  const UserModel({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    this.isActive = true,
    this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String? ?? '',
      email: json['email'] as String? ?? '',
      name: json['name'] as String? ?? '',
      role: json['role'] == 'admin' ? Role.admin : Role.user,
      isActive: _parseIsActive(json),
      createdAt: json['createdAt'] as String?,
    );
  }

  static bool _parseIsActive(Map<String, dynamic> json) {
    if (json.containsKey('isActive')) return json['isActive'] == true;
    if (json.containsKey('is_active')) return json['is_active'] == true;
    if (json.containsKey('active')) return json['active'] == true;
    if (json.containsKey('status')) return json['status'] == 'active';
    return true; // default fallback
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'role': role == Role.admin ? 'admin' : 'user',
      'isActive': isActive,
      if (createdAt != null) 'createdAt': createdAt,
    };
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? name,
    Role? role,
    bool? isActive,
    String? createdAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      role: role ?? this.role,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [id, email, name, role, isActive, createdAt];
}

enum Role { admin, user }

class UserModel {
  final String id;
  final String email;
  final String name;
  final Role role;
  final bool isActive;

  const UserModel({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    this.isActive = true,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String,
      role: json['role'] == 'admin' ? Role.admin : Role.user,
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'role': role == Role.admin ? 'admin' : 'user',
      'isActive': isActive,
    };
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? name,
    Role? role,
    bool? isActive,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      role: role ?? this.role,
      isActive: isActive ?? this.isActive,
    );
  }
}

class User {
  final String id;
  final String email;
  final String nome;
  final String? telefone;
  final String role;
  final bool isActive;
  final DateTime? createdAt;

  User({
    required this.id,
    required this.email,
    required this.nome,
    this.telefone,
    required this.role,
    required this.isActive,
    this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      email: json['email'] as String,
      nome: json['nome'] as String,
      telefone: json['telefone'] as String?,
      role: json['role'] as String,
      isActive: json['isActive'] as bool? ?? true,
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'nome': nome,
      'telefone': telefone,
      'role': role,
      'isActive': isActive,
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
    };
  }
}

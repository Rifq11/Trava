class RegisterRequest {
  final String fullName;
  final String email;
  final String password;
  final int? roleId;

  RegisterRequest({
    required this.fullName,
    required this.email,
    required this.password,
    this.roleId,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'full_name': fullName,
      'email': email,
      'password': password,
    };
    if (roleId != null) {
      map['role_id'] = roleId;
    }
    return map;
  }
}

class LoginRequest {
  final String email;
  final String password;

  LoginRequest({
    required this.email,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
    };
  }
}

class AuthResponse {
  final int userId;
  final String email;
  final String fullName;
  final int roleId;
  final String token;

  AuthResponse({
    required this.userId,
    required this.email,
    required this.fullName,
    required this.roleId,
    required this.token,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      userId: json['user_id'] ?? json['id'] ?? 0,
      email: json['email'] ?? '',
      fullName: json['full_name'] ?? '',
      roleId: json['role_id'] ?? 2,
      token: json['token'] ?? '',
    );
  }
}


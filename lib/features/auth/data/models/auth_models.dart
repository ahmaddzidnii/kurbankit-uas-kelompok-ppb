class LoginRequest {
  final String email;
  final String password;

  LoginRequest({required this.email, required this.password});

  Map<String, dynamic> toJson() {
    return {'email': email.trim(), 'password': password.trim()};
  }
}

class RegisterRequest {
  final String name;
  final String email;
  final String password;

  RegisterRequest({
    required this.name,
    required this.email,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name.trim(),
      'email': email.trim(),
      'password': password.trim(),
    };
  }
}

class LoginResponse {
  final String accessToken;

  LoginResponse({required this.accessToken});

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(accessToken: json['accessToken'] ?? '');
  }

  Map<String, dynamic> toJson() {
    return {'accessToken': accessToken};
  }
}

class RegisterResponse {
  final String? message;

  RegisterResponse({this.message});

  factory RegisterResponse.fromJson(Map<String, dynamic> json) {
    return RegisterResponse(message: json['message']);
  }

  Map<String, dynamic> toJson() {
    return {if (message != null) 'message': message};
  }
}

class UserData {
  final String id;
  final String name;
  final String email;
  final String? role;

  UserData({
    required this.id,
    required this.name,
    required this.email,
    this.role,
  });

  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      role: json['role'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      if (role != null) 'role': role,
    };
  }
}

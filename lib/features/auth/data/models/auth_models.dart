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
  final ProfileMasjid? masjid;

  UserData({
    required this.id,
    required this.name,
    required this.email,
    this.role,
    this.masjid,
  });

  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      role: json['role'],
      masjid: json['masjid'] is Map<String, dynamic>
          ? ProfileMasjid.fromJson(json['masjid'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      if (role != null) 'role': role,
      if (masjid != null) 'masjid': masjid!.toJson(),
    };
  }
}

class ProfileMasjid {
  final String id;
  final String nama;
  final String status;
  final String? rejectionReason;

  ProfileMasjid({
    required this.id,
    required this.nama,
    required this.status,
    this.rejectionReason,
  });

  factory ProfileMasjid.fromJson(Map<String, dynamic> json) {
    return ProfileMasjid(
      id: json['id'] ?? '',
      nama:
          _readString(json, const [
            'nama',
            'name',
            'mosqueName',
            'namaMasjid',
          ]) ??
          '',
      status: _readString(json, const ['status']) ?? '',
      rejectionReason: _readString(json, const [
        'rejectionReason',
        'reason',
        'alasan',
        'rejection_reason',
        'notes',
        'catatan',
      ]),
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'nama': nama, 'status': status};
  }

  bool get isPending => status.toUpperCase() == 'PENDING';

  bool get isApproved => status.toUpperCase() == 'APPROVED';

  bool get isRejected => status.toUpperCase() == 'REJECTED';

  bool get isSuspended => status.toUpperCase() == 'SUSPENDED';

  static String? _readString(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      final value = json[key];
      if (value is String && value.trim().isNotEmpty) {
        return value.trim();
      }
    }

    return null;
  }
}

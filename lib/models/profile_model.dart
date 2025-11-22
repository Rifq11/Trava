class ProfileResponse {
  final ProfileUser user;
  final ProfileDetail? profile;

  ProfileResponse({
    required this.user,
    this.profile,
  });

  factory ProfileResponse.fromJson(Map<String, dynamic> json) {
    return ProfileResponse(
      user: ProfileUser.fromJson(json['user']),
      profile: json['profile'] != null
          ? ProfileDetail.fromJson(json['profile'])
          : null,
    );
  }
}

class ProfileUser {
  final int id;
  final String fullName;
  final String email;
  final int roleId;

  ProfileUser({
    required this.id,
    required this.fullName,
    required this.email,
    required this.roleId,
  });

  factory ProfileUser.fromJson(Map<String, dynamic> json) {
    return ProfileUser(
      id: json['id'] ?? 0,
      fullName: json['full_name'] ?? '',
      email: json['email'] ?? '',
      roleId: json['role_id'] ?? 2,
    );
  }
}

class ProfileDetail {
  final int id;
  final int userId;
  final String phone;
  final String address;
  final String birthDate;
  final String userPhoto;
  final bool isCompleted;

  ProfileDetail({
    required this.id,
    required this.userId,
    required this.phone,
    required this.address,
    required this.birthDate,
    required this.userPhoto,
    required this.isCompleted,
  });

  factory ProfileDetail.fromJson(Map<String, dynamic> json) {
    return ProfileDetail(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      phone: json['phone'] ?? '',
      address: json['address'] ?? '',
      birthDate: json['birth_date'] ?? '',
      userPhoto: json['user_photo'] ?? '',
      isCompleted: json['is_completed'] ?? false,
    );
  }
}

class CompleteProfileRequest {
  final String? phone;
  final String? address;
  final String? birthDate;
  final String? userPhoto;

  CompleteProfileRequest({
    this.phone,
    this.address,
    this.birthDate,
    this.userPhoto,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (phone != null) map['phone'] = phone;
    if (address != null) map['address'] = address;
    if (birthDate != null) map['birth_date'] = birthDate;
    if (userPhoto != null) map['user_photo'] = userPhoto;
    return map;
  }
}

class UpdateProfileRequest {
  final String? fullName;
  final String? email;
  final String? phone;
  final String? address;
  final String? birthDate;
  final String? password;
  final String? userPhoto;

  UpdateProfileRequest({
    this.fullName,
    this.email,
    this.phone,
    this.address,
    this.birthDate,
    this.password,
    this.userPhoto,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (fullName != null) map['full_name'] = fullName;
    if (email != null) map['email'] = email;
    if (phone != null) map['phone'] = phone;
    if (address != null) map['address'] = address;
    if (birthDate != null) map['birth_date'] = birthDate;
    if (password != null) map['password'] = password;
    if (userPhoto != null) map['user_photo'] = userPhoto;
    return map;
  }
}


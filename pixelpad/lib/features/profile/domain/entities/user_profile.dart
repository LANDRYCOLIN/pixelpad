import 'dart:convert';

class UserProfile {
  final int id;
  final String userUuid;
  final String phone;
  final String username;
  final String password;
  final String email;
  final DateTime birthday;
  final String mbti;
  final UserAvatarMode avatarMode;

  const UserProfile({
    required this.id,
    required this.userUuid,
    required this.phone,
    required this.username,
    required this.password,
    required this.email,
    required this.birthday,
    required this.mbti,
    required this.avatarMode,
  });

  factory UserProfile.initial() {
    return UserProfile(
      id: 1,
      userUuid: '',
      phone: '13800000000',
      username: 'PixelPad',
      password: '123456',
      email: 'pixelpad@example.com',
      birthday: DateTime(2006, 11, 15),
      mbti: 'INFP',
      avatarMode: UserAvatarMode.logo,
    );
  }

  UserProfile copyWith({
    int? id,
    String? userUuid,
    String? phone,
    String? username,
    String? password,
    String? email,
    DateTime? birthday,
    String? mbti,
    UserAvatarMode? avatarMode,
  }) {
    return UserProfile(
      id: id ?? this.id,
      userUuid: userUuid ?? this.userUuid,
      phone: phone ?? this.phone,
      username: username ?? this.username,
      password: password ?? this.password,
      email: email ?? this.email,
      birthday: birthday ?? this.birthday,
      mbti: mbti ?? this.mbti,
      avatarMode: avatarMode ?? this.avatarMode,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_uuid': userUuid,
      'phone': phone,
      'username': username,
      'password': password,
      'email': email,
      'birthday': _formatDate(birthday),
      'mbti': mbti,
      'avatarMode': avatarMode.name,
    };
  }

  static UserProfile fromJson(String raw) {
    final Map<String, dynamic> data = jsonDecode(raw) as Map<String, dynamic>;
    return fromMap(data);
  }

  static UserProfile fromMap(Map<String, dynamic> data) {
    final dynamic avatarModeValue = data['avatarMode'] ?? data['avatar_mode'];
    return UserProfile(
      id: (data['id'] as num?)?.toInt() ?? 1,
      userUuid: data['user_uuid'] as String? ?? '',
      phone: data['phone'] as String? ?? '13800000000',
      username: data['username'] as String? ?? 'PixelPad',
      password: data['password'] as String? ?? '',
      email: data['email'] as String? ?? 'pixelpad@example.com',
      birthday:
          _parseDate(data['birthday'] as String?) ?? DateTime(2006, 11, 15),
      mbti: data['mbti'] as String? ?? 'INFP',
      avatarMode: UserAvatarMode.values.firstWhere(
        (mode) => mode.name == avatarModeValue,
        orElse: () => UserAvatarMode.logo,
      ),
    );
  }

  static String _formatDate(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  static DateTime? _parseDate(String? raw) {
    if (raw == null || raw.isEmpty) {
      return null;
    }
    final parts = raw.split('-');
    if (parts.length != 3) {
      return null;
    }
    final year = int.tryParse(parts[0]);
    final month = int.tryParse(parts[1]);
    final day = int.tryParse(parts[2]);
    if (year == null || month == null || day == null) {
      return null;
    }
    return DateTime(year, month, day);
  }
}

enum UserAvatarMode { logo, initials }

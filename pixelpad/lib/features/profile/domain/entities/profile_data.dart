import 'dart:convert';

class ProfileData {
  final String name;
  final String mbti;
  final String email;
  final DateTime birthday;
  final ProfileAvatarMode avatarMode;

  const ProfileData({
    required this.name,
    required this.mbti,
    required this.email,
    required this.birthday,
    required this.avatarMode,
  });

  factory ProfileData.initial() {
    return ProfileData(
      name: 'PixelPad',
      mbti: 'INFP',
      email: 'pixelpad@example.com',
      birthday: DateTime(2006, 11, 15),
      avatarMode: ProfileAvatarMode.logo,
    );
  }

  ProfileData copyWith({
    String? name,
    String? mbti,
    String? email,
    DateTime? birthday,
    ProfileAvatarMode? avatarMode,
  }) {
    return ProfileData(
      name: name ?? this.name,
      mbti: mbti ?? this.mbti,
      email: email ?? this.email,
      birthday: birthday ?? this.birthday,
      avatarMode: avatarMode ?? this.avatarMode,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'mbti': mbti,
      'email': email,
      'birthday': _formatDate(birthday),
      'avatarMode': avatarMode.name,
    };
  }

  static ProfileData fromJson(String raw) {
    final Map<String, dynamic> data = jsonDecode(raw) as Map<String, dynamic>;
    return ProfileData(
      name: data['name'] as String? ?? 'PixelPad',
      mbti: data['mbti'] as String? ?? 'INFP',
      email: data['email'] as String? ?? 'pixelpad@example.com',
      birthday: _parseDate(data['birthday'] as String?) ?? DateTime(2006, 11, 15),
      avatarMode: ProfileAvatarMode.values.firstWhere(
        (mode) => mode.name == data['avatarMode'],
        orElse: () => ProfileAvatarMode.logo,
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

enum ProfileAvatarMode {
  logo,
  initials,
}

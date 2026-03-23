/// User roles for the TourEnvi application
enum UserRole {
  endUser,
  admin,
  supportTeam,
  localGuide,
}

/// Extension to convert UserRole to/from Firestore string
extension UserRoleExtension on UserRole {
  String get value {
    switch (this) {
      case UserRole.endUser:
        return 'end_user';
      case UserRole.admin:
        return 'admin';
      case UserRole.supportTeam:
        return 'support_team';
      case UserRole.localGuide:
        return 'local_guide';
    }
  }

  static UserRole fromString(String role) {
    switch (role) {
      case 'admin':
        return UserRole.admin;
      case 'support_team':
        return UserRole.supportTeam;
      case 'local_guide':
        return UserRole.localGuide;
      default:
        return UserRole.endUser;
    }
  }
}

/// User model representing the Firestore users collection
class UserModel {
  final String uid;
  final String name;
  final String email;
  final UserRole role;
  final String? avatarUrl;
  final String? phone;
  final DateTime createdAt;
  final DateTime lastLogin;
  final List<String> savedTrips;
  final List<String> favourites;
  final List<Map<String, dynamic>> vehicles;
  final Map<String, dynamic>? preferences;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    this.role = UserRole.endUser,
    this.avatarUrl,
    this.phone,
    required this.createdAt,
    required this.lastLogin,
    this.savedTrips = const [],
    this.favourites = const [],
    this.vehicles = const [],
    this.preferences,
  });

  /// Create from Firestore document
  factory UserModel.fromMap(Map<String, dynamic> map, String uid) {
    return UserModel(
      uid: uid,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      role: UserRoleExtension.fromString(map['role'] ?? 'end_user'),
      avatarUrl: map['avatarUrl'],
      phone: map['phone'],
      createdAt: map['createdAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['createdAt'])
          : DateTime.now(),
      lastLogin: map['lastLogin'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['lastLogin'])
          : DateTime.now(),
      savedTrips: List<String>.from(map['savedTrips'] ?? []),
      favourites: List<String>.from(map['favourites'] ?? []),
      vehicles: List<Map<String, dynamic>>.from(map['vehicles'] ?? []),
      preferences: map['preferences'],
    );
  }

  /// Convert to Firestore-compatible map
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'role': role.value,
      'avatarUrl': avatarUrl,
      'phone': phone,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'lastLogin': lastLogin.millisecondsSinceEpoch,
      'savedTrips': savedTrips,
      'favourites': favourites,
      'vehicles': vehicles,
      'preferences': preferences,
    };
  }

  /// Create a copy with updated fields
  UserModel copyWith({
    String? name,
    String? email,
    UserRole? role,
    String? avatarUrl,
    String? phone,
    DateTime? lastLogin,
    List<String>? savedTrips,
    List<String>? favourites,
    List<Map<String, dynamic>>? vehicles,
    Map<String, dynamic>? preferences,
  }) {
    return UserModel(
      uid: uid,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      phone: phone ?? this.phone,
      createdAt: createdAt,
      lastLogin: lastLogin ?? this.lastLogin,
      savedTrips: savedTrips ?? this.savedTrips,
      favourites: favourites ?? this.favourites,
      vehicles: vehicles ?? this.vehicles,
      preferences: preferences ?? this.preferences,
    );
  }
}

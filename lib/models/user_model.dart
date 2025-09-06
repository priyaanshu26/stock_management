class UserModel {
  final String uid;
  final String email;
  final String role; // 'admin' or 'user'
  final DateTime createdAt;

  UserModel({
    required this.uid,
    required this.email,
    required this.role,
    required this.createdAt,
  });

  // Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'role': role,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  // Create from Firestore Map
  factory UserModel.fromMap(Map<String, dynamic> map) {
    DateTime createdAt;
    try {
      if (map['createdAt'] is String) {
        createdAt = DateTime.parse(map['createdAt']);
      } else {
        createdAt = DateTime.now();
      }
    } catch (e) {
      createdAt = DateTime.now();
    }

    return UserModel(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      role: map['role'] ?? 'user',
      createdAt: createdAt,
    );
  }

  bool get isAdmin => role == 'admin';
}
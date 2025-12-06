class ElderUser {
  final String uid;
  final String email;
  final String name;
  final String? phone;
  final DateTime createdAt;

  ElderUser({
    required this.uid,
    required this.email,
    required this.name,
    this.phone,
    required this.createdAt,
  });

  // Convert to JSON for Firestore
  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'phone': phone,
      'createdAt': createdAt.toIso8601String(),
      'userType': 'elder',
    };
  }

  // Create from Firestore document
  factory ElderUser.fromJson(Map<String, dynamic> json) {
    return ElderUser(
      uid: json['uid'] as String,
      email: json['email'] as String,
      name: json['name'] as String,
      phone: json['phone'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}

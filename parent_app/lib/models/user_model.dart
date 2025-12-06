class ParentUser {
  final String uid;
  final String? email;
  final String? name;
  final String elderId; // ID của người con được chăm sóc
  final DateTime createdAt;

  ParentUser({
    required this.uid,
    this.email,
    this.name,
    required this.elderId,
    required this.createdAt,
  });

  // Convert to JSON for Firestore
  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'elderId': elderId,
      'createdAt': createdAt.toIso8601String(),
      'userType': 'parent',
    };
  }

  // Create from Firestore document
  factory ParentUser.fromJson(Map<String, dynamic> json) {
    return ParentUser(
      uid: json['uid'] as String,
      email: json['email'] as String?,
      name: json['name'] as String?,
      elderId: json['elderId'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}

class User {
  final String id;
  final String name;
  final String phoneNumber;
  final String email;
  final UserType type; // 'carer' hoặc 'elder'
  final String? parentId; // Nếu là carer, lưu ID của parent
  final String? carerId; // Nếu là elder, lưu ID của carer
  final DateTime createdAt;

  User({
    required this.id,
    required this.name,
    required this.phoneNumber,
    required this.email,
    required this.type,
    this.parentId,
    this.carerId,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'phoneNumber': phoneNumber,
      'email': email,
      'type': type.toString().split('.').last,
      'parentId': parentId,
      'carerId': carerId,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    // Hỗ trợ cả 'id' và '_id' từ API
    final id = json['id']?.toString() ?? json['_id']?.toString() ?? '';
    
    // Xử lý createdAt có thể là String hoặc DateTime
    DateTime createdAt;
    if (json['createdAt'] is String) {
      createdAt = DateTime.parse(json['createdAt']);
    } else if (json['createdAt'] is DateTime) {
      createdAt = json['createdAt'];
    } else {
      createdAt = DateTime.now();
    }
    
    return User(
      id: id,
      name: json['name'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      email: json['email'] ?? '',
      type: UserType.values.firstWhere(
        (e) => e.toString().split('.').last == json['type'],
        orElse: () => UserType.carer,
      ),
      parentId: json['parentId']?.toString(),
      carerId: json['carerId']?.toString(),
      createdAt: createdAt,
    );
  }
}

enum UserType {
  carer, // Người con
  elder, // Người cha mẹ
}


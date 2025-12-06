import 'package:cloud_firestore/cloud_firestore.dart';

class Alert {
  final String id;
  final String elderId;
  final String alertType; // 'sos', 'missed_medicine', 'no_checkin'
  final String message;
  final DateTime createdAt;
  final bool isResolved;
  final String? resolvedBy;
  final DateTime? resolvedAt;

  Alert({
    required this.id,
    required this.elderId,
    required this.alertType,
    required this.message,
    required this.createdAt,
    this.isResolved = false,
    this.resolvedBy,
    this.resolvedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'elderId': elderId,
      'alertType': alertType,
      'message': message,
      'createdAt': createdAt.toIso8601String(),
      'isResolved': isResolved,
      'resolvedBy': resolvedBy,
      'resolvedAt': resolvedAt?.toIso8601String(),
    };
  }

  factory Alert.fromJson(Map<String, dynamic> json) {
    return Alert(
      id: json['id'] as String,
      elderId: json['elderId'] as String,
      alertType: json['alertType'] as String,
      message: json['message'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      isResolved: json['isResolved'] as bool? ?? false,
      resolvedBy: json['resolvedBy'] as String?,
      resolvedAt: json['resolvedAt'] != null
          ? DateTime.parse(json['resolvedAt'] as String)
          : null,
    );
  }

  factory Alert.fromFirestore(DocumentSnapshot doc) {
    return Alert.fromJson(doc.data() as Map<String, dynamic>);
  }
}

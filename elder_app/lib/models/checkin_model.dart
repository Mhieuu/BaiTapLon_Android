import 'package:cloud_firestore/cloud_firestore.dart';

class CheckinLog {
  final String id;
  final String elderId;
  final DateTime checkinTime;
  final bool isLate; // true nếu trễ hơn giờ mong đợi
  final String? notes;

  CheckinLog({
    required this.id,
    required this.elderId,
    required this.checkinTime,
    this.isLate = false,
    this.notes,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'elderId': elderId,
      'checkinTime': checkinTime.toIso8601String(),
      'isLate': isLate,
      'notes': notes,
    };
  }

  factory CheckinLog.fromJson(Map<String, dynamic> json) {
    return CheckinLog(
      id: json['id'] as String,
      elderId: json['elderId'] as String,
      checkinTime: DateTime.parse(json['checkinTime'] as String),
      isLate: json['isLate'] as bool? ?? false,
      notes: json['notes'] as String?,
    );
  }

  factory CheckinLog.fromFirestore(DocumentSnapshot doc) {
    return CheckinLog.fromJson(doc.data() as Map<String, dynamic>);
  }
}

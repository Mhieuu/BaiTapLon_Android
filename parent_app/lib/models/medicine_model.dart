import 'package:cloud_firestore/cloud_firestore.dart';

class MedicineSchedule {
  final String id;
  final String elderId;
  final String medicineName;
  final int quantity; // số viên
  final String scheduledTime; // HH:mm format
  final String medicineType; // e.g., "Tablet", "Liquid", "Capsule"
  final String? notes;
  final bool isActive;
  final DateTime createdAt;

  MedicineSchedule({
    required this.id,
    required this.elderId,
    required this.medicineName,
    required this.quantity,
    required this.scheduledTime,
    required this.medicineType,
    this.notes,
    this.isActive = true,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'elderId': elderId,
      'medicineName': medicineName,
      'quantity': quantity,
      'scheduledTime': scheduledTime,
      'medicineType': medicineType,
      'notes': notes,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory MedicineSchedule.fromJson(Map<String, dynamic> json) {
    return MedicineSchedule(
      id: json['id'] as String,
      elderId: json['elderId'] as String,
      medicineName: json['medicineName'] as String,
      quantity: json['quantity'] as int,
      scheduledTime: json['scheduledTime'] as String,
      medicineType: json['medicineType'] as String,
      notes: json['notes'] as String?,
      isActive: json['isActive'] as bool? ?? true,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  factory MedicineSchedule.fromFirestore(DocumentSnapshot doc) {
    return MedicineSchedule.fromJson(doc.data() as Map<String, dynamic>);
  }
}

class MedicineLog {
  final String id;
  final String elderId;
  final String scheduleId;
  final String medicineName;
  final int quantity;
  final DateTime takenAt;
  final String? takenBy; // người ghi (parent)
  final bool isCompleted;

  MedicineLog({
    required this.id,
    required this.elderId,
    required this.scheduleId,
    required this.medicineName,
    required this.quantity,
    required this.takenAt,
    this.takenBy,
    this.isCompleted = true,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'elderId': elderId,
      'scheduleId': scheduleId,
      'medicineName': medicineName,
      'quantity': quantity,
      'takenAt': takenAt.toIso8601String(),
      'takenBy': takenBy,
      'isCompleted': isCompleted,
    };
  }

  factory MedicineLog.fromJson(Map<String, dynamic> json) {
    return MedicineLog(
      id: json['id'] as String,
      elderId: json['elderId'] as String,
      scheduleId: json['scheduleId'] as String,
      medicineName: json['medicineName'] as String,
      quantity: json['quantity'] as int,
      takenAt: DateTime.parse(json['takenAt'] as String),
      takenBy: json['takenBy'] as String?,
      isCompleted: json['isCompleted'] as bool? ?? true,
    );
  }

  factory MedicineLog.fromFirestore(DocumentSnapshot doc) {
    return MedicineLog.fromJson(doc.data() as Map<String, dynamic>);
  }
}

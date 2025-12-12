class CheckIn {
  final String id;
  final String medicationScheduleId;
  final String elderId;
  final DateTime checkInTime;
  final bool isOnTime; // Có check-in đúng giờ không (trong vòng 30 phút)
  final String? notes;

  CheckIn({
    required this.id,
    required this.medicationScheduleId,
    required this.elderId,
    required this.checkInTime,
    required this.isOnTime,
    this.notes,
  });

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'medicationScheduleId': medicationScheduleId,
      'elderId': elderId,
      'checkInTime': checkInTime.toIso8601String(),
      'isOnTime': isOnTime,
      'notes': notes,
    };
  }

  factory CheckIn.fromJson(Map<String, dynamic> json) {
    final id = json['id']?.toString() ?? json['_id']?.toString() ?? '';
    
    DateTime checkInTime;
    if (json['checkInTime'] is String) {
      checkInTime = DateTime.parse(json['checkInTime']);
    } else {
      checkInTime = json['checkInTime'] as DateTime;
    }
    
    return CheckIn(
      id: id,
      medicationScheduleId: json['medicationScheduleId'] ?? '',
      elderId: json['elderId'] ?? '',
      checkInTime: checkInTime,
      isOnTime: json['isOnTime'] ?? false,
      notes: json['notes']?.toString(),
    );
  }
}


class MedicationSchedule {
  final String id;
  final String carerId;
  final String elderId;
  final String medicationName;
  final String dosage; // Ví dụ: "1 viên", "2 viên"
  final MedicationTime time; // Giờ uống thuốc
  final List<int> daysOfWeek; // 0=Chủ nhật, 1=Thứ 2, ..., 6=Thứ 7
  final List<String>? specificDates; // Danh sách ngày cụ thể (format: "yyyy-MM-dd")
  final bool isActive;
  final DateTime createdAt;

  MedicationSchedule({
    required this.id,
    required this.carerId,
    required this.elderId,
    required this.medicationName,
    required this.dosage,
    required this.time,
    required this.daysOfWeek,
    this.specificDates,
    this.isActive = true,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'carerId': carerId,
      'elderId': elderId,
      'medicationName': medicationName,
      'dosage': dosage,
      'time': {
        'hour': time.hour,
        'minute': time.minute,
      },
      'daysOfWeek': daysOfWeek,
      'specificDates': specificDates ?? [],
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory MedicationSchedule.fromJson(Map<String, dynamic> json) {
    final timeJson = json['time'] as Map<String, dynamic>? ?? {};
    final id = json['id']?.toString() ?? json['_id']?.toString() ?? '';
    
    DateTime createdAt;
    if (json['createdAt'] is String) {
      createdAt = DateTime.parse(json['createdAt']);
    } else if (json['createdAt'] is DateTime) {
      createdAt = json['createdAt'];
    } else {
      createdAt = DateTime.now();
    }
    
    final specificDatesJson = json['specificDates'];
    List<String>? specificDates;
    if (specificDatesJson != null) {
      if (specificDatesJson is List) {
        specificDates = specificDatesJson.map((e) => e.toString()).toList();
      }
    }

    return MedicationSchedule(
      id: id,
      carerId: json['carerId'] ?? '',
      elderId: json['elderId'] ?? '',
      medicationName: json['medicationName'] ?? '',
      dosage: json['dosage'] ?? '',
      time: MedicationTime(
        hour: timeJson['hour'] ?? 8,
        minute: timeJson['minute'] ?? 0,
      ),
      daysOfWeek: List<int>.from(json['daysOfWeek'] ?? []),
      specificDates: specificDates,
      isActive: json['isActive'] ?? true,
      createdAt: createdAt,
    );
  }

  // Kiểm tra xem hôm nay có phải ngày uống thuốc không
  bool isToday() {
    final now = DateTime.now();
    final todayStr = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    final todayWeekday = now.weekday % 7; // 0=Chủ nhật, 1=Thứ 2, ...
    
    print('🔍 [SCHEDULE] isToday() cho ${medicationName}:');
    print('  - Hôm nay: $todayStr, weekday: $todayWeekday');
    print('  - specificDates: $specificDates');
    print('  - daysOfWeek: $daysOfWeek');
    
    // Kiểm tra ngày cụ thể trước
    if (specificDates != null && specificDates!.isNotEmpty) {
      final found = specificDates!.contains(todayStr);
      print('  - Match specificDates: $found');
      if (found) {
        return true;
      }
    }
    
    // Kiểm tra ngày trong tuần
    final foundWeekday = daysOfWeek.contains(todayWeekday);
    print('  - Match daysOfWeek: $foundWeekday');
    return foundWeekday;
  }

  // Kiểm tra xem đã đến giờ uống thuốc chưa (với buffer 30 phút)
  bool isTimeToTake() {
    if (!isToday() || !isActive) return false;
    final now = DateTime.now();
    final scheduledTime = DateTime(
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );
    final difference = now.difference(scheduledTime).inMinutes;
    return difference >= 0 && difference <= 30; // Trong vòng 30 phút sau giờ uống
  }
}

class MedicationTime {
  final int hour;
  final int minute;

  MedicationTime({required this.hour, required this.minute});

  String toString() {
    return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
  }
}


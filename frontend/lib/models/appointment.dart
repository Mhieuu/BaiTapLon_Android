class Appointment {
  final String id;
  final String carerId;
  final String elderId;
  final String title;
  final String description;
  final DateTime dateTime;
  final String location;
  final bool isCompleted;
  final DateTime createdAt;

  Appointment({
    required this.id,
    required this.carerId,
    required this.elderId,
    required this.title,
    required this.description,
    required this.dateTime,
    required this.location,
    this.isCompleted = false,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'carerId': carerId,
      'elderId': elderId,
      'title': title,
      'description': description,
      'dateTime': dateTime.toIso8601String(),
      'location': location,
      'isCompleted': isCompleted,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Appointment.fromJson(Map<String, dynamic> json) {
    final id = json['id']?.toString() ?? json['_id']?.toString() ?? '';
    
    DateTime dateTime;
    if (json['dateTime'] is String) {
      dateTime = DateTime.parse(json['dateTime']);
    } else {
      dateTime = json['dateTime'] as DateTime;
    }
    
    DateTime createdAt;
    if (json['createdAt'] is String) {
      createdAt = DateTime.parse(json['createdAt']);
    } else if (json['createdAt'] is DateTime) {
      createdAt = json['createdAt'];
    } else {
      createdAt = DateTime.now();
    }
    
    return Appointment(
      id: id,
      carerId: json['carerId'] ?? '',
      elderId: json['elderId'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      dateTime: dateTime,
      location: json['location'] ?? '',
      isCompleted: json['isCompleted'] ?? false,
      createdAt: createdAt,
    );
  }
}


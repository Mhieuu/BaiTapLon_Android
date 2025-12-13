import '../models/user.dart';
import '../models/medication_schedule.dart';
import '../models/check_in.dart';
import '../models/appointment.dart';

/// Mock Data Service - Cung cấp dữ liệu demo khi không có backend
class MockDataService {
  // Mock Users
  static User getMockCarer() {
    return User(
      id: 'carer_001',
      name: 'Bà Nguyễn Thị Lan',
      phoneNumber: '0123456789',
      email: 'lan.nguyen@example.com',
      type: UserType.carer,
      parentId: 'parent_001',
      createdAt: DateTime.now().subtract(const Duration(days: 90)),
    );
  }

  static User getMockParent() {
    return User(
      id: 'parent_001',
      name: 'Anh Trần Văn Nam',
      phoneNumber: '0987654321',
      email: 'nam.tran@example.com',
      type: UserType.carer, // Parent cũng là carer trong model
      carerId: 'carer_001',
      createdAt: DateTime.now().subtract(const Duration(days: 90)),
    );
  }

  // Mock Medication Schedules
  static List<MedicationSchedule> getMockMedicationSchedules() {
    final now = DateTime.now();
    return [
      MedicationSchedule(
        id: 'med_001',
        carerId: 'carer_001',
        elderId: 'elder_001',
        medicationName: 'Thuốc huyết áp Amlodipine',
        dosage: '1 viên 5mg',
        time: MedicationTime(hour: 8, minute: 0),
        daysOfWeek: [1, 2, 3, 4, 5, 6, 0], // Hàng ngày
        isActive: true,
        createdAt: now.subtract(const Duration(days: 30)),
      ),
      MedicationSchedule(
        id: 'med_002',
        carerId: 'carer_001',
        elderId: 'elder_001',
        medicationName: 'Vitamin D3',
        dosage: '1 viên 1000IU',
        time: MedicationTime(hour: 12, minute: 0),
        daysOfWeek: [1, 2, 3, 4, 5, 6, 0],
        isActive: true,
        createdAt: now.subtract(const Duration(days: 25)),
      ),
      MedicationSchedule(
        id: 'med_003',
        carerId: 'carer_001',
        elderId: 'elder_001',
        medicationName: 'Thuốc tiểu đường Metformin',
        dosage: '1 viên 500mg',
        time: MedicationTime(hour: 19, minute: 0),
        daysOfWeek: [1, 2, 3, 4, 5, 6, 0],
        isActive: true,
        createdAt: now.subtract(const Duration(days: 20)),
      ),
      MedicationSchedule(
        id: 'med_004',
        carerId: 'carer_001',
        elderId: 'elder_001',
        medicationName: 'Omega-3',
        dosage: '2 viên',
        time: MedicationTime(hour: 20, minute: 0),
        daysOfWeek: [1, 2, 3, 4, 5, 6, 0],
        isActive: false,
        createdAt: now.subtract(const Duration(days: 15)),
      ),
    ];
  }

  // Mock Check-ins (7 ngày gần đây)
  static List<CheckIn> getMockCheckIns() {
    final now = DateTime.now();
    final List<CheckIn> checkIns = [];
    
    // Tạo check-in cho 7 ngày gần đây
    for (int i = 0; i < 7; i++) {
      final date = now.subtract(Duration(days: i));
      
      // Check-in sáng
      checkIns.add(CheckIn(
        id: 'checkin_${i}_morning',
        medicationScheduleId: 'med_001',
        elderId: 'elder_001',
        checkInTime: DateTime(date.year, date.month, date.day, 8, 5),
        isOnTime: i % 3 == 0,
        notes: i % 3 == 0 ? 'Đã uống thuốc đầy đủ' : 'Quên uống sáng, đã bổ sung',
      ));
      
      // Check-in tối
      checkIns.add(CheckIn(
        id: 'checkin_${i}_evening',
        medicationScheduleId: 'med_001',
        elderId: 'elder_001',
        checkInTime: DateTime(date.year, date.month, date.day, 19, 10),
        isOnTime: i % 2 == 0,
        notes: i % 2 == 0 ? 'Đã ăn tối và uống thuốc' : 'Uống thuốc muộn do ra ngoài',
      ));
    }
    
    return checkIns;
  }

  // Mock Appointments
  static List<Appointment> getMockAppointments() {
    final now = DateTime.now();
    return [
      Appointment(
        id: 'apt_001',
        carerId: 'carer_001',
        elderId: 'elder_001',
        title: 'Khám tim mạch định kỳ',
        description: 'Kiểm tra huyết áp, điện tâm đồ, siêu âm tim',
        dateTime: now.add(const Duration(days: 3)),
        location: 'Bệnh viện Chợ Rẫy - Phòng khám Tim mạch',
        isCompleted: false,
        createdAt: now.subtract(const Duration(days: 10)),
      ),
      Appointment(
        id: 'apt_002',
        carerId: 'carer_001',
        elderId: 'elder_001',
        title: 'Xét nghiệm đường huyết',
        description: 'Xét nghiệm đường huyết lúc đói và sau ăn',
        dateTime: now.add(const Duration(days: 7)),
        location: 'Phòng khám Đa khoa Quận 1',
        isCompleted: false,
        createdAt: now.subtract(const Duration(days: 5)),
      ),
      Appointment(
        id: 'apt_003',
        carerId: 'carer_001',
        elderId: 'elder_001',
        title: 'Khám mắt',
        description: 'Kiểm tra thị lực và đáy mắt',
        dateTime: now.subtract(const Duration(days: 2)),
        location: 'Bệnh viện Mắt TP.HCM',
        isCompleted: true,
        createdAt: now.subtract(const Duration(days: 15)),
      ),
    ];
  }

  // Mock Photos (danh sách URL ảnh demo)
  static List<String> getMockPhotos() {
    return [
      'https://picsum.photos/400/300?random=1',
      'https://picsum.photos/400/300?random=2',
      'https://picsum.photos/400/300?random=3',
      'https://picsum.photos/400/300?random=4',
      'https://picsum.photos/400/300?random=5',
    ];
  }

  // Mock Notifications
  static List<Map<String, dynamic>> getMockNotifications() {
    final now = DateTime.now();
    return [
      {
        'id': 'notif_001',
        'title': '🔔 Nhắc nhở uống thuốc',
        'message': 'Đã đến giờ uống thuốc huyết áp (8:00 sáng)',
        'time': now.subtract(const Duration(hours: 2)),
        'isRead': false,
      },
      {
        'id': 'notif_002',
        'title': '✅ Check-in thành công',
        'message': 'Bà Lan đã check-in đúng giờ lúc 8:05',
        'time': now.subtract(const Duration(hours: 3)),
        'isRead': true,
      },
      {
        'id': 'notif_003',
        'title': '⏰ Lịch hẹn sắp tới',
        'message': 'Nhắc nhở: Khám tim mạch vào ngày ${now.add(const Duration(days: 3)).day}/${now.add(const Duration(days: 3)).month}',
        'time': now.subtract(const Duration(days: 1)),
        'isRead': true,
      },
    ];
  }

  // Helper: Simulate API delay
  static Future<T> simulateDelay<T>(T data, {int milliseconds = 500}) async {
    await Future.delayed(Duration(milliseconds: milliseconds));
    return data;
  }
}

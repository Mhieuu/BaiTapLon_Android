import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/medicine_model.dart';

class MedicineService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Tạo lịch uống thuốc mới
  Future<bool> createSchedule({
    required String elderId,
    required String medicineName,
    required int quantity,
    required String scheduledTime,
    required String medicineType,
    String? notes,
  }) async {
    try {
      final scheduleId = _firestore.collection('medicine_schedules').doc().id;
      final schedule = MedicineSchedule(
        id: scheduleId,
        elderId: elderId,
        medicineName: medicineName,
        quantity: quantity,
        scheduledTime: scheduledTime,
        medicineType: medicineType,
        notes: notes,
        isActive: true,
        createdAt: DateTime.now(),
      );

      await _firestore
          .collection('medicine_schedules')
          .doc(scheduleId)
          .set(schedule.toJson());

      return true;
    } catch (e) {
      print('Error creating schedule: $e');
      return false;
    }
  }

  // Lấy tất cả lịch uống thuốc của 1 người
  Stream<List<MedicineSchedule>> getSchedulesStream(String elderId) {
    return _firestore
        .collection('medicine_schedules')
        .where('elderId', isEqualTo: elderId)
        .where('isActive', isEqualTo: true)
        .orderBy('scheduledTime')
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => MedicineSchedule.fromFirestore(doc))
              .toList();
        });
  }

  // Lấy lịch uống thuốc hôm nay
  Future<List<MedicineSchedule>> getTodaySchedules(String elderId) async {
    try {
      final snapshot = await _firestore
          .collection('medicine_schedules')
          .where('elderId', isEqualTo: elderId)
          .where('isActive', isEqualTo: true)
          .get();

      return snapshot.docs
          .map((doc) => MedicineSchedule.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('Error getting today schedules: $e');
      return [];
    }
  }

  // Ghi log khi uống thuốc
  Future<bool> logMedicineTaken({
    required String elderId,
    required String scheduleId,
    required String medicineName,
    required int quantity,
  }) async {
    try {
      final logId = _firestore.collection('medicine_logs').doc().id;
      final log = MedicineLog(
        id: logId,
        elderId: elderId,
        scheduleId: scheduleId,
        medicineName: medicineName,
        quantity: quantity,
        takenAt: DateTime.now(),
        isCompleted: true,
      );

      await _firestore.collection('medicine_logs').doc(logId).set(log.toJson());

      // Update elder_status
      await _firestore.collection('elder_status').doc(elderId).set({
        'medicine_status': 'done',
        'last_medicine_time': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      }, SetOptions(merge: true));

      return true;
    } catch (e) {
      print('Error logging medicine: $e');
      return false;
    }
  }

  // Lấy lịch sử uống thuốc
  Stream<List<MedicineLog>> getMedicineLogsStream(
    String elderId, {
    DateTime? fromDate,
  }) {
    var query = _firestore
        .collection('medicine_logs')
        .where('elderId', isEqualTo: elderId);

    if (fromDate != null) {
      query = query.where(
        'takenAt',
        isGreaterThanOrEqualTo: fromDate.toIso8601String(),
      );
    }

    return query.orderBy('takenAt', descending: true).snapshots().map((
      snapshot,
    ) {
      return snapshot.docs
          .map((doc) => MedicineLog.fromFirestore(doc))
          .toList();
    });
  }

  // Xóa lịch uống thuốc
  Future<bool> deleteSchedule(String scheduleId) async {
    try {
      await _firestore
          .collection('medicine_schedules')
          .doc(scheduleId)
          .delete();
      return true;
    } catch (e) {
      print('Error deleting schedule: $e');
      return false;
    }
  }

  // Update lịch uống thuốc
  Future<bool> updateSchedule({
    required String scheduleId,
    String? medicineName,
    int? quantity,
    String? scheduledTime,
    String? medicineType,
    String? notes,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (medicineName != null) data['medicineName'] = medicineName;
      if (quantity != null) data['quantity'] = quantity;
      if (scheduledTime != null) data['scheduledTime'] = scheduledTime;
      if (medicineType != null) data['medicineType'] = medicineType;
      if (notes != null) data['notes'] = notes;

      await _firestore
          .collection('medicine_schedules')
          .doc(scheduleId)
          .update(data);
      return true;
    } catch (e) {
      print('Error updating schedule: $e');
      return false;
    }
  }

  // Lấy status uống thuốc
  Stream<Map<String, dynamic>?> getMedicineStatusStream(String elderId) {
    return _firestore.collection('elder_status').doc(elderId).snapshots().map((
      snapshot,
    ) {
      if (snapshot.exists) {
        return snapshot.data();
      }
      return null;
    });
  }

  // Đánh dấu thuốc đã uống
  Future<bool> markMedicineAsTaken(String scheduleId) async {
    try {
      await _firestore.collection('medicine_schedules').doc(scheduleId).update({
        'status': 'done',
        'completedAt': DateTime.now().toIso8601String(),
      });
      return true;
    } catch (e) {
      print('Error marking medicine as taken: $e');
      return false;
    }
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/medicine_model.dart';

class MedicineService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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

  // Ghi log khi cha mẹ nhấn "Đã uống thuốc"
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

  // Lấy status uống thuốc hôm nay
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
}

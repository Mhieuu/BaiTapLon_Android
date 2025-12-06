import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/checkin_model.dart';

class CheckinService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final int _expectedCheckinHour = 8; // Giờ check-in dự kiến (8h sáng)

  // Ghi log check-in (từ parent_app)
  Future<bool> logCheckin(String elderId) async {
    try {
      final now = DateTime.now();
      final isLate = now.hour > _expectedCheckinHour;

      final checkinId = _firestore.collection('checkin_logs').doc().id;
      final checkin = CheckinLog(
        id: checkinId,
        elderId: elderId,
        checkinTime: now,
        isLate: isLate,
      );

      await _firestore
          .collection('checkin_logs')
          .doc(checkinId)
          .set(checkin.toJson());

      // Update elder_status
      await _firestore.collection('elder_status').doc(elderId).set({
        'checkin_today': true,
        'last_checkin_time': now.toIso8601String(),
        'is_checkin_late': isLate,
        'updated_at': now.toIso8601String(),
      }, SetOptions(merge: true));

      return true;
    } catch (e) {
      print('Error logging checkin: $e');
      return false;
    }
  }

  // Lấy lịch sử check-in
  Stream<List<CheckinLog>> getCheckinLogsStream(String elderId) {
    return _firestore
        .collection('checkin_logs')
        .where('elderId', isEqualTo: elderId)
        .orderBy('checkinTime', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => CheckinLog.fromFirestore(doc))
              .toList();
        });
  }

  // Check nếu check-in hôm nay
  Future<bool> isCheckedInToday(String elderId) async {
    try {
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);
      final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);

      final snapshot = await _firestore
          .collection('checkin_logs')
          .where('elderId', isEqualTo: elderId)
          .where('checkinTime', isGreaterThanOrEqualTo: startOfDay)
          .where('checkinTime', isLessThanOrEqualTo: endOfDay)
          .get();

      return snapshot.docs.isNotEmpty;
    } catch (e) {
      print('Error checking checkin: $e');
      return false;
    }
  }

  // Lấy status check-in hôm nay
  Stream<Map<String, dynamic>?> getCheckinStatusStream(String elderId) {
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

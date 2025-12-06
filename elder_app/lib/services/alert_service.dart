import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/alert_model.dart';

class AlertService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Ghi SOS alert (từ parent_app)
  Future<bool> createSOSAlert(String elderId) async {
    try {
      final alertId = _firestore.collection('alerts').doc().id;
      final alert = Alert(
        id: alertId,
        elderId: elderId,
        alertType: 'sos',
        message: 'Cha mẹ gọi SOS!',
        createdAt: DateTime.now(),
      );

      await _firestore.collection('alerts').doc(alertId).set(alert.toJson());

      // Update elder_status
      await _firestore.collection('elder_status').doc(elderId).set({
        'latest_alert': 'sos',
        'alert_time': DateTime.now().toIso8601String(),
      }, SetOptions(merge: true));

      return true;
    } catch (e) {
      print('Error creating SOS alert: $e');
      return false;
    }
  }

  // Ghi missed medicine alert
  Future<bool> createMissedMedicineAlert(
    String elderId,
    String medicineName,
  ) async {
    try {
      final alertId = _firestore.collection('alerts').doc().id;
      final alert = Alert(
        id: alertId,
        elderId: elderId,
        alertType: 'missed_medicine',
        message: 'Quên uống thuốc: $medicineName',
        createdAt: DateTime.now(),
      );

      await _firestore.collection('alerts').doc(alertId).set(alert.toJson());
      return true;
    } catch (e) {
      print('Error creating missed medicine alert: $e');
      return false;
    }
  }

  // Ghi no checkin alert
  Future<bool> createNoCheckinAlert(String elderId) async {
    try {
      final alertId = _firestore.collection('alerts').doc().id;
      final alert = Alert(
        id: alertId,
        elderId: elderId,
        alertType: 'no_checkin',
        message: 'Chưa check-in hôm nay',
        createdAt: DateTime.now(),
      );

      await _firestore.collection('alerts').doc(alertId).set(alert.toJson());
      return true;
    } catch (e) {
      print('Error creating no checkin alert: $e');
      return false;
    }
  }

  // Lấy danh sách alerts
  Stream<List<Alert>> getAlertsStream(
    String elderId, {
    bool onlyUnresolved = true,
  }) {
    return _firestore
        .collection('alerts')
        .where('elderId', isEqualTo: elderId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          final alerts = snapshot.docs
              .map((doc) => Alert.fromFirestore(doc))
              .toList();
          // Filter client-side to avoid composite index requirement
          if (onlyUnresolved) {
            return alerts.where((alert) => !alert.isResolved).toList();
          }
          return alerts;
        });
  }

  // Resolve alert
  Future<bool> resolveAlert(String alertId) async {
    try {
      await _firestore.collection('alerts').doc(alertId).update({
        'isResolved': true,
        'resolvedAt': DateTime.now().toIso8601String(),
      });
      return true;
    } catch (e) {
      print('Error resolving alert: $e');
      return false;
    }
  }

  // Lấy latest alert
  Stream<Alert?> getLatestAlertStream(String elderId) {
    return _firestore
        .collection('alerts')
        .where('elderId', isEqualTo: elderId)
        .snapshots()
        .map((snapshot) {
          // Filter and sort all client-side to avoid any index requirement
          final alerts = snapshot.docs
              .map((doc) => Alert.fromFirestore(doc))
              .where((alert) => !alert.isResolved)
              .toList();
          alerts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return alerts.isNotEmpty ? alerts.first : null;
        });
  }
}

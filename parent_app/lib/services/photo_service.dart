import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/photo_model.dart';

class PhotoService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Lấy danh sách ảnh của 1 người (cho parent_app slideshow)
  Stream<List<Photo>> getPhotosStream(String elderId) {
    return _firestore
        .collection('photos')
        .where('elderId', isEqualTo: elderId)
        .orderBy('uploadedAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) => Photo.fromFirestore(doc)).toList();
        });
  }
}

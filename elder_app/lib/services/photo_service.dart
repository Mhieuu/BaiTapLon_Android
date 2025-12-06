import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/photo_model.dart';

class PhotoService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Thêm ảnh (từ elder_app)
  Future<bool> addPhoto({
    required String elderId,
    required String imageUrl,
    String? caption,
  }) async {
    try {
      final photoId = _firestore.collection('photos').doc().id;
      final photo = Photo(
        id: photoId,
        elderId: elderId,
        imageUrl: imageUrl,
        caption: caption,
        uploadedAt: DateTime.now(),
      );

      await _firestore.collection('photos').doc(photoId).set(photo.toJson());
      return true;
    } catch (e) {
      print('Error adding photo: $e');
      return false;
    }
  }

  // Lấy danh sách ảnh của 1 người
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

  // Xóa ảnh
  Future<bool> deletePhoto(String photoId) async {
    try {
      await _firestore.collection('photos').doc(photoId).delete();
      return true;
    } catch (e) {
      print('Error deleting photo: $e');
      return false;
    }
  }

  // Update caption ảnh
  Future<bool> updateCaption(String photoId, String caption) async {
    try {
      await _firestore.collection('photos').doc(photoId).update({
        'caption': caption,
      });
      return true;
    } catch (e) {
      print('Error updating caption: $e');
      return false;
    }
  }
}

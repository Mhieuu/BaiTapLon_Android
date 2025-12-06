import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class ParentAuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Stream để monitor auth state
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  // Lấy current user
  User? get currentUser => _firebaseAuth.currentUser;

  // Anonymous Sign In - Parent
  // Parent app sử dụng anonymous login
  Future<ParentUser?> signInAnonymous({required String elderId}) async {
    try {
      final userCredential = await _firebaseAuth.signInAnonymously();

      final parentUser = ParentUser(
        uid: userCredential.user!.uid,
        elderId: elderId,
        createdAt: DateTime.now(),
      );

      // Lưu vào Firestore
      await _firestore
          .collection('parent_users')
          .doc(parentUser.uid)
          .set(parentUser.toJson());

      return parentUser;
    } on FirebaseAuthException catch (e) {
      print('Error signing in anonymously: ${e.message}');
      return null;
    }
  }

  // Sign Out
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  // Get Parent User từ Firestore
  Future<ParentUser?> getParentUser(String uid) async {
    try {
      final doc = await _firestore.collection('parent_users').doc(uid).get();
      if (doc.exists) {
        return ParentUser.fromJson(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      print('Error getting user: $e');
      return null;
    }
  }

  // Verify Elder ID exists
  Future<bool> verifyElderId(String elderId) async {
    try {
      final doc = await _firestore.collection('users').doc(elderId).get();
      return doc.exists;
    } catch (e) {
      print('Error verifying elder: $e');
      return false;
    }
  }
}

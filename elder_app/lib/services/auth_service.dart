import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Stream để monitor auth state
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  // Lấy current user
  User? get currentUser => _firebaseAuth.currentUser;

  // Sign Up - Elder
  Future<ElderUser?> signUpElder({
    required String email,
    required String password,
    required String name,
    String? phone,
  }) async {
    try {
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final elderUser = ElderUser(
        uid: userCredential.user!.uid,
        email: email,
        name: name,
        phone: phone,
        createdAt: DateTime.now(),
      );

      // Lưu vào Firestore
      await _firestore
          .collection('users')
          .doc(elderUser.uid)
          .set(elderUser.toJson());

      return elderUser;
    } on FirebaseAuthException catch (e) {
      print('Error signing up: ${e.message}');
      return null;
    }
  }

  // Sign In - Elder
  Future<ElderUser?> signInElder({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Lấy user từ Firestore
      final doc = await _firestore
          .collection('users')
          .doc(userCredential.user!.uid)
          .get();

      if (doc.exists) {
        return ElderUser.fromJson(doc.data() as Map<String, dynamic>);
      }
      return null;
    } on FirebaseAuthException catch (e) {
      print('Error signing in: ${e.message}');
      return null;
    }
  }

  // Sign Out
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  // Get Elder User từ Firestore
  Future<ElderUser?> getElderUser(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        return ElderUser.fromJson(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      print('Error getting user: $e');
      return null;
    }
  }
}

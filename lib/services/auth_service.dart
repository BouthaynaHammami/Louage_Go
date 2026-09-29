import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  static final _auth = FirebaseAuth.instance;
  static final _db = FirebaseFirestore.instance;

  static Future<void> register({
    required String name,
    required String phone,
    required String email,
    required String password,
    required String role, // 'passenger' or 'driver'
  }) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    await cred.user!.updateDisplayName(name);
    await _db.collection('users').doc(cred.user!.uid).set({
      'name': name,
      'phone': phone,
      'email': email,
      'role': role,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  /// Logs in and returns the user's role.
  static Future<String> login(String email, String password) async {
    await _auth.signInWithEmailAndPassword(email: email, password: password);
    return currentRole();
  }

  static Future<String> currentRole() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return 'passenger';
    final doc = await _db.collection('users').doc(uid).get();
    return (doc.data()?['role'] as String?) ?? 'passenger';
  }

  static Future<void> resetPassword(String email) {
    return _auth.sendPasswordResetEmail(email: email);
  }

  static Future<void> logout() => _auth.signOut();

  static String errorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-credential':
      case 'user-not-found':
      case 'wrong-password':
        return 'Email ou mot de passe incorrect';
      case 'email-already-in-use':
        return 'Cet email est déjà utilisé';
      case 'weak-password':
        return 'Mot de passe trop faible (6 caractères minimum)';
      case 'invalid-email':
        return 'Adresse email invalide';
      case 'network-request-failed':
        return 'Problème de connexion internet';
      case 'too-many-requests':
        return 'Trop de tentatives, réessayez plus tard';
      default:
        return 'Erreur : ${e.code}';
    }
  }
}
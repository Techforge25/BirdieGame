import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

abstract class AuthRepository {
  Future<UserCredential> signIn({
    required String email,
    required String password,
  });

  Future<UserCredential> signUp({
    required String email,
    required String password,
    required String displayName,
  });

  Future<void> upsertUserProfile({
    required String uid,
    required String email,
    required String displayName,
    required String role,
  });

  Future<String?> fetchUserRole(String uid);

  Future<String?> consumeInviteRole(String email);
}

class FirebaseAuthRepository implements AuthRepository {
  FirebaseAuthRepository({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  @override
  Future<UserCredential> signIn({
    required String email,
    required String password,
  }) {
    return _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  @override
  Future<UserCredential> signUp({
    required String email,
    required String password,
    required String displayName,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    await credential.user?.updateDisplayName(displayName);
    return credential;
  }

  @override
  Future<void> upsertUserProfile({
    required String uid,
    required String email,
    required String displayName,
    required String role,
  }) {
    final normalizedRole = role.trim().toLowerCase();
    final isAdminRole =
        normalizedRole == 'club_admin' || normalizedRole == 'super_admin';
 return _firestore.collection('users').doc(uid).set({    
      'email': email,
      'displayName': displayName,
      'role': role,
      if (isAdminRole) 'isActive': true,
      if (isAdminRole) 'status': 'active',
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  @override
  Future<String?> fetchUserRole(String uid) async {
    final snapshot = await _firestore.collection('users').doc(uid).get();
    if (!snapshot.exists) {
      return null;
    }
    final data = snapshot.data();
    return data?['role'] as String?;
  }

  @override
  Future<String?> consumeInviteRole(String email) async {
    final docId = email.trim().toLowerCase();
    final docRef = _firestore.collection('role_invites').doc(docId);
    final snapshot = await docRef.get();
    if (!snapshot.exists) {
      return null;
    }
    final data = snapshot.data();
    final role = data?['role'] as String?;
    await docRef.delete();
    return role;
  }
}

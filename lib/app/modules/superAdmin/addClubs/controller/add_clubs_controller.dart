import 'package:bierdygame/app/modules/superAdmin/super_admin_bottom_nav/controller/super_admin_bot_nav_controller.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AdminModel {
  final String uid;
  final String name;
  final String email;

  AdminModel({required this.uid, required this.name, required this.email});
}

class AddClubsController extends GetxController {
  final int maxAdmins = 5;
  final admins = <AdminModel>[].obs;
  final showAddAdminForm = false.obs;
  final isNewAdmin = true.obs;
  final clubNameController = TextEditingController();
  final clubLocationController = TextEditingController();
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final isPasswordHidden = true.obs;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final RxnString logoName = RxnString();
  final RxnString logoPath = RxnString();
  final RxnString logoBase64 = RxnString();

  @override
  

  @override
  void onClose() {
    clubNameController.dispose();
    clubLocationController.dispose();
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  Future<void> pickLogo() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked == null) {
      return;
    }

    logoName.value = picked.name;
    logoPath.value = picked.path;
    final bytes = await File(picked.path).readAsBytes();
    logoBase64.value = base64Encode(bytes);
  }

  void showAddAdminFormIfAllowed() {
    if (admins.length >= maxAdmins) {
      Get.snackbar("Note", "Only 5 Admins added");
      return;
    }
    showAddAdminForm.value = true;
  }

  void removeAdminAt(int index) {
    admins.removeAt(index);
  }

  void onSaveChanges() {
    if (!showAddAdminForm.value) return;
    if (admins.length >= maxAdmins) {
      Get.snackbar("Note", "Only 5 Admins added");
      return;
    }

    admins.add(
      AdminModel(
        uid: '',
        name: nameController.text.trim(),
        email: emailController.text.trim(),
      ),
    );

    showAddAdminForm.value = false;
    nameController.clear();
    emailController.clear();
    passwordController.clear();
  }

  Future<void> sendAdminInvite() async {
    final name = nameController.text.trim();
    final email = emailController.text.trim().toLowerCase();
    final password = passwordController.text.trim();
    final clubName = clubNameController.text.trim();
    if (name.isEmpty || email.isEmpty) {
      Get.snackbar("Error", "Name and email are required");
      return;
    }
    if (password.length < 6) {
      Get.snackbar("Error", "Password must be at least 6 characters");
      return;
    }

    try {
      final secondaryApp = await _getSecondaryApp();
      final secondaryAuth = FirebaseAuth.instanceFor(app: secondaryApp);
      final credential = await secondaryAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final uid = credential.user?.uid;
        if (uid != null) {
          await _firestore.collection('users').doc(uid).set({
            'email': email,
            'displayName': name,
            'role': 'club_admin',
            'clubName': clubName,
            'isActive': true,
            'status': 'active',
            'updatedAt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));
       
        admins.add(AdminModel(uid: uid, name: name, email: email));
      }
      await secondaryAuth.signOut();
    } on FirebaseAuthException catch (e) {
      Get.snackbar("Error", e.message ?? "Failed to create admin");
      return;
    }

    showAddAdminForm.value = false;
    nameController.clear();
    emailController.clear();
    passwordController.clear();
    Get.snackbar("Admin created", "Admin account created for $email");
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> pendingInvitesStream() {
    return _firestore
        .collection('role_invites')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

 

  Future<void> resendInvite(String email) async {
    final normalizedEmail = email.trim().toLowerCase();
    await _firestore.collection('role_invites').doc(normalizedEmail).set({
      'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
    Get.snackbar("Invite sent", "Invite resent to $normalizedEmail");
  }

  Future<void> deleteInvite(String email) async {
    final normalizedEmail = email.trim().toLowerCase();
    await _firestore.collection('role_invites').doc(normalizedEmail).delete();
    Get.snackbar("Deleted", "Invite removed for $normalizedEmail");
  }

  Future<void> createClub({
    bool closeOnSuccess = false,
    bool navigateToClubs = false,
  }) async {
    final clubName = clubNameController.text.trim();
    final location = clubLocationController.text.trim();
    if (clubName.isEmpty || location.isEmpty) {
      Get.snackbar("Error", "Club name and location are required");
      return;
    }
    if (admins.length > maxAdmins) {
      Get.snackbar("Error", "Only $maxAdmins admins allowed per club");
      return;
    }

    final docRef = await _firestore.collection('clubs').add({
      'name': clubName,
      'location': location,
      'logoPath': logoPath.value,
      'logoBase64': logoBase64.value,
      'status': 'active',
      'createdAt': FieldValue.serverTimestamp(),
    });

    final adminEntries = <Map<String, dynamic>>[];
    if (admins.isNotEmpty) {
      for (final admin in admins) {
        if (admin.uid.isNotEmpty) {
          await _firestore.collection('users').doc(admin.uid).set({
            'clubId': docRef.id,
            'clubName': clubName,
          }, SetOptions(merge: true));
          
          adminEntries.add({
            'uid': admin.uid,
            'name': admin.name,
            'email': admin.email.toLowerCase(),
          });
        } else if (admin.email.isNotEmpty) {
          final snapshot = await _firestore
              .collection('users')
              .where('email', isEqualTo: admin.email.toLowerCase())
              .limit(1)
              .get();
          if (snapshot.docs.isNotEmpty) {
            final uid = snapshot.docs.first.id;
            await _firestore.collection('users').doc(uid).set({
              'clubId': docRef.id,
              'clubName': clubName,
            }, SetOptions(merge: true));
            
            adminEntries.add({
              'uid': uid,
              'name': admin.name,
              'email': admin.email.toLowerCase(),
            });
          }
        }
      }
    }
    await _firestore.collection('clubs').doc(docRef.id).set({
      'admins': adminEntries,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    _resetFormState();
    Get.snackbar("Created", "Club added successfully");

    if (closeOnSuccess) {
      Get.back();
    }
    if (navigateToClubs) {
      Get.find<SuperAdminBotNavController>().changeTab(1);
    }
  }

  Future<void> deleteAdminByEmail(String email) async {
    final normalizedEmail = email.trim().toLowerCase();
    if (normalizedEmail.isEmpty) {
      return;
    }

    final snapshot = await _firestore
        .collection('users')
        .where('email', isEqualTo: normalizedEmail)
        .where('role', isEqualTo: 'club_admin')
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) {
      Get.snackbar("Not found", "No club admin found for $normalizedEmail");
      return;
    }

    await _firestore.collection('users').doc(snapshot.docs.first.id).delete();
    Get.snackbar("Deleted", "Admin removed for $normalizedEmail");
  }

  Future<void> deleteAdminById(String uid, {String? clubId}) async {
    if (uid.isEmpty) return;
    final userDoc = await _firestore.collection('users').doc(uid).get();
    final userData = userDoc.data();
    final name = userData?['displayName']?.toString();
    final email = userData?['email']?.toString();
    await _firestore.collection('users').doc(uid).delete();
    if (clubId != null && clubId.isNotEmpty) {
      final entry = {
        'uid': uid,
        'name': name ?? '',
        'email': (email ?? '').toLowerCase(),
      };
      await _firestore.collection('clubs').doc(clubId).set({
        'admins': FieldValue.arrayRemove([entry]),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }
    Get.snackbar("Deleted", "Admin removed");
  }

  Future<void> removeAdminFromClub({
    required String uid,
    required String clubId,
  }) async {
    if (uid.isEmpty || clubId.isEmpty) return;
    final userDoc = await _firestore.collection('users').doc(uid).get();
    final userData = userDoc.data();
    final name = userData?['displayName']?.toString() ?? '';
    final email = userData?['email']?.toString() ?? '';

    await _firestore.collection('users').doc(uid).set({
      'clubId': FieldValue.delete(),
      'clubName': FieldValue.delete(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
    await _upsertRoleProfile(
      uid: uid,
      role: 'club_admin',
      data: {
        'clubId': FieldValue.delete(),
        'clubName': FieldValue.delete(),
      },
    );

    await _firestore.collection('clubs').doc(clubId).set({
      'admins': FieldValue.arrayRemove([
        {
          'uid': uid,
          'name': name,
          'email': email.toLowerCase(),
        }
      ]),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    Get.snackbar("Removed", "Admin removed from club");
  }

  Future<void> createClubAdmin({
    required String name,
    required String email,
    required String password,
    required String clubId,
    required String clubName,
  }) async {
    if (name.isEmpty || email.isEmpty) {
      Get.snackbar("Error", "Name and email are required");
      return;
    }
    if (password.length < 6) {
      Get.snackbar("Error", "Password must be at least 6 characters");
      return;
    }
    if (clubId.isEmpty) {
      Get.snackbar("Error", "Missing club id");
      return;
    }
    final adminCount = await _fetchClubAdminCount(clubId);
    if (adminCount >= maxAdmins) {
      Get.snackbar("Error", "Only $maxAdmins admins allowed per club");
      return;
    }

    try {
      final secondaryApp = await _getSecondaryApp();
      final secondaryAuth = FirebaseAuth.instanceFor(app: secondaryApp);
      final credential = await secondaryAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final uid = credential.user?.uid;
      if (uid != null) {
        await _firestore.collection('users').doc(uid).set({
          'email': email,
          'displayName': name,
          'role': 'club_admin',
          'clubId': clubId,
          'clubName': clubName,
          'isActive': true,
          'status': 'active',
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
        await _upsertRoleProfile(
          uid: uid,
          role: 'club_admin',
          data: {
            'email': email,
            'displayName': name,
            'clubId': clubId,
            'clubName': clubName,
            'isActive': true,
            'status': 'active',
          },
        );
        
        await _firestore.collection('clubs').doc(clubId).set({
          'admins': FieldValue.arrayUnion([
            {
              'uid': uid,
              'name': name,
              'email': email.toLowerCase(),
            }
          ]),
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }
      await secondaryAuth.signOut();
    } on FirebaseAuthException catch (e) {
      Get.snackbar("Error", e.message ?? "Failed to create admin");
      return;
    }

    Get.snackbar("Admin created", "Admin account created for $email");
  }

  Future<AdminModel?> attachExistingClubAdminByEmail({
    required String email,
    required String clubId,
    required String clubName,
  }) async {
    final normalizedEmail = email.trim().toLowerCase();
    if (normalizedEmail.isEmpty) {
      Get.snackbar("Error", "Admin email is required");
      return null;
    }
    if (clubId.isEmpty) {
      Get.snackbar("Error", "Missing club id");
      return null;
    }
    final adminCount = await _fetchClubAdminCount(clubId);
    if (adminCount >= maxAdmins) {
      Get.snackbar("Error", "Only $maxAdmins admins allowed per club");
      return null;
    }

    final snapshot = await _firestore
        .collection('users')
        .where('email', isEqualTo: normalizedEmail)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) {
      Get.snackbar("Error", "No existing club admin found for $normalizedEmail");
      return null;
    }

    final doc = snapshot.docs.first;
    final data = doc.data();
    final role = (data['role'] ?? '').toString().trim().toLowerCase();
    if (role.isNotEmpty && role != 'club_admin') {
      Get.snackbar("Error", "User is not a club admin");
      return null;
    }
    final currentClubId = (data['clubId'] ?? '').toString();
    if (currentClubId.isNotEmpty && currentClubId != clubId) {
      Get.snackbar("Error", "Admin already assigned to another club");
      return null;
    }

    final uid = doc.id;
    final name = (data['displayName'] ?? '').toString();

    await _firestore.collection('users').doc(uid).set({
      'role': 'club_admin',
      'clubId': clubId,
      'clubName': clubName,
      'isActive': true,
      'status': 'active',
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
    await _upsertRoleProfile(
      uid: uid,
      role: 'club_admin',
      data: {
        'email': normalizedEmail,
        'displayName': name,
        'clubId': clubId,
        'clubName': clubName,
        'isActive': true,
        'status': 'active',
      },
    );
    await _firestore.collection('clubs').doc(clubId).set({
      'admins': FieldValue.arrayUnion([
        {
          'uid': uid,
          'name': name,
          'email': normalizedEmail,
        }
      ]),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    Get.snackbar("Admin added", "Admin linked to $clubName");
    return AdminModel(uid: uid, name: name, email: normalizedEmail);
  }

  Future<FirebaseApp> _getSecondaryApp() async {
    try {
      return Firebase.app('secondary');
    } catch (_) {
      return Firebase.initializeApp(
        name: 'secondary',
        options: Firebase.app().options,
      );
    }
  }

  Future<int> _fetchClubAdminCount(String clubId) async {
    final clubDoc = await _firestore.collection('clubs').doc(clubId).get();
    final data = clubDoc.data();
    final adminsField = data?['admins'];
    if (adminsField is List) {
      return adminsField.length;
    }
    final snapshot = await _firestore
        .collection('users')
        .where('clubId', isEqualTo: clubId)
        .where('role', isEqualTo: 'club_admin')
        .get();
    return snapshot.docs.length;
  }

  void cancelAndGoHome() {
    Get.find<SuperAdminBotNavController>().changeTab(0);
  }

  Future<void> _upsertRoleProfile({
    required String uid,
    required String role,
    required Map<String, dynamic> data,
  }) async {
    final normalizedRole = role.trim().toLowerCase();
    await _firestore
        .collection('users')
        .doc(uid)
        .collection(normalizedRole)
        .doc('profile')
        .set({
      ...data,
      'role': normalizedRole,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

 
  void _resetFormState() {
    clubNameController.clear();
    clubLocationController.clear();
    nameController.clear();
    emailController.clear();
    passwordController.clear();
    admins.clear();
    showAddAdminForm.value = false;
    logoName.value = null;
    logoPath.value = null;
    logoBase64.value = null;
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';

class AdminModel {
  String adminId;
  String email;
  String username;
  bool verified;

  AdminModel({
    required this.adminId,
    required this.email,
    required this.username,
    required this.verified,
  });

  factory AdminModel.fromDocument(DocumentSnapshot doc) {
    return AdminModel(
      adminId: doc.id,
      email: doc['email'],
      username: doc['username'],
      verified: doc['verified'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'username': username,
      'verified': verified,
    };
  }

  Future<void> createAdmin() async {
    await FirebaseFirestore.instance.collection('admins').add(toMap());
  }

  Future<void> updateAdmin() async {
    await FirebaseFirestore.instance.collection('admins').doc(adminId).update(toMap());
  }
}

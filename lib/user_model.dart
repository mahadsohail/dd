import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  String userId;
  String name;
  String userName;
  String email;
  String type;
  bool verified;

  UserModel({
    required this.userId,
    required this.name,
    required this.userName,
    required this.email,
    required this.type,
    required this.verified,
  });

  // Add fromDocument method if you need to fetch UserModel from Firestore document
  factory UserModel.fromDocument(DocumentSnapshot doc) {
    return UserModel(
      userId: doc['userId'],
      name: doc['name'],
      userName: doc['userName'],
      email: doc['email'],
      type: doc['type'],
      verified: doc['verified'],
    );
  }
}
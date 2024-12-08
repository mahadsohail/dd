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

  // Factory constructor to create UserModel from Firestore document
  factory UserModel.fromDocument(DocumentSnapshot doc) {
    return UserModel(
      userId: doc.id,
      name: doc['name'],
      userName: doc['userName'],
      email: doc['email'],
      type: doc['type'],
      verified: doc['verified'],
    );
  }

  // Static method to fetch user details from Firestore by userId
  static Future<UserModel?> fetchUserById(String userId) async {
    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      if (doc.exists) {
        return UserModel.fromDocument(doc);
      } else {
        print("User does not exist");
        return null;
      }
    } catch (e) {
      print("Error fetching user details: $e");
      return null;
    }
  }
}

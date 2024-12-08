import 'package:cloud_firestore/cloud_firestore.dart';

class SlotModel {
  String doctorId;
  String day;
  String time;

  SlotModel({
    required this.doctorId,
    required this.day,
    required this.time,
  });

  // Convert SlotModel to a map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'doctorId': doctorId,
      'day': day,
      'time': time,
    };
  }

  // Create SlotModel from Firestore document
  factory SlotModel.fromDocument(DocumentSnapshot doc) {
    return SlotModel(
      doctorId: doc['doctorId'],
      day: doc['day'],
      time: doc['time'],
    );
  }
}

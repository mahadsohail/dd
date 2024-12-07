import 'package:cloud_firestore/cloud_firestore.dart';

class PatientModel {
  String patientId;
  String name;
  String profilePic;
  bool disabled;

  PatientModel({
    required this.patientId,
    required this.name,
    required this.profilePic,
    required this.disabled,
  });

  factory PatientModel.fromDocument(DocumentSnapshot doc) {
    return PatientModel(
      patientId: doc.id,
      name: doc['name'],
      profilePic: doc['profilePic'],
      disabled: doc['disabled'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'profilePic': profilePic,
      'disabled': disabled,
    };
  }

  Future<void> updatePatient() async {
    await FirebaseFirestore.instance.collection('patients').doc(patientId).update(toMap());
  }

  Future<void> disablePatient() async {
    disabled = true;
    await updatePatient();
  }

  Future<void> enablePatient() async {
    disabled = false;
    await updatePatient();
  }
}

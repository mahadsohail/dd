import 'package:cloud_firestore/cloud_firestore.dart';

class DoctorModel {
  String doctorId;
  String name;
  String email;
  String specialization;
  String qualification;
  String profilePic;
  int experience;
  double rating;
  bool disabled;
  bool categoryDisabled;

  DoctorModel({
    required this.doctorId,
    required this.name,
    required this.email,
    required this.specialization,
    required this.qualification,
    required this.profilePic,
    required this.experience,
    required this.rating,
    required this.disabled,
    required this.categoryDisabled,
  });

  factory DoctorModel.fromDocument(DocumentSnapshot doc) {
    return DoctorModel(
      doctorId: doc.id,
      name: doc['name'],
      email: doc['email'],
      specialization: doc['specialization'],
      qualification: doc['qualification'],
      profilePic: doc['profilePic'],
      experience: doc['experience'],
      rating: doc['rating'],
      disabled: doc['disabled'] ?? false,
      categoryDisabled: doc['categoryDisabled'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'specialization': specialization,
      'qualification': qualification,
      'profilePic': profilePic,
      'experience': experience,
      'rating': rating,
      'disabled': disabled,
      'categoryDisabled': categoryDisabled,
    };
  }

  Future<void> updateDoctor() async {
    await FirebaseFirestore.instance.collection('doctors').doc(doctorId).update(toMap());
  }

  Future<void> disableDoctor() async {
    disabled = true;
    await updateDoctor();
  }

  Future<void> enableDoctor() async {
    disabled = false;
    await updateDoctor();
  }

  Future<void> disableCategory() async {
    categoryDisabled = true;
    await updateDoctor();
  }

  Future<void> enableCategory() async {
    categoryDisabled = false;
    await updateDoctor();
  }
}

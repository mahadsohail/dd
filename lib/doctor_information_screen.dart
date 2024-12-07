// doctor_information_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DoctorInformationScreen extends StatefulWidget {
  const DoctorInformationScreen({super.key});

  @override
  _DoctorInformationScreenState createState() => _DoctorInformationScreenState();
}

class _DoctorInformationScreenState extends State<DoctorInformationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _qualificationController = TextEditingController();
  final _experienceController = TextEditingController();
  String _profilePicUrl = '';
  double _rating = 0.0;

  @override
  void initState() {
    super.initState();
    _loadDoctorInfo();
  }

  Future<void> _loadDoctorInfo() async {
    // Load doctor information from Firestore
    // Assume the doctor ID is stored in a variable `doctorId`
    String doctorId = 'doctorId'; // Replace with actual doctor ID
    DocumentSnapshot docSnapshot = await FirebaseFirestore.instance.collection('doctors').doc(doctorId).get();
    if (docSnapshot.exists) {
      setState(() {
        _nameController.text = docSnapshot['name'];
        _qualificationController.text = docSnapshot['qualification'];
        _experienceController.text = docSnapshot['experience'];
        _profilePicUrl = docSnapshot['profilePicUrl'];
        _rating = docSnapshot['rating'];
      });
    }
  }

  void _saveDoctorInfo() {
    if (_formKey.currentState!.validate()) {
      // Save updated doctor information to Firestore
      String doctorId = 'doctorId'; // Replace with actual doctor ID
      FirebaseFirestore.instance.collection('doctors').doc(doctorId).update({
        'name': _nameController.text,
        'qualification': _qualificationController.text,
        'experience': _experienceController.text,
        'profilePicUrl': _profilePicUrl,
        'rating': _rating,
      });
    }
  }

  void _addSlot() {
    // Implement slot addition logic
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: ListView(
          children: [
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Name'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your name';
                }
                return null;
              },
            ),
            TextFormField(
              controller: _qualificationController,
              decoration: InputDecoration(labelText: 'Qualification'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your qualification';
                }
                return null;
              },
            ),
            TextFormField(
              controller: _experienceController,
              decoration: InputDecoration(labelText: 'Experience'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your experience';
                }
                return null;
              },
            ),
            // Add Profile Picture, Rating, and Slots
            ElevatedButton(
              onPressed: _saveDoctorInfo,
              child: Text('Save'),
            ),
            ElevatedButton(
              onPressed: _addSlot,
              child: Text('Add Slot'),
            ),
          ],
        ),
      ),
    );
  }
}

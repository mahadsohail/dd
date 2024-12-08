import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'auth_service.dart';
import 'cloudinary_service.dart';
import 'doctor_model.dart';
import 'user_model.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _userNameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthService _authService = AuthService();

  void _login() async {
    String userName = _userNameController.text;
    String password = _passwordController.text;

    // Fetch user by username
    QuerySnapshot userQuery = await FirebaseFirestore.instance
        .collection('users')
        .where('userName', isEqualTo: userName)
        .get();

    if (userQuery.docs.isNotEmpty) {
      DocumentSnapshot userDoc = userQuery.docs.first;
      UserModel userModel = UserModel.fromDocument(userDoc);

      // Check if the user's type is doctor
      if (userModel.type == 'doctor') {
        // Check if the doctor's profile exists
        DocumentSnapshot doctorDoc = await FirebaseFirestore.instance
            .collection('doctors')
            .doc(userModel.userId)
            .get();

        if (!doctorDoc.exists) {
          // If doctor profile does not exist, show profile dialog
          _showDoctorProfileDialog(userModel, password);
          return; // Exit the login process
        }
      }

      // Sign in the user
      User? user = await _authService.signIn(userModel.email, password);

      if (user != null) {
        await _authService.updateVerificationStatus(user);

        DocumentSnapshot updatedUserDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        UserModel updatedUserModel = UserModel.fromDocument(updatedUserDoc);

        if (updatedUserModel.verified) {
          if (updatedUserModel.type == 'doctor') {
            // Navigate to the doctor dashboard if profile exists
            Navigator.pushReplacementNamed(context, '/doctor_dashboard');
          } else {
            // Handle other types of users (patient/admin)
            Navigator.pushReplacementNamed(context, '/patient_dashboard');
          }
        } else {
          // Handle email not verified
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Email not verified'),
              content: const Text('Please verify your email to log in.'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        }
      } else {
        _showErrorDialog('Login Failed', 'Invalid username or password');
      }
    } else {
      _showErrorDialog('User Not Found', 'No user found with this username');
    }
  }

  void _showDoctorProfileDialog(UserModel user, String password) {
    final TextEditingController qualificationsController = TextEditingController();
    final TextEditingController experienceController = TextEditingController();
    String? specialization;
    File? profileImage;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Complete Your Profile'),
        content: SingleChildScrollView(
          child: StatefulBuilder(
            builder: (context, setState) {
              return Column(
                children: [
                  // Profile Picture
                  profileImage == null
                      ? IconButton(
                    icon: Icon(Icons.camera_alt),
                    onPressed: () async {
                      final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
                      if (pickedFile != null) {
                        setState(() {
                          profileImage = File(pickedFile.path);
                        });
                      }
                    },
                  )
                      : CircleAvatar(
                    radius: 50,
                    backgroundImage: FileImage(profileImage!),
                  ),
                  TextField(
                    controller: qualificationsController,
                    decoration: const InputDecoration(
                      labelText: 'Qualifications',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 10),
                  TextField(
                    controller: experienceController,
                    decoration: const InputDecoration(
                      labelText: 'Experience (Years)',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  SizedBox(height: 10),
                  // Specialization Dropdown (fetch categories from Firestore)
                  FutureBuilder<QuerySnapshot>(
                    future: FirebaseFirestore.instance.collection('categories').get(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return CircularProgressIndicator();
                      } else if (snapshot.hasError) {
                        return Text('Error fetching categories');
                      } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return Text('No categories available');
                      } else {
                        List<String> categories = snapshot.data!.docs
                            .map((doc) => doc['name'] as String)
                            .toList();
                        return DropdownButton<String>(
                          hint: Text('Select Specialization'),
                          value: specialization,
                          onChanged: (value) {
                            setState(() {
                              specialization = value;
                            });
                          },
                          items: categories.map((category) {
                            return DropdownMenuItem<String>(
                              value: category,
                              child: Text(category),
                            );
                          }).toList(),
                        );
                      }
                    },
                  ),
                ],
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              if (specialization != null &&
                  profileImage != null &&
                  qualificationsController.text != "" &&
                  experienceController.text != "") {
                // Upload the image to Cloudinary
                String? imageUrl = await CloudinaryService().uploadImage(profileImage!);
                if (imageUrl == null) {
                  _showErrorDialog('Error', 'Failed to upload image');
                  return;
                }

                // Create the DoctorModel
                DoctorModel doctor = DoctorModel(
                  doctorId: user.userId,
                  name: user.name,
                  email: user.email,
                  specialization: specialization!,
                  qualification: qualificationsController.text,
                  profilePic: imageUrl,
                  experience: int.parse(experienceController.text),
                  rating: 0.0,
                  disabled: false,
                  categoryDisabled: false,
                );

                // Save the doctor profile to Firestore
                await FirebaseFirestore.instance.collection('doctors').doc(user.userId).set(doctor.toMap());

                // Navigate to the doctor dashboard
                Navigator.pop(context);
              } else {
                // Show error if necessary fields are missing
                _showErrorDialog('Error', 'Please complete all fields');
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }


  void _showErrorDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showForgotPasswordDialog() {
    final TextEditingController emailController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Forgot Password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: 'Enter your email',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              String email = emailController.text;
              if (email.isNotEmpty) {
                await _authService.sendPasswordResetEmail(email);
                Navigator.of(context).pop();
                _showErrorDialog('Password Reset', 'Password reset email sent. Check your inbox.');
              }
            },
            child: const Text('Send'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.blueAccent,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 40),
              Center(
                child: Text(
                  'Welcome Back!',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueAccent,
                  ),
                ),
              ),
              SizedBox(height: 40),
              TextField(
                controller: _userNameController,
                decoration: InputDecoration(
                  labelText: 'Username',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
              ),
              SizedBox(height: 20),
              TextField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock),
                ),
                obscureText: true,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _login,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: Text('Login', style: TextStyle(fontSize: 18)),
              ),
              SizedBox(height: 10),
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/register');
                },
                child: Text('Register', style: TextStyle(fontSize: 16)),
              ),
              TextButton(
                onPressed: _showForgotPasswordDialog,
                child: Text('Forgot Password?', style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

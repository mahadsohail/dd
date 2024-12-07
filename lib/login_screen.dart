import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'auth_service.dart';
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
      User? user = await _authService.signIn(userModel.email, password);

      if (user != null) {
        await _authService.updateVerificationStatus(user);

        DocumentSnapshot updatedUserDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        UserModel updatedUserModel = UserModel.fromDocument(updatedUserDoc);

        if (updatedUserModel.verified) {
          if (updatedUserModel.type == 'patient') {
            Navigator.pushReplacementNamed(context, '/patient_dashboard');
          } else if (updatedUserModel.type == 'doctor') {
            Navigator.pushReplacementNamed(context, '/doctor_dashboard');
          } else if (updatedUserModel.type == 'admin') {
            Navigator.pushReplacementNamed(context, '/admin_dashboard');
          }
        } else {
          // Handle email not verified
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text('Email not verified'),
              content: Text('Please verify your email to log in.'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('OK'),
                ),
              ],
            ),
          );
        }
      } else {
        // Handle sign in error
      }
    } else {
      // Handle user not found
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _userNameController,
              decoration: InputDecoration(labelText: 'Username'),
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            ElevatedButton(
              onPressed: _login,
              child: Text('Login'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, '/register');
              },
              child: Text('Register'),
            ),
          ],
        ),
      ),
    );
  }
}

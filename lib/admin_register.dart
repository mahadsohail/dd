import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'auth_service.dart';
import 'user_model.dart';

class AdminRegisterScreen extends StatefulWidget {
  const AdminRegisterScreen({super.key});

  @override
  _AdminRegisterScreenState createState() => _AdminRegisterScreenState();
}

class _AdminRegisterScreenState extends State<AdminRegisterScreen> {
  final AuthService _authService = AuthService();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  String? errorMessage; // For displaying error messages

  void _registerAdmin() async {
    String name = _nameController.text;
    String email = _emailController.text;
    String password = _passwordController.text;
    String confirmPassword = _confirmPasswordController.text;


    if (password == confirmPassword) {
      setState(() {
        errorMessage = null; // Reset error message when passwords match
      });


      UserModel userModel = UserModel(
        userId: '',
        name: name,
        userName: 'admin', // Default admin username
        email: email,
        type: 'admin',
        verified: false,
      );

      User? user = await _authService.register(userModel, password);
      if (user != null) {
        FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'userId': user.uid,
          'name': name,
          'userName': 'admin',
          'email': email,
          'type': 'admin',
          'verified': false,
        }).then((_) {
          // Show a dialog or snackbar informing the user to check their email
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text('Verify your email'),
              content: Text('A verification email has been sent to $email. Please verify your email before logging in.'),
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

          // Navigate to login or another relevant page
          Navigator.pushReplacementNamed(context, '/login');
        }).catchError((error) {
          // Handle errors
          print("Failed to add user: $error");
        });
      }
    } else {
      // Handle password mismatch
      setState(() {
        errorMessage = 'Passwords do not match!'; // Reset error message when passwords match
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Registration'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            TextField(
              controller: _confirmPasswordController,
              decoration: InputDecoration(labelText: 'Confirm Password'),
              obscureText: true,
            ),
            if (errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  errorMessage!,
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ElevatedButton(
              onPressed: _registerAdmin,
              child: Text('Register Admin'),
            ),
          ],
        ),
      ),
    );
  }
}
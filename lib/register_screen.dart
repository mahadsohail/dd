import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'auth_service.dart';
import 'user_model.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _userNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  String _userType = 'patient';
  final AuthService _authService = AuthService();

  void _register() async {
    String name = _nameController.text;
    String userName = _userNameController.text;
    String email = _emailController.text;
    String password = _passwordController.text;
    String confirmPassword = _confirmPasswordController.text;

    if (password == confirmPassword) {
      UserModel userModel = UserModel(
        userId: '',
        name: name,
        userName: userName,
        email: email,
        type: _userType,
        verified: false,
      );

      User? user = await _authService.register(userModel, password);

      if (user != null) {
        // Create a user document in Firestore
        FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'userId': user.uid,
          'name': name,
          'userName': userName,
          'email': email,
          'type': _userType,
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
      print("Passwords do not match.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Register')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: _userNameController,
              decoration: InputDecoration(labelText: 'Username'),
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
            DropdownButton<String>(
              value: _userType,
              onChanged: (String? newValue) {
                setState(() {
                  _userType = newValue!;
                });
              },
              items: <String>['patient', 'doctor']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            ElevatedButton(
              onPressed: _register,
              child: Text('Register'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, '/login');
              },
              child: Text('Login'),
            ),
          ],
        ),
      ),
    );
  }
}

// my_app.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:dd/admin_register.dart';
import 'package:dd/login_screen.dart';
import 'package:provider/provider.dart';

import 'register_screen.dart';
import 'patient_dashboard.dart';
import 'doctor_dashboard.dart';
import 'admin_dashboard.dart';
import 'auth_service.dart';


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        StreamProvider<User?>.value(
          value: AuthService().user,
          initialData: null,
        ),
      ],
      child: MaterialApp(
        title: 'Health Management App',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        initialRoute: '/',
        routes: {
          '/': (context) => Wrapper(),
          '/login': (context) => LoginScreen(),
          '/register': (context) => RegisterScreen(),
          '/patient_dashboard': (context) => PatientDashboard(),
          '/doctor_dashboard': (context) => DoctorDashboard(),
          '/admin_dashboard': (context) => AdminDashboard(),
          '/admin_register': (context) => AdminRegisterScreen(),
        },
      ),
    );
  }
}

class Wrapper extends StatelessWidget {
  const Wrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: checkIfUsersExist(),
      builder: (context, userCheckSnapshot) {
        if (userCheckSnapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator(); // Loading state for user check
        }

        if (userCheckSnapshot.data == false) {
          // If no users exist, redirect to admin registration screen
          Future.microtask(() => Navigator.pushReplacementNamed(context, '/admin_register'));
          return Container(); // Placeholder while redirecting
        }

        final user = Provider.of<User?>(context);

        if (user == null) {
          return LoginScreen(); // If no user is logged in, show login screen
        } else {
          return FutureBuilder<DocumentSnapshot>(
            future: FirebaseFirestore.instance.collection('users').doc(user.uid).get(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator(); // Loading state
              }

              if (snapshot.hasError) {
                return Text("Something went wrong");
              }

              if (snapshot.hasData && !snapshot.data!.exists) {
                return Text("User does not exist");
              }

              // Check user type and navigate to the appropriate dashboard
              if (snapshot.hasData && snapshot.data!.exists) {
                var userType = snapshot.data!['type'];
                if (userType == 'patient') {
                  return PatientDashboard();
                } else if (userType == 'doctor') {
                  return DoctorDashboard();
                } else if (userType == 'admin') {
                  return AdminDashboard();
                }
              }

              return Text("Unknown user type");
            },
          );
        }
      },
    );
  }

  Future<bool> checkIfUsersExist() async {
    QuerySnapshot userQuery = await FirebaseFirestore.instance.collection('users').get();
    return userQuery.docs.isNotEmpty;
  }
}
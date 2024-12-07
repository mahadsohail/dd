import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'my_app.dart'; // Your main app file

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

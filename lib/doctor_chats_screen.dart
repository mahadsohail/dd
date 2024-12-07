// doctor_chats_screen.dart
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class DoctorChatsScreen extends StatelessWidget {
  final DatabaseReference _chatsRef = FirebaseDatabase.instance.ref().child('chats');
  DoctorChatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DatabaseEvent>(
      stream: _chatsRef.onValue,
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data?.snapshot.value == null) {
          return const CircularProgressIndicator();
        }
        Map<dynamic, dynamic> chats = snapshot.data!.snapshot.value as Map<dynamic, dynamic>;
        List<Widget> chatHeads = [];
        chats.forEach((key, value) {
          chatHeads.add(ListTile(
            title: Text(value['patientName']),
            subtitle: Text(value['lastMessage']),
            onTap: () {
              // Navigate to chat screen
            },
          ));
        });
        return ListView(children: chatHeads);
      },
    );
  }
}

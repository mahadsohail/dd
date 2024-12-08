// doctor_information_screen.dart
import 'package:dd/slot_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'doctor_model.dart';

class DoctorInformationScreen extends StatefulWidget {
  const DoctorInformationScreen({super.key});

  @override
  _DoctorInformationScreenState createState() =>
      _DoctorInformationScreenState();
}

class _DoctorInformationScreenState extends State<DoctorInformationScreen> {
  final List<String> timeSlots = List.generate(24, (index) {
    final startHour = index;
    final endHour = (index + 1) % 24;
    return '${startHour.toString().padLeft(2, '0')}:00-${endHour.toString().padLeft(2, '0')}:00';
  });

  // Map to store the expansion state for each day
  Map<String, bool> _expandedDays = {
    'Monday': false,
    'Tuesday': false,
    'Wednesday': false,
    'Thursday': false,
    'Friday': false,
    'Saturday': false,
    'Sunday': false,
  };

  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('doctors')
          .doc(user?.uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || !snapshot.data!.exists) {
          return Center(child: Text('No doctor data available.'));
        }

        DoctorModel doctor = DoctorModel.fromDocument(snapshot.data!);

        return Scaffold(
          appBar: AppBar(
            title: Text(doctor.name),
          ),
          body: Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundImage: NetworkImage(doctor.profilePic),
                ),
                SizedBox(height: 10),
                Text('Specialization: ${doctor.specialization}'),
                SizedBox(height: 10),
                Text('Qualifications: ${doctor.qualification}'),
                SizedBox(height: 10),
                Text('Experience: ${doctor.experience} years'),
                SizedBox(height: 10),
                Text('Rating: ${doctor.rating}'),
                SizedBox(height: 20),

                // Show Time Slots for the week
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('slots')
                        .where('doctorId', isEqualTo: user?.uid)
                        .snapshots(),
                    builder: (context, slotSnapshot) {
                      if (slotSnapshot.connectionState == ConnectionState.waiting) {
                        return CircularProgressIndicator();
                      }

                      // Group slots by day of the week
                      Map<String, List<String>> daySlots = {};
                      for (var doc in slotSnapshot.data!.docs) {
                        SlotModel slot = SlotModel.fromDocument(doc);
                        if (!daySlots.containsKey(slot.day)) {
                          daySlots[slot.day] = [];
                        }
                        daySlots[slot.day]?.add(slot.time);
                      }

                      // Sort slots for each day
                      daySlots.forEach((key, slots) {
                        slots.sort((a, b) {
                          // Convert 'HH:mm-HH:mm' to time for comparison
                          var timeA = _parseTime(a);
                          var timeB = _parseTime(b);
                          return timeA.compareTo(timeB);
                        });
                      });

                      return ListView.builder(
                        itemCount: 7,
                        itemBuilder: (context, index) {
                          String day = _getDayOfWeek(index);
                          List<String> slots = daySlots[day] ?? [];
                          return ExpansionTile(
                            title: Text(day),
                            trailing: IconButton(
                              icon: Icon(Icons.add),
                              onPressed: () async {
                                await _addSlotDialog(day, slots, user?.uid);
                              },
                            ),
                            initiallyExpanded: _expandedDays[day] ?? false, // Use the stored state
                            onExpansionChanged: (expanded) {
                              setState(() {
                                _expandedDays[day] = expanded; // Update the expansion state
                              });
                            },
                            children: [
                              ...slots.map((slot) {
                                return ListTile(
                                  title: Text(slot),
                                  trailing: IconButton(
                                    icon: Icon(Icons.delete),
                                    onPressed: () async {
                                      // Delete slot from Firestore
                                      await FirebaseFirestore.instance
                                          .collection('slots')
                                          .where('doctorId', isEqualTo: user?.uid)
                                          .where('day', isEqualTo: day)
                                          .where('time', isEqualTo: slot)
                                          .get()
                                          .then((querySnapshot) {
                                        for (var doc in querySnapshot.docs) {
                                          doc.reference.delete();
                                        }
                                      });
                                    },
                                  ),
                                );
                              }),
                            ],
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Helper function to convert time string 'HH:mm-HH:mm' to DateTime for comparison
  DateTime _parseTime(String time) {
    final timeParts = time.split('-')[0].split(':');
    final hour = int.parse(timeParts[0]);
    final minute = int.parse(timeParts[1]);
    return DateTime(0, 1, 1, hour, minute); // Create a DateTime object for sorting
  }

  // Add Slot Dialog
  Future<void> _addSlotDialog(String day, List<String> usedSlots, String? doctorId) async {
    String? selectedSlot;

    // Filter out the already used slots from the dropdown
    List<String> availableSlots = timeSlots.where((slot) => !usedSlots.contains(slot)).toList();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add Slot for $day'),
          content: StatefulBuilder( // Use StatefulBuilder to manage local state within the dialog
            builder: (context, setState) {
              return DropdownButton<String>(
                value: selectedSlot, // The selected value
                onChanged: (String? newValue) {
                  setState(() {
                    selectedSlot = newValue; // Update the selected slot
                  });
                },
                items: availableSlots.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () async {
                if (selectedSlot != null) {
                  // Add the new slot to Firestore
                  await FirebaseFirestore.instance.collection('slots').add({
                    'doctorId': doctorId,
                    'day': day,
                    'time': selectedSlot,
                  });

                  // Close the dialog
                  Navigator.pop(context);
                }
              },
              child: Text('Add Slot'),
            ),
          ],
        );
      },
    );
  }



  String _getDayOfWeek(int index) {
    switch (index) {
      case 0:
        return 'Monday';
      case 1:
        return 'Tuesday';
      case 2:
        return 'Wednesday';
      case 3:
        return 'Thursday';
      case 4:
        return 'Friday';
      case 5:
        return 'Saturday';
      case 6:
        return 'Sunday';
      default:
        return '';
    }
  }
}

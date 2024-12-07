// doctor_dashboard.dart
import 'package:flutter/material.dart';
import 'auth_service.dart';
import 'doctor_information_screen.dart';
import 'doctor_appointments_screen.dart';
import 'doctor_chats_screen.dart';
import 'doctor_profile_screen.dart';

class DoctorDashboard extends StatefulWidget {
  const DoctorDashboard({super.key});

  @override
  _DoctorDashboardState createState() => _DoctorDashboardState();
}

class _DoctorDashboardState extends State<DoctorDashboard> with SingleTickerProviderStateMixin {
  final AuthService _authService = AuthService();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Doctor Dashboard'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              _authService.signOut();
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                DoctorInformationScreen(),
                DoctorAppointmentsScreen(),
                DoctorChatsScreen(),
                DoctorProfileScreen(),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: TabBar(
        controller: _tabController,
        tabs: [
          Tab(icon: Icon(Icons.info), text: 'Information'),
          Tab(icon: Icon(Icons.calendar_today), text: 'Appointments'),
          Tab(icon: Icon(Icons.chat), text: 'Chats'),
          Tab(icon: Icon(Icons.person), text: 'Profile'),
        ],
        labelColor: Colors.amber[800],
        unselectedLabelColor: Colors.grey,
        indicatorColor: Colors.amber[800],
      ),
    );
  }
}

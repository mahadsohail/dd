import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'auth_service.dart';
import 'doctor_model.dart';
import 'patient_model.dart';
import 'category_model.dart';
import 'admin_model.dart';
import 'user_model.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  _AdminDashboardState createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> with SingleTickerProviderStateMixin {
  final AuthService _authService = AuthService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _categoryNameController = TextEditingController();
  final TextEditingController _adminEmailController = TextEditingController();
  final TextEditingController _adminUsernameController = TextEditingController();
  final TextEditingController _adminPasswordController = TextEditingController();

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _categoryController.dispose();
    _categoryNameController.dispose();
    _adminEmailController.dispose();
    _adminUsernameController.dispose();
    _adminPasswordController.dispose();
    super.dispose();
  }

  void _addCategory(String name) async {
    CategoryModel newCategory = CategoryModel(
      categoryId: '',
      name: name,
      disabled: false,
    );
    await newCategory.createCategory();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Category added successfully')),
    );
  }

  void _enableCategory(String categoryId) async {
    await _firestore.collection('categories').doc(categoryId).update({
      'disabled': false,
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Category enabled')),
    );
  }

  void _disableCategory(String categoryId) async {
    await _firestore.collection('categories').doc(categoryId).update({
      'disabled': true,
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Category disabled')),
    );
  }

  void _togglePatientStatus(PatientModel patient) async {
    if (patient.disabled) {
      await patient.enablePatient();
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Patient enabled')));
    } else {
      await patient.disablePatient();
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Patient disabled')));
    }
  }

  void _toggleDoctorStatus(DoctorModel doctor) async {
    if (doctor.disabled) {
      await doctor.enableDoctor();
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Doctor enabled')));
    } else {
      await doctor.disableDoctor();
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Doctor disabled')));
    }
  }

  void _toggleCategoryStatus(DoctorModel doctor) async {
    if (doctor.categoryDisabled) {
      await doctor.enableCategory();
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Category enabled')));
    } else {
      await doctor.disableCategory();
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Category disabled')));
    }
  }

  void _addAdmin() async {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add New Admin'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _adminEmailController,
                decoration: const InputDecoration(labelText: 'Email'),
              ),
              TextField(
                controller: _adminUsernameController,
                decoration: const InputDecoration(labelText: 'Username'),
              ),
              TextField(
                controller: _adminPasswordController,
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
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
                if (_adminEmailController.text.isNotEmpty &&
                    _adminUsernameController.text.isNotEmpty &&
                    _adminPasswordController.text.isNotEmpty) {
                  String email = _adminEmailController.text;
                  String username = _adminUsernameController.text;
                  String password = _adminPasswordController.text;

                  AdminModel newAdmin = AdminModel(
                    adminId: '',
                    email: email,
                    username: username,
                    verified: true,
                  );
                  UserModel newUser = UserModel(
                    userId: '',
                    name: username,
                    userName: username,
                    email: email,
                    type: 'admin',
                    verified: true,
                  );

                  User? user = await _authService.register(newUser, password);
                  if (user != null) {
                    await newAdmin.createAdmin();
                    await _firestore.collection('users').doc(user.uid).set({
                      'userId': user.uid,
                      'name': newUser.name,
                      'userName': newUser.userName,
                      'email': newUser.email,
                      'type': newUser.type,
                      'verified': newUser.verified,
                    });

                    String subject = 'Admin Account Created';
                    String body = 'Your admin account has been created.\n\n'
                        'Username: $username\n'
                        'Password: $password\n\n'
                        'Please sign in and change your password immediately.';

                    await _authService.sendEmail(email, subject, body);

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Admin added successfully')),
                    );

                    Navigator.of(context).pop();
                    _adminEmailController.clear();
                    _adminUsernameController.clear();
                    _adminPasswordController.clear();
                  }
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        title: const Text('Admin Dashboard', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'Patients'),
            Tab(text: 'Doctors'),
            Tab(text: 'Categories'),
            Tab(text: 'Admins'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildPatientList(),
          _buildDoctorList(),
          _buildCategoryList(),
          _buildAdminList(),
        ],
      ),
    );
  }

  Widget _buildPatientList() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection('patients').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        var patients = snapshot.data!.docs.map((doc) {
          return PatientModel.fromDocument(doc);
        }).toList();

        return ListView.builder(
          itemCount: patients.length,
          itemBuilder: (context, index) {
            var patient = patients[index];
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              elevation: 6,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              child: ListTile(
                contentPadding: const EdgeInsets.all(16),
                title: Text(patient.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                trailing: IconButton(
                  icon: Icon(patient.disabled ? Icons.check_circle : Icons.remove_circle),
                  color: patient.disabled ? Colors.green : Colors.red,
                  onPressed: () {
                    _togglePatientStatus(patient);
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDoctorList() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection('doctors').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        var doctors = snapshot.data!.docs.map((doc) {
          return DoctorModel.fromDocument(doc);
        }).toList();

        return ListView.builder(
          itemCount: doctors.length,
          itemBuilder: (context, index) {
            var doctor = doctors[index];
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              elevation: 6,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              child: ListTile(
                contentPadding: const EdgeInsets.all(16),
                title: Text(doctor.name, style: const TextStyle(fontWeight: FontWeight.bold)),

                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(doctor.disabled ? Icons.check_circle : Icons.remove_circle),
                      color: doctor.disabled ? Colors.green : Colors.red,
                      onPressed: () {
                        _toggleDoctorStatus(doctor);
                      },
                    ),
                    IconButton(
                      icon: Icon(doctor.categoryDisabled ? Icons.visibility_off : Icons.visibility),
                      color: doctor.categoryDisabled ? Colors.red : Colors.green,
                      onPressed: () {
                        _toggleCategoryStatus(doctor);
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildCategoryList() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: const Text('Add Category'),
                    content: TextField(
                      controller: _categoryNameController,
                      decoration: const InputDecoration(labelText: 'Category Name'),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () {
                          if (_categoryNameController.text.isNotEmpty) {
                            _addCategory(_categoryNameController.text);
                            Navigator.of(context).pop();
                            _categoryNameController.clear();
                          }
                        },
                        child: const Text('Add'),
                      ),
                    ],
                  );
                },
              );
            },
            child: const Text('Add Category', style: TextStyle(fontSize: 16)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueAccent,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: _firestore.collection('categories').snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              var categories = snapshot.data!.docs.map((doc) {
                return CategoryModel.fromDocument(doc);
              }).toList();

              return ListView.builder(
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  var category = categories[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    elevation: 6,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      title: Text(category.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                      trailing: IconButton(
                        icon: Icon(category.disabled ? Icons.check_circle : Icons.remove_circle),
                        color: category.disabled ? Colors.green : Colors.red,
                        onPressed: () {
                          if (category.disabled) {
                            _enableCategory(category.categoryId);
                          } else {
                            _disableCategory(category.categoryId);
                          }
                        },
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAdminList() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton(
            onPressed: _addAdmin,
            child: const Text('Add Admin', style: TextStyle(fontSize: 16)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: _firestore.collection('admins').snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              var admins = snapshot.data!.docs.map((doc) {
                return AdminModel.fromDocument(doc);
              }).toList();

              return ListView.builder(
                itemCount: admins.length,
                itemBuilder: (context, index) {
                  var admin = admins[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    elevation: 6,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      title: Text(admin.username, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(admin.email),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

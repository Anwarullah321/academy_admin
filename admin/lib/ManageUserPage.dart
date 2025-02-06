import 'package:admin/constants/colors.dart';
import 'package:admin/providers/AuthProvider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'loginscreen.dart';
import 'main.dart';
import 'mcq_provider.dart';

class ManageUsersPage extends StatefulWidget {
  @override
  _ManageUsersPageState createState() => _ManageUsersPageState();
}

class _ManageUsersPageState extends State<ManageUsersPage> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  List<User> users = [];
  bool _showForm = false;
  bool _passwordVisible = false;
  String _formButtonText = 'Create User';
  User? editingUser;

  @override
  void initState() {
    super.initState();
    fetchUsers();
  }

  void fetchUsers() async {
    DatabaseEvent event = await FirebaseDatabase.instance
        .ref()
        .child('internal_users')
        .orderByChild('userType')
        .equalTo('internal_user')
        .once();

    if (event.snapshot.value != null && event.snapshot.value is Map<dynamic, dynamic>) {
      final Map<dynamic, dynamic> userMap = event.snapshot.value as Map<dynamic, dynamic>;
      List<User> fetchedUsers = [];

      userMap.forEach((key, value) {
        if (value is Map<dynamic, dynamic>) {

          value['uid'] = key;
          fetchedUsers.add(User.fromJson(value));
        }
      });

      setState(() {
        users = fetchedUsers;
      });
    } else {
      setState(() {
        users = [];
      });
    }
  }

  void updateUser(User user) async {
    final newUsername = usernameController.text.trim();
    final newPassword = passwordController.text.trim();

    if (newUsername.isEmpty || newPassword.isEmpty) {
      showMessage('Username and password cannot be empty');
      return;
    }

    try {
      await FirebaseDatabase.instance.ref().child('internal_users/${user.uid}').update({
        'username': newUsername,
        'password': newPassword
      });

      fetchUsers();
      usernameController.clear();
      passwordController.clear();
      setState(() {
        _showForm = false;
        _formButtonText = 'Create User';
        editingUser = null;
      });

      showMessage('User updated successfully');
    } catch (e) {
      showMessage('Error updating user: $e');
    }
  }

  void deleteUser(String uid) async {
    try {
      await FirebaseDatabase.instance.ref().child('internal_users/$uid').remove();
      fetchUsers();
      showMessage('User deleted successfully');
    } catch (e) {
      showMessage('Error deleting user: $e');
    }
  }

  void addUser() async {
    final username = usernameController.text.trim();
    final password = passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      showMessage('Username and password cannot be empty');
      return;
    }

    try {
      await FirebaseDatabase.instance
          .ref()
          .child('internal_users/$username')
          .set({
        'username': username,
        'password': password,
        'userType': 'internal_user',
      });

      fetchUsers();
      usernameController.clear();
      passwordController.clear();
      showMessage('User created successfully');
    } catch (e) {
      showMessage('Error creating user: $e');
    }
  }


  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void toggleFormVisibility([User? user]) {
    setState(() {
      _showForm = !_showForm;
      _formButtonText = _showForm ? 'Cancel' : 'Create User';
      editingUser = user;
      if (editingUser != null) {
        usernameController.text = editingUser!.username;
        passwordController.text = editingUser!.password;
      } else {
        usernameController.clear();
        passwordController.clear();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
      print("[DEBUG] Back button press blocked on Manage Users Page.");
      return false;
    },
    child: Scaffold(
      appBar: AppBar(
        title: Text('Manage Users'),
        backgroundColor: customYellow,
        actions: [
          TextButton.icon(
            icon: Icon(Icons.exit_to_app),
            label: Text('Logout'),
            onPressed: () async {

              Provider.of<AuthManager>(context, listen: false).logout(context);

              context.go('/login');
            },
          ),
        ],

      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () => toggleFormVisibility(),
              child: Text(_formButtonText),
            ),
          ),

          if (_showForm)
            Card(
              margin: EdgeInsets.symmetric(vertical: 10),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(editingUser == null ? 'Create User' : 'Update User', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      SizedBox(height: 10),
                      TextField(
                        controller: usernameController,
                        decoration: InputDecoration(
                          labelText: 'Username',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      SizedBox(height: 10),
                      TextField(
                        controller: passwordController,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          border: OutlineInputBorder(),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _passwordVisible ? Icons.visibility : Icons.visibility_off,
                            ),
                            onPressed: () {
                              setState(() {
                                _passwordVisible = !_passwordVisible;
                              });
                            },
                          ),
                        ),
                        obscureText: !_passwordVisible,
                      ),
                      SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: () {
                          if (editingUser == null) {
                            addUser();
                          } else {
                            updateUser(editingUser!);
                          }
                        },
                        child: Text(editingUser == null ? 'Create User' : 'Update User'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          Expanded(
            child: ListView.builder(
              itemCount: users.length,
              itemBuilder: (context, index) {
                User user = users[index];
                return ListTile(
                  title: Text(user.username),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () {
                          toggleFormVisibility(user);
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () {
                          deleteUser(user.uid);
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    ));
  }
}
class User {
  final String uid;
  final String username;
  final String password;
  final String userType;

  User({
    required this.uid,
    required this.username,
    required this.password,
    required this.userType,
  });

  factory User.fromJson(Map<dynamic, dynamic> json) {
    return User(
      uid: json['uid'] ?? '',
      username: json['username'] ?? '',
      password: json['password'] ?? '',
      userType: json['userType'] ?? 'internal_user',
    );
  }
}
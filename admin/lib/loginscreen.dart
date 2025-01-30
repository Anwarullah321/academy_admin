


import 'package:admin/constants/colors.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'main.dart';

class LoggedInScreen extends StatefulWidget {
  @override
  _LoggedInScreenState createState() => _LoggedInScreenState();
}

class _LoggedInScreenState extends State<LoggedInScreen> {
  final TextEditingController orgController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  String selectedUserType = 'Select User';
  bool _passwordVisible = false;

  static const String INITIAL_ADMIN_ORG_NAME = 'AIMS';
  static const String INITIAL_ADMIN_EMAIL = 'admin';
  static const String INITIAL_ADMIN_PASSWORD = 'admin';

  @override
  void initState() {
    super.initState();
    checkInitialAdminSetup();
  }

  Future<void> checkInitialAdminSetup() async {
    try {
      final databaseReference = FirebaseDatabase.instance.ref();
      final snapshot = await databaseReference.child('admin_credentials').get();

      if (!snapshot.exists) {

        setState(() {});
      }
    } catch (e) {
      print("Error checking admin credentials: $e");
      _showError("Error checking initial setup");
    }
  }



  void _showError(String message) {
    ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Log In'),
        backgroundColor: customYellow,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              decoration: InputDecoration(labelText: 'Org Name'),
              controller: orgController,
            ),
            TextField(
              decoration: InputDecoration(labelText: 'Username'),
              controller: usernameController,
            ),
            TextField(
              decoration: InputDecoration(
                labelText: 'Password',

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
              controller: passwordController,
              obscureText: !_passwordVisible,
            ),
            DropdownButton<String>(
              value: selectedUserType,
              items: [
                DropdownMenuItem<String>(
                  value: 'Select User',
                  child: Text('Select User'),
                ),
                DropdownMenuItem<String>(
                  value: 'admin',
                  child: Text('Admin'),
                ),
                DropdownMenuItem<String>(
                  value: 'internal_user',
                  child: Text('Internal User'),
                ),
              ],
              onChanged: (value) {
                setState(() {
                  selectedUserType = value!;
                });
              },
              hint: Text('Select User'),
            ),
            SizedBox(height: 20),
            Row(

              children: [
                ElevatedButton(
                  onPressed: () async {
                    String org_name = orgController.text.trim();
                    String username = usernameController.text.trim();
                    String password = passwordController.text.trim();


                    if (org_name.isEmpty || username.isEmpty || password.isEmpty) {
                      showError(context, 'Org Name, username and password cannot be empty');
                      return;
                    }

                    if (!org_name.equalsIgnoreCase(INITIAL_ADMIN_ORG_NAME)) {
                      showError(context, 'Invalid Org Name');
                      return;
                    }

                    if (selectedUserType == 'Select User') {
                      showError(context, 'Please select a user type');
                      return;
                    }

                    if (selectedUserType == 'admin') {
                      final databaseReference = FirebaseDatabase.instance.ref();
                      final snapshot = await databaseReference.child('admin_credentials').get();

                      if (!snapshot.exists) {
                        if (org_name.toLowerCase() == INITIAL_ADMIN_ORG_NAME.toLowerCase() &&
                            username == INITIAL_ADMIN_EMAIL &&
                            password == INITIAL_ADMIN_PASSWORD) {

                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => InitialAdminSetupScreen(
                                      INITIAL_ADMIN_ORG_NAME: INITIAL_ADMIN_ORG_NAME,
                                      INITIAL_ADMIN_EMAIL: INITIAL_ADMIN_EMAIL
                                  )
                              )
                          );
                          return;
                        } else {
                          showError(context, 'Invalid initial admin credentials');
                          return;
                        }
                      }

                      // If credentials exist in database, validate against database
                      bool isValidAdmin = await validateAdminCredentials(username, password);
                      if (isValidAdmin) {
                        Navigator.pushReplacementNamed(context, '/manage_users');
                      } else {
                        showError(context, 'Invalid admin credentials');
                      }
                    } else if (selectedUserType == 'internal_user') {
                      bool isValidUser = await validateInternalUser(username, password);
                      if (isValidUser) {
                        Navigator.pushReplacementNamed(context, '/dashboard');
                      } else {
                        showError(context, 'Invalid credentials or user type');
                      }
                    }
                  },
                  child: Text('Login'),
                ),
                SizedBox(width: 10),
                ElevatedButton(onPressed: (){}, child: Text('Forgot Password'))
              ],
            ),

          ],
        ),
      ),
    );
  }

  Future<bool> checkAdminCredentialsExist() async {
    try {
      final databaseReference = FirebaseDatabase.instance.ref();
      final snapshot = await databaseReference.child('admin_credentials').get();
      return snapshot.exists;
    } catch (e) {
      print("Error checking admin credentials existence: $e");
      return false;
    }
  }

  void showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }


  Future<bool> validateAdminCredentials(String username, String password) async {
    try {
      final databaseReference = FirebaseDatabase.instance.ref();
      final snapshot = await databaseReference.child('admin_credentials').get();

      if (snapshot.exists) {
        final adminData = snapshot.value as Map;
        return adminData['email'] == username && adminData['password'] == password;
      }
      return false;
    } catch (e) {
      print("Error validating admin credentials: $e");
      return false;
    }
  }

  Future<bool> validateInternalUser(String username, String password) async {
    try {
      final databaseReference = FirebaseDatabase.instance.ref();
      final snapshot = await databaseReference.child('internal_users').get();

      if (snapshot.exists) {
        final users = snapshot.value as Map;


        for (var userId in users.keys) {
          final user = users[userId];
          if (user['username'] == username && user['password'] == password) {
            return true;
          }
        }
      }
      return false;
    } catch (e) {
      print("Error validating internal user: $e");
      return false;
    }
  }
}

class InitialAdminSetupScreen extends StatefulWidget {
  final bool isInitialSetup;
  final String INITIAL_ADMIN_ORG_NAME;
  final String INITIAL_ADMIN_EMAIL;

  const InitialAdminSetupScreen({ required this.INITIAL_ADMIN_ORG_NAME, required this.INITIAL_ADMIN_EMAIL, Key? key, this.isInitialSetup = false}) : super(key: key);

  @override
  _InitialAdminSetupScreenState createState() => _InitialAdminSetupScreenState();
}

class _InitialAdminSetupScreenState extends State<InitialAdminSetupScreen> {
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  bool _passwordVisible = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isInitialSetup
            ? 'Initial Admin Setup'
            : 'Create New Admin Password'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.isInitialSetup
                  ? 'Set Up Initial Admin Password'
                  : 'Create New Admin Password',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            TextField(
              decoration: InputDecoration(
              labelText: 'Password',

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
              controller: passwordController,
              obscureText: !_passwordVisible,

            ),
            TextField(
              decoration: InputDecoration(
                labelText: 'Confirm Password',

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
              controller: confirmPasswordController,
              obscureText: !_passwordVisible,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                String org_name = widget.INITIAL_ADMIN_ORG_NAME;
                String username = widget.INITIAL_ADMIN_EMAIL;
                String password = passwordController.text.trim();
                String confirmPassword = confirmPasswordController.text.trim();

                if (org_name.isEmpty || username.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
                  _showError('All fields are required');
                  return;
                }

                if (password != confirmPassword) {
                  _showError('Passwords do not match');
                  return;
                }

                if (!org_name.equalsIgnoreCase(widget.INITIAL_ADMIN_ORG_NAME)) {
                  _showError('Invalid Org Name');
                  return;
                }

                // if (!EmailValidator.isValid(email)) {
                //   _showError('Invalid email format');
                //   return;
                // }


                try {
                  final databaseReference = FirebaseDatabase.instance.ref();
                  await databaseReference.child('admin_credentials').set({
                    'orgname': org_name,
                    'username': username,
                    'password': password
                  });


                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => LoggedInScreen())
                  );
                } catch (e) {
                  _showError('Failed to save credentials: $e');
                }
              },
              child: Text(widget.isInitialSetup
                  ? 'Create Admin Account'
                  : 'Create New Password'),
            ),
          ],
        ),
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }


}
extension StringComparison on String {
  bool equalsIgnoreCase(String other) => this.toLowerCase() == other.toLowerCase();
}

// class EmailValidator {
//   static bool isValid(String email) {
//
//     String pattern = r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$";
//     RegExp regex = RegExp(pattern);
//     return regex.hasMatch(email);
//   }
// }
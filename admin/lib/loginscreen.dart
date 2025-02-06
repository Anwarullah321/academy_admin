import 'package:admin/constants/colors.dart';
import 'package:admin/mcq_provider.dart';
import 'package:admin/providers/AuthProvider.dart';
import 'package:admin/providers/MCQProvider.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import 'dart:html' as html;
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
  bool isAuthenticated = false;

  static const String INITIAL_ADMIN_ORG_NAME = 'AIMS';
  static const String INITIAL_ADMIN_USERNAME = 'admin';
  static const String INITIAL_ADMIN_PASSWORD = 'admin';

  @override
  void initState() {
    super.initState();
    checkInitialAdminSetup();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
          return false; // Prevents back navigation
        },
        child: Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
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
                        String orgName = orgController.text.trim();
                        String username = usernameController.text.trim();
                        String password = passwordController.text.trim();

                        print("[DEBUG] Login attempt - OrgName: $orgName, Username: $username, UserType: $selectedUserType");

                        if (orgName.isEmpty || username.isEmpty || password.isEmpty) {
                          showError(context, 'Org Name, username, and password cannot be empty');
                          return;
                        }

                        if (!orgName.equalsIgnoreCase(INITIAL_ADMIN_ORG_NAME)) {
                          showError(context, 'Invalid Org Name');
                          return;
                        }

                        if (selectedUserType == 'Select User') {
                          showError(context, 'Please select a user type');
                          return;
                        }

                        final databaseReference = FirebaseDatabase.instance.ref();

                        if (selectedUserType == 'admin') {
                          final snapshot = await databaseReference.child('admin_credentials').get();

                          if (!snapshot.exists) {
                            if (INITIAL_ADMIN_ORG_NAME.toLowerCase() == INITIAL_ADMIN_ORG_NAME.toLowerCase() &&
                                username == INITIAL_ADMIN_USERNAME &&
                                password == INITIAL_ADMIN_PASSWORD) {
                              html.window.sessionStorage['forceAdminSetup'] = 'true'; // ✅ Store session flag
                              html.window.sessionStorage['username'] = username;
                              setState(() {
                                isAuthenticated = true; // ✅ Ensure state is updated
                              });
                              print("[DEBUG] Hardcoded admin login accepted. Redirecting to Initial Admin Setup");
                              Future.microtask(() {
                                print("[DEBUG] Executing navigation to Initial Admin Setup...");
                                context.go('/initial_admin_setup/AIMS/admin');                              });

                              return;
                            } else {
                              showError(context, 'Invalid initial admin credentials');
                              return;
                            }
                          }

                          if (!snapshot.exists) {
                            showError(context, 'No admin credentials found');
                            return;
                          }

                          bool isValidAdmin = await validateAdminCredentials(username, password);
                          if (isValidAdmin) {
                            await Provider.of<AuthManager>(context, listen: false).login(username, password, context, 'admin');
                            html.window.sessionStorage['username'] = username;

                            html.window.sessionStorage.remove('forceAdminLogin'); // ✅ Remove enforced login flag
                            setState(() {
                              isAuthenticated = true; // ✅ Ensure state is updated
                            });
                            print("[DEBUG] Admin login successful. Redirecting...");
                            Future.microtask(() => context.go('/manage_users'));
                          } else {
                            showError(context, 'Invalid admin credentials');
                          }

                        } else if (selectedUserType == 'internal_user') {
                          bool isValidUser = await validateInternalUser(username, password);
                          if (isValidUser) {
                            html.window.sessionStorage['username'] = username;
                            setState(() {
                              isAuthenticated = true; // ✅ Ensure state is updated
                            });
                            Provider.of<AuthManager>(context, listen: false).login(username, password, context, 'internal_user');
                            context.go('/dashboard');
                          } else {
                            showError(context, 'Invalid credentials or user type');
                          }
                        }
                      },
                      child: Text('Login'),
                    ),
                    SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: () {},
                      child: Text('Forgot Password'),
                    )
                  ],
                ),
              ],
            ),
          ),
        )
    );
  }

  Future<void> checkInitialAdminSetup() async {
    try {
      final databaseReference = FirebaseDatabase.instance.ref();
      final snapshot = await databaseReference.child('admin_credentials').get();

      if (!snapshot.exists) {
        print("[DEBUG] No admin credentials found. Redirecting to InitialAdminSetupScreen...");
        if (mounted) {
          Future.delayed(Duration.zero, () {
            context.go('/initial_admin_setup');
          });
        }
      }
    } catch (e) {
      print("Error checking admin credentials: $e");
      showError(context, "Error checking initial setup");
    }
  }

  Future<bool> validateAdminCredentials(String username, String password) async {
    try {
      final databaseReference = FirebaseDatabase.instance.ref();
      final snapshot = await databaseReference.child('admin_credentials').get();

      if (!snapshot.exists) {
        // ✅ Allow hardcoded login if no admin credentials are stored
        return username == "admin" && password == "admin";
      }

      final adminData = snapshot.value as Map;
      return adminData['username'] == username && adminData['password'] == password;
    } catch (e) {
      print("Error validating admin credentials: $e");
      return false;
    }
  }


  Future<bool> validateInternalUser(String username, String password) async {
    try {
      final databaseReference = FirebaseDatabase.instance.ref();
      final snapshot = await databaseReference.child('internal_users/$username').get();

      if (snapshot.exists) {
        final user = snapshot.value as Map;
        return user['password'] == password;
      }
      return false;
    } catch (e) {
      print("Error validating internal user: $e");
      return false;
    }
  }

  void showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }
}

extension StringComparison on String {
  bool equalsIgnoreCase(String other) => this.toLowerCase() == other.toLowerCase();
}


class InitialAdminSetupScreen extends StatefulWidget {
  final bool isInitialSetup;
  final String INITIAL_ADMIN_ORG_NAME;
  final String INITIAL_ADMIN_USERNAME;

  const InitialAdminSetupScreen(
      {required this.INITIAL_ADMIN_ORG_NAME,
      required this.INITIAL_ADMIN_USERNAME,
      Key? key,
      this.isInitialSetup = false})
      : super(key: key);

  @override
  _InitialAdminSetupScreenState createState() =>
      _InitialAdminSetupScreenState();
}

class _InitialAdminSetupScreenState extends State<InitialAdminSetupScreen> {
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  bool _passwordVisible = false;



  @override
  void initState() {
    super.initState();

    // ✅ Listen for browser back button press
    html.window.onPopState.listen((event) {
      if (ModalRoute.of(context)?.settings.name == '/initial_admin_setup') {
        print("[DEBUG] Back button detected on Initial Admin Setup. Clearing session...");

        // ✅ Clear session storage on back navigation
        html.window.sessionStorage.clear();

        // ✅ Redirect user to login page
        Future.microtask(() => GoRouter.of(context).go('/login'));
      }
    });

    // ✅ Replace history entry so user cannot go back again
    Future.delayed(Duration.zero, () {
      html.window.history.replaceState(null, '', '/initial_admin_setup');
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
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
                    _passwordVisible
                        ? Icons.visibility
                        : Icons.visibility_off,
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
                    _passwordVisible
                        ? Icons.visibility
                        : Icons.visibility_off,
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
                String username = widget.INITIAL_ADMIN_USERNAME;
                String password = passwordController.text.trim();
                String confirmPassword =
                    confirmPasswordController.text.trim();

                if (org_name.isEmpty ||
                    username.isEmpty ||
                    password.isEmpty ||
                    confirmPassword.isEmpty) {
                  _showError('All fields are required');
                  return;
                }

                if (password != confirmPassword) {
                  _showError('Passwords do not match');
                  return;
                }

                if (!org_name
                    .equalsIgnoreCase(widget.INITIAL_ADMIN_ORG_NAME)) {
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
                  // ✅ Clear session storage to force re-login
                  html.window.sessionStorage.clear();

                  // ✅ Replace browser history so back button doesn't work
                  html.window.history.pushState(null, '', '/login');
                  html.window.history.replaceState(null, '', '/login');

                  GoRouter.of(context).go('/login');
                  html.window.history.pushState(null, '', '/login');

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



// class EmailValidator {
//   static bool isValid(String email) {
//
//     String pattern = r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$";
//     RegExp regex = RegExp(pattern);
//     return regex.hasMatch(email);
//   }
// }

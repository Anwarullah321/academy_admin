import 'dart:html' as html;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';


class AuthManager  with ChangeNotifier {
  final DatabaseReference _databaseReference = FirebaseDatabase.instance.ref();
  bool isAuthenticated = false;
  String username = "";
  bool forceAdminSetup = false;



  AuthProvider() {
    loadAuthState();
  }


  void loadAuthState() async {
    if (kIsWeb) {
      String? storedUsername = html.window.sessionStorage['username'];

      final snapshot = await _databaseReference.child('admin_credentials').get();

      if (storedUsername != null && snapshot.exists) {
        isAuthenticated = true;
        username = storedUsername;
        notifyListeners();
        print("[DEBUG] Loaded session: User authenticated as $username");
      } else {
        print("[DEBUG] No valid session found. User needs to log in.");
        isAuthenticated = false;
        html.window.sessionStorage.remove('username');
        notifyListeners();
      }
    }
  }


  Future<void> login(String enteredUsername, String enteredPassword, BuildContext context, String userType) async {
    try {
      print("[DEBUG] Login attempt: Username: $enteredUsername, UserType: $userType");
      final adminSnapshot = await _databaseReference.child('admin_credentials').get();
      bool isAdmin = false;
      String? storedPassword;

      if (adminSnapshot.exists) {
        final adminData = Map<String, dynamic>.from(adminSnapshot.value as Map);
        if (adminData['username'] == enteredUsername) {
          storedPassword = adminData['password'];
          isAdmin = true;
        }
      }

      // ✅ If no admin exists in the database, only allow the hardcoded login for initial setup
      if (!adminSnapshot.exists && enteredUsername == 'admin' && enteredPassword == 'admin') {
        print("[DEBUG] No admin credentials found. Redirecting to Initial Admin Setup.");
        html.window.sessionStorage['forceAdminSetup'] = 'true'; // ✅ Store a flag for setup
        Future.microtask(() => context.go('/initial_admin_setup/AIMS/admin'));
        return;
      }


      if (storedPassword == null || storedPassword != enteredPassword) {
        print("[DEBUG] Invalid credentials for $enteredUsername.");
        throw Exception("Invalid username or password");
      }
      print("[DEBUG] User authenticated: $enteredUsername");
      html.window.sessionStorage['username'] = enteredUsername;
      html.window.sessionStorage.remove('forceAdminSetup');
      isAuthenticated = true;
      forceAdminSetup = false;
      username = enteredUsername;
      notifyListeners();
      Future.microtask(() {
        if (isAdmin) {
          print("[DEBUG] Admin login successful. Redirecting to /manage_users");
          context.go('/manage_users');
        } else {
          print("[DEBUG] Internal user login successful. Redirecting to /dashboard");
          context.go('/dashboard');
        }
      });
    } catch (e) {
      print("[DEBUG] Login error: $e");
      throw e;
    }
  }
  Future<void> logout(BuildContext context) async {
    if (kIsWeb) {
      print("[DEBUG] Clearing sessionStorage...");
      html.window.sessionStorage.clear();
    }

    isAuthenticated = false;
    username = "";
    notifyListeners();

    print("[DEBUG] User logged out.");
    GoRouter.of(context).go('/login');
  }



  AuthNotifier() {
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      print("[DEBUG] Auth state changed. User: ${user?.email ?? 'Logged out'}");

      notifyListeners();
    });
  }
}

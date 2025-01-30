import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:academyapp/utils/decrytion_service.dart';
import 'package:academyapp/utils/firestore_service.dart';
import 'package:academyapp/utils/nexasoft_license_generator.dart';

import 'package:academyapp/whatsapp.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:academyapp/services/mcq_services.dart';
import 'SpashScreen.dart';
import 'academic/subject_screen.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'academic_local/local_subject.dart';
import 'etea/etea_subject_page.dart';
import 'etea/etealocal/etea_local_sujbects.dart';
import 'homepage.dart';




Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  try {
    final mcqService = MCQService();
    await mcqService.checkAndHandleLicenseExpiry();

    runApp(MyApp(mcqService: mcqService));
  } catch (e, stackTrace) {
    print("Error during initialization: $e");
    print("Stack trace: $stackTrace");
  }
}

class MyApp extends StatefulWidget {
  final MCQService mcqService;

  const MyApp({Key? key, required this.mcqService}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AIMS Academy App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.white,
      ),
      home: SplashHandler(mcqService: widget.mcqService),
    );
  }
}

class SplashHandler extends StatefulWidget {
  final MCQService mcqService;

  const SplashHandler({Key? key, required this.mcqService}) : super(key: key);

  @override
  State<SplashHandler> createState() => _SplashHandlerState();
}

class _SplashHandlerState extends State<SplashHandler> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => HomePage(),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return const SplashScreen();
  }
}





import 'dart:convert';
import 'dart:io';

import 'package:admin/screens/add_screens/subjectwise_past_papers.dart';


import 'package:admin/screens/add_yaml_data/etea/eteatexttoyamluploadscreen.dart';
import 'package:admin/screens/add_yaml_data/texttoyamluploadscreen.dart';

import 'package:admin/screens/options_screen/internaluser_Dashboard.dart';
import 'package:admin/services/decryption_service.dart';
import 'package:admin/services/get_service.dart';
import 'package:admin/splash_page.dart';
import 'package:admin/widgets/decrypt_verify.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:path_provider/path_provider.dart';
import 'package:universal_html/js.dart';
import 'package:yaml/yaml.dart';
import 'ManageUserPage.dart';
import 'chapterwise_test/selectclasspage.dart';

import 'package:yaml/yaml.dart';
import 'package:yaml/yaml.dart' as yaml;
import 'dart:html' as html;

import 'package:flutter/foundation.dart' show kIsWeb;

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import 'export_data/export_class_data.dart';
import 'export_data/export_etea_data.dart';
import 'loginscreen.dart';
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    // Firebase options for the web and mobile
    final firebaseOptions = FirebaseOptions(
        apiKey: "AIzaSyDUkF2QUEZh9F09ZZfyrMkbnyzwDJF53VA",
        authDomain: "academy-app-realtimedatabase.firebaseapp.com",
        databaseURL: "https://academy-app-realtimedatabase-default-rtdb.firebaseio.com",
        projectId: "academy-app-realtimedatabase",
        storageBucket: "academy-app-realtimedatabase.appspot.com",
        messagingSenderId: "785375733186",
        appId: "1:785375733186:web:f30a2b782077349e9c625b",
        measurementId: "G-2KJ6ZJKJ87"
    );
    await Firebase.initializeApp(options: firebaseOptions);

    // Initialize Realtime Database
    if (!kIsWeb) {
      // Mobile-specific initialization
      FirebaseDatabase.instance.setPersistenceEnabled(true);
      FirebaseDatabase.instance.setPersistenceCacheSizeBytes(10000000); // 10MB
    }

    // Set database URL for both web and mobile
    FirebaseDatabase.instance.databaseURL = "https://academy-app-realtimedatabase-default-rtdb.firebaseio.com";

    print("Firebase initialized successfully");
  } catch (e) {
    print("Failed to initialize Firebase: $e");
  }
  final String encryptedAesKey = "pJLfgOMn7pGzQK1LzGxjqdYQdDolj3V4rzBBkEhnSho1KHYG+vc0VfKhe4LBAmMtUb/67fUv+H8eezey6EZiitfgFUi6G6c4ZWYQlYUJRqQqRQorQw6CGuExzU568CZr1R6Oqa8BYp01K+u1Vz0dHNcjZ+Lt7s7/qHj4jeTe8ZTKyHyItCM888BCv8fIQR3vp3nA2AqwhfS/G+/CRtPNF/wl/He7DSulk89qAU0DMOHTop9c0xE9z4w7UaieEwjt4z/wvkczOrLzPNDkiKYKF10x8Opa5AUVYoAaWAclgbI7n4T2DSaCT7V4tM77an8tB9M+UfcoGcRcj2yR52vs/Q==";
  String encRsaPrivateKeyForAesEncryption = '''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''';
   String encRsaPublicForAesEncryption = '''qHAelRZEJiwbB1WzvRcNP82+3D/SIiF4kmm0l86LZs422p0/QSc18wSs05Qh09qm5fq0s/ck71PZha3wetLn+FRKp2OlvK1NdMoz/Ez4OLikIqFlpiPxiins80vvSpldxSb6jJfjGoXitAd0YbuP3j4Hp58oc0VG/kxGr7IMJ7DHzRAHw3Vw5bBBd9syIrEKHaTakqlWAN3YAAGZ8pWNAAKZaVLCM4jSw7WAqpuvegpfCZ/AEmDVz/OABuPaOVRwGqobxxsBhSm5+LfFjDGwOxzMr8dljaKyfZq9JwbQ2bkM4WzFVKQG6fooJLucSS14Ryg2oTfv3kBOXdzFTZBP1bz3wYAJagyJOA9cLJLEErasZJ4HaajwkCM3IbdneprocUqi5c5PXCug/17hUW9K4ZAyOCBfn8b0yHxWVVhhczTZiUbtJ9OEVKArCVNGucTK2mAcFjdXci0DFy1xmMHV0kiQHqvBEfabXvohXM5Y7PHXdnCbc2FmREfi+mLUt3tvrvq73OkY9rXs8B1I2v3mjlbNr1ugeSdOPxDpbChnHMLcUZgNcZ0YzjZGDW13q/yAN8FN13EeufPzKyE8dCqTr+wXrUtKv+oHYNdi6acHP2RtR+vhi0/mgJliydQ54g==''';

  await KeyDecryptionService.decryptKey(
      encryptedAesKey,
      encRsaPrivateKeyForAesEncryption
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'AIMS Academy',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      routes: {
        '/spashPage': (context) => SplashPage(),
        '/': (context) => LoggedInScreen(),
        '/dashboard': (context) => Dashboard(),
        '/manage_users': (context) => ManageUsersPage(),
            // HomePage(),
        // '/add-mcq': (context) => AddMCQPage(),
        // '/add-question': (context) => AddQuestionPage(),
        // '/manage-mcq': (context) => SelectClassPage(),
        // '/add_mcq': (context) => AddFirsthalfMcqs(),

      },
    );
  }
}

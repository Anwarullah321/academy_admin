import 'dart:convert';
import 'dart:io';

import 'package:admin/providers/ChapterProvider.dart';
import 'package:admin/providers/ClassProvider.dart';
import 'package:admin/providers/MCQProvider.dart';
import 'package:admin/providers/QuestionProvider.dart';
import 'package:admin/providers/SubjectProvider.dart';
import 'package:admin/providers/etea/EteaChapterProvider.dart';
import 'package:admin/providers/etea/EteaSubjectProvider.dart';
import 'package:admin/screens/add_screens/subjectwise_past_papers.dart';

import 'package:admin/screens/add_yaml_data/etea/eteatexttoyamluploadscreen.dart';
import 'package:admin/screens/add_yaml_data/texttoyamluploadscreen.dart';
import 'package:admin/screens/edit_screens/etea_edit/etea_edit_chapterwise.dart';
import 'package:admin/screens/options_screen/ManageDataPage.dart';
import 'package:admin/screens/options_screen/etea_manage_options.dart';

import 'package:admin/screens/options_screen/internaluser_Dashboard.dart';
import 'package:admin/screens/view_screens/etea_view/etea_view_chapterwise.dart';
import 'package:admin/services/decryption_service.dart';
import 'package:admin/services/get_service.dart';
import 'package:admin/splash_page.dart';
import 'package:admin/widgets/decrypt_verify.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:universal_html/js.dart';
import 'package:yaml/yaml.dart';
import 'ManageUserPage.dart';
import 'Mcq_manager.dart';
import 'auth_state.dart';
import 'chapterwise_test/chapter_detail_page.dart';
import 'chapterwise_test/chapter_page.dart';
import 'chapterwise_test/select_subjectpage.dart';
import 'chapterwise_test/selectclasspage.dart';

import 'package:yaml/yaml.dart';
import 'package:yaml/yaml.dart' as yaml;
import 'dart:html' as html;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'providers/AuthProvider.dart';

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import 'eteachapterwise_test/etea_chapter_page.dart';
import 'eteachapterwise_test/etea_detail_page.dart';
import 'eteachapterwise_test/etea_subject_page.dart';
import 'export_data/export_class_data.dart';
import 'export_data/export_data_page.dart';
import 'export_data/export_etea_data.dart';
import 'loginscreen.dart';
import 'mcq_provider.dart';
import 'models/mcq_model.dart';
import 'models/question_model.dart';
import 'screens/edit_screens/editmcq_page.dart';
import 'screens/edit_screens/editquestion_page.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Firebase options for the web and mobile
    final firebaseOptions = FirebaseOptions(
        apiKey: "AIzaSyDUkF2QUEZh9F09ZZfyrMkbnyzwDJF53VA",
        authDomain: "academy-app-realtimedatabase.firebaseapp.com",
        databaseURL:
            "https://academy-app-realtimedatabase-default-rtdb.firebaseio.com",
        projectId: "academy-app-realtimedatabase",
        storageBucket: "academy-app-realtimedatabase.appspot.com",
        messagingSenderId: "785375733186",
        appId: "1:785375733186:web:f30a2b782077349e9c625b",
        measurementId: "G-2KJ6ZJKJ87");
    await Firebase.initializeApp(options: firebaseOptions);

    // Initialize Realtime Database
    if (!kIsWeb) {
      // Mobile-specific initialization
      FirebaseDatabase.instance.setPersistenceEnabled(true);
      FirebaseDatabase.instance.setPersistenceCacheSizeBytes(10000000); // 10MB
    }

    // Set database URL for both web and mobile
    FirebaseDatabase.instance.databaseURL =
        "https://academy-app-realtimedatabase-default-rtdb.firebaseio.com";

    print("Firebase initialized successfully");
  } catch (e) {
    print("Failed to initialize Firebase: $e");
  }

  DecrytionService.initializeDecryption();


  runApp(
    MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (context) => AuthManager ()),
          ChangeNotifierProvider(create: (context) => ClassProvider()),
          ChangeNotifierProvider(create: (context) => SubjectProvider()),
          ChangeNotifierProvider(create: (context) => ChapterProvider()),
          ChangeNotifierProvider(create: (context) => EteaSubjectProvider()),
          ChangeNotifierProvider(create: (context) => EteaChapterProvider()),
          ChangeNotifierProvider(create: (context) => QuestionProvider()),
          ChangeNotifierProvider(create: (context) => MCQProvider())
    ],
      child: MyApp(),

  ),
  );
}

class MyApp extends StatelessWidget {
  final GoRouter _router = GoRouter(

    redirect: (BuildContext context, GoRouterState state) async {
      final databaseReference = FirebaseDatabase.instance.ref();
      final String? username = html.window.sessionStorage['username'];
      final bool isAuthenticated = username != null;
      final bool isAdmin = username == 'admin';
      final bool isInternalUser = username != null && username != 'admin';
      final bool isHardcodedAdmin = html.window.sessionStorage['forceAdminSetup'] == 'true';

      try {
        final snapshot = await databaseReference.child('admin_credentials').get();

        print("[DEBUG] Checking Authentication: $isAuthenticated");
        print("[DEBUG] Admin Credentials Exist: ${snapshot.exists}");
        print("[DEBUG] Current Page: ${state.matchedLocation}");

        // ✅ If hardcoded admin is used, force them to complete setup and go to login
        if (isHardcodedAdmin) {
          print("[DEBUG] Hardcoded admin detected. Enforcing Initial Admin Setup.");
          return '/initial_admin_setup/AIMS/admin';
        }


        // ✅ If admin just completed setup, force them to login
        if (!isAuthenticated) {
          return '/login';
        }

        // ✅ Prevent navigation back to login after logging in with database credentials
        if (isAuthenticated && state.matchedLocation == '/login') {
          return isAdmin ? '/manage_users' : '/dashboard';
        }

        // ✅ Allow Initial Setup if no admin credentials exist
        if (isAuthenticated && !snapshot.exists && state.matchedLocation.startsWith('/initial_admin_setup')) {
          return null;
        }

        return null; // ✅ Allow normal navigation
      } catch (e) {
        print("[DEBUG] Router Redirect Error: $e");
        return '/login';
      }
    },




routes: [
      GoRoute(path: '/', builder: (context, state) => SplashPage()),
      GoRoute(
          path: '/login',
          name: 'login',
          builder: (context, state) => LoggedInScreen()),
      GoRoute(
        path: '/initial_admin_setup/:orgName/:username',
        name: 'initial_admin_setup',
        builder: (context, state) => InitialAdminSetupScreen(
          INITIAL_ADMIN_ORG_NAME: state.pathParameters['orgName']!,
          INITIAL_ADMIN_USERNAME: state.pathParameters['username']!,
        ),
      ),
      GoRoute(
        path: '/initial_admin_setup',
        redirect: (context, state) => '/initial_admin_setup',
      ),
      GoRoute(path: '/dashboard', builder: (context, state) => Dashboard()),
      GoRoute(
          path: '/manage_users',
          builder: (context, state) => ManageUsersPage()),
      GoRoute(path: '/upload', builder: (context, state) => UploadDataPage()),
      GoRoute(
          path: '/upload/academic',
          builder: (context, state) => TextToYamlUploadScreen()),
      GoRoute(
          path: '/upload/etea',
          builder: (context, state) => EteaTextToYamlUploadScreen()),
      GoRoute(path: '/manage', builder: (context, state) => ManageDataPage()),
      GoRoute(
          path: '/etea/manage',
          builder: (context, state) => EteaManageOptionsDialog()),
      GoRoute(
          path: '/etea/selecteatesubjectpage',
          builder: (context, state) => SelectEteaSubjectPage()),
      GoRoute(path: '/export', builder: (context, state) => ExportDataPage()),
      GoRoute(
          path: '/export/academic',
          builder: (context, state) => ExportClassesScreen()),
      GoRoute(
          path: '/export/etea',
          builder: (context, state) => ExportEteaScreen()),
      GoRoute(
          path: '/chapterwise_test',
          builder: (context, state) => SelectClassPage()),
      GoRoute(
        path: '/verify',
        builder: (context, state) {
          return const DecryptVerify();
        },
      ),


      GoRoute(
          path: '/selecteatesubjectpage/:selectedSubject',
          builder: (context, state) {
            final selectedSubject = state.pathParameters['selectedSubject']!;
            return SelectEteaChapterPage(selectedSubject: selectedSubject);
          }),
      GoRoute(
          path: '/eteachapter_detail/:selectedSubject/:selectedChapter',
          builder: (context, state) {
            final selectedSubject = state.pathParameters['selectedSubject']!;
            final selectedChapter = state.pathParameters['selectedChapter']!;
            return EteaChapterDetailPage(
              selectedSubject: selectedSubject,
              selectedChapter: selectedChapter,
            );
          }),
      GoRoute(
        path: '/select_subject/:selectedClass',
        builder: (context, state) {
          final selectedClass = state.pathParameters['selectedClass']!;
          return SelectMainSubjectPage(selectedClass: selectedClass);
        },
      ),
      GoRoute(
        path: '/select_chapter/:selectedClass/:selectedSubject',
        builder: (context, state) {
          final selectedClass = state.pathParameters['selectedClass']!;
          final selectedSubject = state.pathParameters['selectedSubject']!;
          return SelectChapterPage(
            selectedClass: selectedClass,
            selectedSubject: selectedSubject,
          );
        },
      ),
      GoRoute(
        path:
            '/chapter_detail/:selectedClass/:selectedSubject/:selectedChapter/:initialIndex',
        builder: (context, state) {
          final selectedClass = state.pathParameters['selectedClass']!;
          final selectedSubject = state.pathParameters['selectedSubject']!;
          final selectedChapter = state.pathParameters['selectedChapter']!;
          final initialIndex =
              int.tryParse(state.pathParameters['initialIndex'] ?? '0') ?? 0;

          return ChapterDetailPage(
            selectedClass: selectedClass,
            selectedSubject: selectedSubject,
            selectedChapter: selectedChapter,
            initialIndex: initialIndex,
          );
        },
      ),

      GoRoute(
        path: '/edit_mcq/:selectedClass/:selectedSubject/:selectedChapter/:mcqId',
        builder: (context, state) {
          final selectedClass = state.pathParameters['selectedClass']!;
          final selectedSubject = state.pathParameters['selectedSubject']!;
          final selectedChapter = state.pathParameters['selectedChapter']!;
          final mcqId = state.pathParameters['mcqId']!;

          final mcqProvider = Provider.of<MCQProvider>(context, listen: false);


          final mcq = mcqProvider.mcqs.firstWhere(
                (mcq) => mcq.id == mcqId,
            orElse: () {
              print("MCQ with ID $mcqId not found!");
              return MCQ(id: '', question: '', options: [], correctOption: -1, year: -1);
            },
          );

          if (mcq.id.isEmpty) {
            return Scaffold(
              body: Center(child: Text('MCQ Not Found! ID: $mcqId')),
            );
          }

          return EditMCQPage(
            cls: selectedClass,
            subject: selectedSubject,
            chapter: selectedChapter,
            mcq: mcq,
          );
        },
      ),


      GoRoute(
        path:
            '/edit_question/:selectedClass/:selectedSubject/:selectedChapter/:questionId',
        builder: (context, state) {
          final selectedClass = state.pathParameters['selectedClass']!;
          final selectedSubject = state.pathParameters['selectedSubject']!;
          final selectedChapter = state.pathParameters['selectedChapter']!;
          final questionId = state.pathParameters['questionId']!;

          final questionProvider = Provider.of<QuestionProvider>(context, listen: false);


          final question = questionProvider.questions.firstWhere(
                (question) => question.id == questionId,
            orElse: () {
              print("Question with ID $questionId not found!");
              return Question(id: '', question: '', year: -1);
            },
          );

          if (question.id.isEmpty) {
            return Scaffold(
              body: Center(child: Text('Question Not Found! ID: $questionId')),
            );
          }

          return EditQuestionPage(
            selectedClass: selectedClass,
            selectedSubject: selectedSubject,
            selectedChapter: selectedChapter,
            question: question,
          );
        },
      ),

      GoRoute(
        path: '/edit_eteamcq/:selectedSubject/:selectedChapter/:mcqId',
        builder: (context, state) {
          final selectedSubject = state.pathParameters['selectedSubject']!;
          final selectedChapter = state.pathParameters['selectedChapter']!;
          final mcqId = state.pathParameters['mcqId']!;
          final mcqProvider = Provider.of<MCQProvider>(context, listen: false);


          final mcq = mcqProvider.mcqs.firstWhere(
                (mcq) => mcq.id == mcqId,
            orElse: () {
              print("MCQ with ID $mcqId not found!");
              return MCQ(id: '', question: '', options: [], correctOption: -1, year: -1);
            },
          );

          if (mcq.id.isEmpty) {
            return Scaffold(
              body: Center(child: Text('MCQ Not Found! ID: $mcqId')),
            );
          }

          return EditEteaMCQPage(
            subject: selectedSubject,
            chapter: selectedChapter,
            mcq: mcq,
          );
        },
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: _router,
      debugShowCheckedModeBanner: false,
      title: 'AIMS Academy',
      theme: ThemeData(primarySwatch: Colors.blue),
    );
  }
}

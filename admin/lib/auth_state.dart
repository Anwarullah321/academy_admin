// import 'package:admin/screens/view_screens/view_mcqs.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:go_router/go_router.dart';
// import '../services/get_service.dart';
// import '../services/update_service.dart';
// import '../services/delete_service.dart';
// import '../models/mcq_model.dart';
// import 'models/question_model.dart';
// import 'models/year_options.dart';
//
// class MQProvider with ChangeNotifier {
//   final GetService _getService = GetService();
//   final UpdateService _updateService = UpdateService();
//   final DeleteService _deleteService = DeleteService();
//
//   List<MCQ> _mcqs = [];
//   MCQ? _selectedMCQ;
//   List<Question> _questions = [];
//   Question? _selectedQuestion;
//
//   bool _isLoading = false;
//   YearOption? _selectedYear;
//   List<YearOption> _uniqueYears = [];
//   bool _isDeleting = false;
//   bool get isDeleting => _isDeleting;
//
//
//
//
//
//
//
//   List<MCQ> get mcqs => _selectedYear?.year == null
//       ? _mcqs
//       : _mcqs.where((mcq) => mcq.year == _selectedYear?.year).toList();
//   MCQ? get selectedMCQ => _selectedMCQ;
//   bool get isLoading => _isLoading;
//   YearOption? get selectedYear => _selectedYear;
//   List<YearOption> get uniqueYears => _uniqueYears;
//
//   List<Question> get questions => _selectedYear?.year == null
//       ? _questions
//       : _questions.where((q) => q.year == _selectedYear?.year).toList();
//
//   Question? get selectedQuestion => _selectedQuestion;
//   bool get isQuestionLoading => _isLoading;
//   YearOption? get eteaselectedYear => _selectedYear;
//   List<YearOption> get eteauniqueYears => _uniqueYears;
//
//   Future<void> loadMCQs(String className, String subject, String chapter) async {
//     _isLoading = true;
//     notifyListeners();
//
//     _mcqs = await _getService.getChapterwiseMCQs(className, subject, chapter);
//     _isLoading = false;
//     _generateUniqueYears();
//     notifyListeners();
//   }
//
//   Future<void> loadEteaMCQs(String subject, String chapter) async {
//     _isLoading = true;
//     notifyListeners();
//
//     _mcqs = await _getService.getEteaChapterwiseMCQs(subject, chapter);
//     _isLoading = false;
//     _generateUniqueYears();
//     notifyListeners();
//   }
//
//   Future<void> loadQuestions(String className, String subject, String chapter) async {
//     _isLoading = true;
//     notifyListeners();
//
//     _questions = await _getService.getChapterwiseQuestions(className, subject, chapter);
//     _isLoading = false;
//     _generatequestionUniqueYears();
//     notifyListeners();
//   }
//
//   void _generatequestionUniqueYears() {
//     Set<int> uniqueYearValues = _questions.map((q) => q.year).toSet();
//     _uniqueYears = [
//       YearOption(null),
//       ...uniqueYearValues.map((year) => YearOption(year)).toList()
//         ..sort((a, b) => a.year!.compareTo(b.year!)),
//     ];
//   }
//
//   void _generateUniqueYears() {
//     Set<int> uniqueYearValues = _mcqs.map((mcq) => mcq.year).toSet();
//     _uniqueYears = [
//       YearOption(null),
//       ...uniqueYearValues.map((year) => YearOption(year)).toList()
//         ..sort((a, b) => a.year!.compareTo(b.year!)),
//     ];
//   }
//
//
//   void selectQuestion(Question question) {
//     try {
//       _selectedQuestion = _questions.firstWhere((q) => q.id == question.id);
//       print("Selected Question: ${_selectedQuestion?.question}");
//     } catch (e) {
//       _selectedQuestion = null;
//     }
//     notifyListeners();
//   }
//
//   void selectMCQ(MCQ mcq) {
//     try {
//       _selectedMCQ = _mcqs.firstWhere((m) => m.id == mcq.id);
//     } catch (e) {
//       _selectedMCQ = null;
//     }
//     notifyListeners();
//   }
//
//   void filterQuestions(YearOption? yearOption) {
//     _selectedYear = yearOption;
//     notifyListeners();
//   }
//
//   void filterMCQs(YearOption? yearOption) {
//     _selectedYear = yearOption;
//     notifyListeners();
//   }
//
//   Future<void> updateQuestion(String className, String subject, String chapter, Question updatedQuestion) async {
//     try {
//       await _updateService.updateChapterwiseQuestion(className, subject, chapter, updatedQuestion);
//
//       int index = _questions.indexWhere((q) => q.id == updatedQuestion.id);
//       if (index != -1) {
//         _questions[index] = updatedQuestion;
//         notifyListeners();
//       }
//     } catch (e) {
//       print("Error updating Question: $e");
//       throw e;
//     }
//   }
//
//
//
//
//   Future<void> updateMCQ(String className, String subject, String chapter, MCQ updatedMCQ) async {
//     try {
//       await _updateService.updateChapterwiseMCQ(className, subject, chapter, updatedMCQ.id, updatedMCQ);
//
//       int index = _mcqs.indexWhere((mcq) => mcq.id == updatedMCQ.id);
//
//       if (index != -1) {
//         _mcqs[index] = updatedMCQ;
//         notifyListeners();
//
//       }
//     } catch (e) {
//       print("Error updating MCQ: $e");
//       throw e;
//     }
//   }
//
//   Future<void> updateEteaMCQ(String subject, String chapter, MCQ updatedMCQ) async {
//     try {
//       await _updateService.updateEteaChapterwiseMCQ(subject, chapter, updatedMCQ.id, updatedMCQ);
//
//       int index = _mcqs.indexWhere((mcq) => mcq.id == updatedMCQ.id);
//
//       if (index != -1) {
//         _mcqs[index] = updatedMCQ;
//         notifyListeners();
//
//       }
//     } catch (e) {
//       print("Error updating MCQ: $e");
//       throw e;
//     }
//   }
//
//   Future<void> deleteQuestion(String className, String subject, String chapter, String questionId) async {
//     await _deleteService.deleteChapterwiseQuestion(className, subject, chapter, questionId);
//     _questions.removeWhere((q) => q.id == questionId);
//     _isDeleting = false;
//     notifyListeners();
//   }
//
//   Future<void> deleteQuestionsByYear(String className, String subject, String chapter, int year) async {
//     await _deleteService.deleteQuestionsByYear(className, subject, chapter, year);
//     _questions.removeWhere((q) => q.id == year);
//     _isDeleting = false;
//     _generatequestionUniqueYears();
//     notifyListeners();
//   }
//
//   Future<void> deleteMCQsByYear(String className, String subject, String chapter, int year) async {
//     _mcqs.removeWhere((mcq) => mcq.year == year);
//     await _deleteService.deleteMCQsByYear(className, subject, chapter, year);
//     _generateUniqueYears();
//     notifyListeners();
//   }
//
//   Future<void> deleteEteaMCQsByYear(String subject, String chapter, int year) async {
//     _mcqs.removeWhere((mcq) => mcq.year == year);
//     await _deleteService.deleteEteaMCQsByYear(subject, chapter, year);
//     _generateUniqueYears();
//     notifyListeners();
//   }
//
//   Future<void> deleteMCQ(String selectedClass, String selectedSubject, String selectedChapter, String mcqId) async {
//     await _deleteService.deleteChpaterwiseMCQ(selectedClass, selectedSubject, selectedChapter, mcqId);
//     _mcqs.removeWhere((mcq) => mcq.id == mcqId);
//     _isDeleting = false;
//     notifyListeners();
//   }
//
//   Future<void> deleteEteaMCQ(String selectedSubject, String selectedChapter, String mcqId) async {
//     await _deleteService.deleteEteaChapterwiseMCQ(selectedSubject, selectedChapter, mcqId);
//     _mcqs.removeWhere((mcq) => mcq.id == mcqId);
//     _isDeleting = false;
//     notifyListeners();
//   }
//
// }
//
//
//
//
// import 'package:admin/constants/colors.dart';
// import 'package:firebase_database/firebase_database.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';
//
// import 'main.dart';
//
// class LoggedInScreen extends StatefulWidget {
//   @override
//   _LoggedInScreenState createState() => _LoggedInScreenState();
// }
//
// class _LoggedInScreenState extends State<LoggedInScreen> {
//   final TextEditingController orgController = TextEditingController();
//   final TextEditingController usernameController = TextEditingController();
//   final TextEditingController passwordController = TextEditingController();
//   String selectedUserType = 'Select User';
//   bool _passwordVisible = false;
//
//   static const String INITIAL_ADMIN_ORG_NAME = 'AIMS';
//   static const String INITIAL_ADMIN_EMAIL = 'admin';
//   static const String INITIAL_ADMIN_PASSWORD = 'admin';
//
//   @override
//   void initState() {
//     super.initState();
//     checkInitialAdminSetup();
//   }
//
//   Future<void> checkInitialAdminSetup() async {
//     try {
//       final databaseReference = FirebaseDatabase.instance.ref();
//       final snapshot = await databaseReference.child('admin_credentials').get();
//
//       if (!snapshot.exists) {
//
//         setState(() {});
//       }
//     } catch (e) {
//       print("Error checking admin credentials: $e");
//       _showError("Error checking initial setup");
//     }
//   }
//
//
//
//   void _showError(String message) {
//     ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(
//       SnackBar(content: Text(message)),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return WillPopScope(
//         onWillPop: () async {
//           return false; // Prevents the user from going back
//         },
//         child: Scaffold(
//           appBar: AppBar(
//             automaticallyImplyLeading: false,
//             title: Text('Log In'),
//             backgroundColor: customYellow,
//           ),
//           body: Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 TextField(
//                   decoration: InputDecoration(labelText: 'Org Name'),
//                   controller: orgController,
//                 ),
//                 TextField(
//                   decoration: InputDecoration(labelText: 'Username'),
//                   controller: usernameController,
//                 ),
//                 TextField(
//                   decoration: InputDecoration(
//                     labelText: 'Password',
//
//                     suffixIcon: IconButton(
//                       icon: Icon(
//                         _passwordVisible ? Icons.visibility : Icons.visibility_off,
//                       ),
//                       onPressed: () {
//                         setState(() {
//                           _passwordVisible = !_passwordVisible;
//                         });
//                       },
//                     ),
//                   ),
//                   controller: passwordController,
//                   obscureText: !_passwordVisible,
//                 ),
//                 DropdownButton<String>(
//                   value: selectedUserType,
//                   items: [
//                     DropdownMenuItem<String>(
//                       value: 'Select User',
//                       child: Text('Select User'),
//                     ),
//                     DropdownMenuItem<String>(
//                       value: 'admin',
//                       child: Text('Admin'),
//                     ),
//                     DropdownMenuItem<String>(
//                       value: 'internal_user',
//                       child: Text('Internal User'),
//                     ),
//                   ],
//                   onChanged: (value) {
//                     setState(() {
//                       selectedUserType = value!;
//                     });
//                   },
//                   hint: Text('Select User'),
//                 ),
//                 SizedBox(height: 20),
//                 Row(
//
//                   children: [
//                     ElevatedButton(
//                       onPressed: () async {
//                         String org_name = orgController.text.trim();
//                         String username = usernameController.text.trim();
//                         String password = passwordController.text.trim();
//
//
//                         if (org_name.isEmpty || username.isEmpty || password.isEmpty) {
//                           showError(context, 'Org Name, username and password cannot be empty');
//                           return;
//                         }
//
//                         if (!org_name.equalsIgnoreCase(INITIAL_ADMIN_ORG_NAME)) {
//                           showError(context, 'Invalid Org Name');
//                           return;
//                         }
//
//                         if (selectedUserType == 'Select User') {
//                           showError(context, 'Please select a user type');
//                           return;
//                         }
//
//                         if (selectedUserType == 'admin') {
//                           final databaseReference = FirebaseDatabase.instance.ref();
//                           final snapshot = await databaseReference.child('admin_credentials').get();
//
//                           if (!snapshot.exists) {
//                             if (org_name.toLowerCase() == INITIAL_ADMIN_ORG_NAME.toLowerCase() &&
//                                 username == INITIAL_ADMIN_EMAIL &&
//                                 password == INITIAL_ADMIN_PASSWORD) {
//
//                               context.go('/initial_admin_setup?orgName=${INITIAL_ADMIN_ORG_NAME}&email=${INITIAL_ADMIN_EMAIL}');
//
//                               return;
//                             } else {
//                               showError(context, 'Invalid initial admin credentials');
//                               return;
//                             }
//                           }
//
//                           // If credentials exist in database, validate against database
//                           bool isValidAdmin = await validateAdminCredentials(username, password);
//                           if (isValidAdmin) {
//                             context.go('/manage_users');
//                           } else {
//                             showError(context, 'Invalid admin credentials');
//                           }
//                         } else if (selectedUserType == 'internal_user') {
//                           bool isValidUser = await validateInternalUser(username, password);
//                           if (isValidUser) {
//                             context.go('/dashboard');
//                           } else {
//                             showError(context, 'Invalid credentials or user type');
//                           }
//                         }
//                       },
//                       child: Text('Login'),
//                     ),
//                     SizedBox(width: 10),
//                     ElevatedButton(onPressed: (){}, child: Text('Forgot Password'))
//                   ],
//                 ),
//
//               ],
//             ),
//           ),
//         ));
//   }
//
//   Future<bool> checkAdminCredentialsExist() async {
//     try {
//       final databaseReference = FirebaseDatabase.instance.ref();
//       final snapshot = await databaseReference.child('admin_credentials').get();
//       return snapshot.exists;
//     } catch (e) {
//       print("Error checking admin credentials existence: $e");
//       return false;
//     }
//   }
//
//   void showError(BuildContext context, String message) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text(message)),
//     );
//   }
//
//
//   Future<bool> validateAdminCredentials(String username, String password) async {
//     try {
//       final databaseReference = FirebaseDatabase.instance.ref();
//       final snapshot = await databaseReference.child('admin_credentials').get();
//
//       if (snapshot.exists) {
//         final adminData = snapshot.value as Map;
//         return adminData['email'] == username && adminData['password'] == password;
//       }
//       return false;
//     } catch (e) {
//       print("Error validating admin credentials: $e");
//       return false;
//     }
//   }
//
//   Future<bool> validateInternalUser(String username, String password) async {
//     try {
//       final databaseReference = FirebaseDatabase.instance.ref();
//       final snapshot = await databaseReference.child('internal_users').get();
//
//       if (snapshot.exists) {
//         final users = snapshot.value as Map;
//
//
//         for (var userId in users.keys) {
//           final user = users[userId];
//           if (user['username'] == username && user['password'] == password) {
//             return true;
//           }
//         }
//       }
//       return false;
//     } catch (e) {
//       print("Error validating internal user: $e");
//       return false;
//     }
//   }
// }
//
// class InitialAdminSetupScreen extends StatefulWidget {
//   final bool isInitialSetup;
//   final String INITIAL_ADMIN_ORG_NAME;
//   final String INITIAL_ADMIN_EMAIL;
//
//   const InitialAdminSetupScreen({ required this.INITIAL_ADMIN_ORG_NAME, required this.INITIAL_ADMIN_EMAIL, Key? key, this.isInitialSetup = false}) : super(key: key);
//
//   @override
//   _InitialAdminSetupScreenState createState() => _InitialAdminSetupScreenState();
// }
//
// class _InitialAdminSetupScreenState extends State<InitialAdminSetupScreen> {
//   final TextEditingController passwordController = TextEditingController();
//   final TextEditingController confirmPasswordController = TextEditingController();
//   bool _passwordVisible = false;
//
//   @override
//   Widget build(BuildContext context) {
//     return WillPopScope(
//         onWillPop: () async {
//           return false;
//         },
//         child: Scaffold(
//           appBar: AppBar(
//             automaticallyImplyLeading: false,
//             title: Text(widget.isInitialSetup
//                 ? 'Initial Admin Setup'
//                 : 'Create New Admin Password'),
//           ),
//           body: Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   widget.isInitialSetup
//                       ? 'Set Up Initial Admin Password'
//                       : 'Create New Admin Password',
//                   style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//                 ),
//                 SizedBox(height: 20),
//                 TextField(
//                   decoration: InputDecoration(
//                     labelText: 'Password',
//
//                     suffixIcon: IconButton(
//                       icon: Icon(
//                         _passwordVisible ? Icons.visibility : Icons.visibility_off,
//                       ),
//                       onPressed: () {
//                         setState(() {
//                           _passwordVisible = !_passwordVisible;
//                         });
//                       },
//                     ),
//                   ),
//                   controller: passwordController,
//                   obscureText: !_passwordVisible,
//
//                 ),
//                 TextField(
//                   decoration: InputDecoration(
//                     labelText: 'Confirm Password',
//
//                     suffixIcon: IconButton(
//                       icon: Icon(
//                         _passwordVisible ? Icons.visibility : Icons.visibility_off,
//                       ),
//                       onPressed: () {
//                         setState(() {
//                           _passwordVisible = !_passwordVisible;
//                         });
//                       },
//                     ),
//                   ),
//                   controller: confirmPasswordController,
//                   obscureText: !_passwordVisible,
//                 ),
//                 SizedBox(height: 20),
//                 ElevatedButton(
//                   onPressed: () async {
//                     String org_name = widget.INITIAL_ADMIN_ORG_NAME;
//                     String username = widget.INITIAL_ADMIN_EMAIL;
//                     String password = passwordController.text.trim();
//                     String confirmPassword = confirmPasswordController.text.trim();
//
//                     if (org_name.isEmpty || username.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
//                       _showError('All fields are required');
//                       return;
//                     }
//
//                     if (password != confirmPassword) {
//                       _showError('Passwords do not match');
//                       return;
//                     }
//
//                     if (!org_name.equalsIgnoreCase(widget.INITIAL_ADMIN_ORG_NAME)) {
//                       _showError('Invalid Org Name');
//                       return;
//                     }
//
//                     // if (!EmailValidator.isValid(email)) {
//                     //   _showError('Invalid email format');
//                     //   return;
//                     // }
//
//
//                     try {
//                       final databaseReference = FirebaseDatabase.instance.ref();
//                       await databaseReference.child('admin_credentials').set({
//                         'orgname': org_name,
//                         'username': username,
//                         'password': password
//                       });
//
//
//                       GoRouter.of(context).pushReplacement('/login');
//
//                     } catch (e) {
//                       _showError('Failed to save credentials: $e');
//                     }
//                   },
//                   child: Text(widget.isInitialSetup
//                       ? 'Create Admin Account'
//                       : 'Create New Password'),
//                 ),
//               ],
//             ),
//           ),
//         ));
//   }
//
//   void _showError(String message) {
//     ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(
//       SnackBar(content: Text(message)),
//     );
//   }
//
//
// }
// extension StringComparison on String {
//   bool equalsIgnoreCase(String other) => this.toLowerCase() == other.toLowerCase();
// }
//
//
//
// class MyApp extends StatelessWidget {
//   final GoRouter _router = GoRouter(
//
//     routes: [
//       GoRoute(path: '/', builder: (context, state) => SplashPage()),
//       GoRoute(
//           path: '/login',
//           name: 'login',
//           builder: (context, state) => LoggedInScreen()),
//       GoRoute(path: '/dashboard', builder: (context, state) => Dashboard()),
//       GoRoute(
//           path: '/manage_users',
//           builder: (context, state) => ManageUsersPage()),
//
//       GoRoute(
//         path: '/initial_admin_setup',
//         builder: (context, state) {
//           final orgName = state.uri.queryParameters['orgName'] ?? 'Unknown';
//           final email = state.uri.queryParameters['email'] ?? 'Unknown';
//           return InitialAdminSetupScreen(
//               INITIAL_ADMIN_ORG_NAME: orgName, INITIAL_ADMIN_EMAIL: email);
//         },
//       ),
//
//     ],
//   );
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp.router(
//       routerConfig: _router,
//       debugShowCheckedModeBanner: false,
//       title: 'AIMS Academy',
//       theme: ThemeData(primarySwatch: Colors.blue),
//     );
//   }
// }
//
//
//

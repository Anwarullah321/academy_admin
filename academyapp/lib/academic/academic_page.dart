// import 'package:academyapp/services/get_service.dart';
// import 'package:academyapp/academic/subject_screen.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
//
// class AcademicPage extends StatefulWidget {
//   @override
//   _AcademicPageState createState() => _AcademicPageState();
// }
//
// class _AcademicPageState extends State<AcademicPage> {
//   final GetService _getService = GetService();
//   List<String> _classes = [];
//   bool _isLoading = true;
//
//   @override
//   void initState() {
//     super.initState();
//     _loadClasses();
//   }
//
//
//   Future<void> _loadClasses() async {
//     setState(() {
//       _isLoading = true;
//     });
//
//     final prefs = await SharedPreferences.getInstance();
//     final cachedClasses = prefs.getStringList('cached_classes');
//
//     if (cachedClasses != null) {
//       setState(() {
//         _classes = cachedClasses;
//         _isLoading = false;
//       });
//     }
//
//     // Fetch new data in the background
//     final classes = await _getService.getClasses();
//
//     if (!listEquals(classes, _classes)) {
//       setState(() {
//         _classes = classes;
//       });
//       await prefs.setStringList('cached_classes', classes);
//     }
//
//     setState(() {
//       _isLoading = false;
//     });
//   }
//
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('Academic')),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: _classes.isEmpty
//             ? Center(child: CircularProgressIndicator())
//             : GridView.builder(
//           gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//             crossAxisCount: 2,
//             crossAxisSpacing: 16.0,
//             mainAxisSpacing: 16.0,
//           ),
//           itemCount: _classes.length,
//           itemBuilder: (context, index) {
//             final className = _classes[index];
//             return GestureDetector(
//               onTap: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (context) => SubjectGridPage(className: className),
//                   ),
//                 );
//               },
//               child: Container(
//                 decoration: BoxDecoration(
//                   color: Colors.blue,
//                   borderRadius: BorderRadius.circular(8.0),
//                 ),
//                 child: Center(
//                   child: Text(
//                     className,
//                     style: TextStyle(
//                       color: Colors.white,
//                       fontSize: 18.0,
//                       fontWeight: FontWeight.bold,
//                     ),
//                     textAlign: TextAlign.center,
//                   ),
//                 ),
//               ),
//             );
//           },
//         ),
//       ),
//     );
//   }
// }

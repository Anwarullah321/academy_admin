import 'package:flutter/cupertino.dart';

import '../services/get_service.dart';

class SubjectProvider with ChangeNotifier {
  final GetService _getService = GetService();
  String? _selectedClass;
  List<String> _subjects = [];
  bool _isLoading = false;
  Map<String, bool> _isHovered = {};

  static const Map<String, String> subjectImages = {
    'English': 'assets/images/subjects/english.png',
    'Physics': 'assets/images/subjects/physics.png',
    'Chemistry': 'assets/images/subjects/chemistry.png',
    'Biology': 'assets/images/subjects/biology.png',
    'Maths': 'assets/images/subjects/maths.png',
    'Urdu': 'assets/images/subjects/urdu.png',
    'Computer Science': 'assets/images/subjects/computer.png',
    'PakStudy': 'assets/images/subjects/pakistanstudy.png',
    'Islamiat': 'assets/images/subjects/islamiyat.png',
  };

  List<String> get subjects => _subjects;
  bool get isLoading => _isLoading;
  String? get selectedClass => _selectedClass;

  bool isHovered(String subject) => _isHovered[subject] ?? false;

  void setHover(String subject, bool value) {
    _isHovered[subject] = value;
    notifyListeners();
  }

  void setSelectedClass(String selectedClass) {
    _selectedClass = selectedClass;
    notifyListeners();
  }

  Future<void> loadSubjects() async {
    if (_selectedClass == null) return;
    _isLoading = true;
    notifyListeners();
    try {
      final subjects = await _getService.getSubjects(_selectedClass!);
      _subjects = subjects;
      _subjects.forEach((subject) => _isHovered[subject] = false);
    } catch (e) {
      print("Error loading subjects: $e");
    }
    _isLoading = false;
    notifyListeners();
  }
}
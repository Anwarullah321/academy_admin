import 'package:flutter/cupertino.dart';

import '../services/get_service.dart';

class ClassProvider with ChangeNotifier {
  final GetService _getService = GetService();
  List<String> _classes = [];
  bool _isLoading = false;
  Map<String, bool> _isHovered = {};

  static const List<String> _classOrder = [
    'Class 9',
    'Class 10',
    '1st Year',
    '2nd Year'
  ];

  static const Map<String, String> classImages = {
    'Class 9': 'assets/images/class9.png',
    'Class 10': 'assets/images/class10.png',
    '1st Year': 'assets/images/1styear.png',
    '2nd Year': 'assets/images/2ndyear.png',
  };

  List<String> get classes => _classes;
  bool get isLoading => _isLoading;

  bool isHovered(String className) => _isHovered[className] ?? false;

  void setHover(String className, bool value) {
    _isHovered[className] = value;
    notifyListeners();
  }

  Future<void> loadClasses() async {
    _isLoading = true;
    notifyListeners();
    try {
      final cls = await _getService.getClasses();
      _classes = cls
          .where((classItem) => _classOrder.contains(classItem))
          .toList()
        ..sort((a, b) => _classOrder.indexOf(a).compareTo(_classOrder.indexOf(b)));
    } catch (e) {
      print("Error loading classes: $e");
    }
    _isLoading = false;
    notifyListeners();
  }
}

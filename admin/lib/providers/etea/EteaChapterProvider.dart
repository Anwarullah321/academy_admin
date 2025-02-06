import 'package:flutter/cupertino.dart';

import '../../services/get_service.dart';

class EteaChapterProvider with ChangeNotifier {
  final GetService _getService = GetService();
  String? _selectedSubject;
  List<String> _chapters = [];
  bool _isLoading = false;
  Map<String, bool> _isHovered = {};

  List<String> get chapters => _chapters;
  bool get isLoading => _isLoading;
  String? get selectedSubject => _selectedSubject;

  bool isHovered(String chapter) => _isHovered[chapter] ?? false;

  void setHover(String chapter, bool value) {
    _isHovered[chapter] = value;
    notifyListeners();
  }

  void setSelectedSubject(String selectedSubject) {
    _selectedSubject = selectedSubject;
    notifyListeners();
  }

  Future<void> loadChapters() async {
    if (_selectedSubject == null) return;
    _isLoading = true;
    notifyListeners();
    try {
      final chapters = await _getService.getEteaChapters(_selectedSubject!);
      _chapters = chapters;
      _chapters.forEach((chapter) => _isHovered[chapter] = false);
    } catch (e) {
      print("Error loading chapters: $e");
    }
    _isLoading = false;
    notifyListeners();
  }
}

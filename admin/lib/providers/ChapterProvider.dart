import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../constants/colors.dart';
import '../services/get_service.dart';

class ChapterProvider with ChangeNotifier {
  final GetService _getService = GetService();
  String? _selectedClass;
  String? _selectedSubject;
  List<String> _chapters = [];
  bool _isLoading = false;
  Map<String, bool> _isHovered = {};

  List<String> get chapters => _chapters;
  bool get isLoading => _isLoading;

  bool isHovered(String chapter) => _isHovered[chapter] ?? false;

  void setHover(String chapter, bool value) {
    _isHovered[chapter] = value;
    notifyListeners();
  }

  void setSelectedClassAndSubject(String selectedClass, String selectedSubject) {
    _selectedClass = selectedClass;
    _selectedSubject = selectedSubject;
    notifyListeners();
  }

  Future<void> loadChapters() async {
    if (_selectedClass == null || _selectedSubject == null) return;
    _isLoading = true;
    notifyListeners();
    try {
      final chapters = await _getService.getChapters(_selectedClass!, _selectedSubject!);
      _chapters = chapters;
      _chapters.forEach((chapter) => _isHovered[chapter] = false);
    } catch (e) {
      print("Error loading chapters: $e");
    }
    _isLoading = false;
    notifyListeners();
  }

  void showQuestionTypeDialog(BuildContext context, String chapter) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Select Type'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: customYellow,
                  minimumSize: Size(double.infinity, 45),
                ),
                onPressed: () => context.go('/chapter_detail/${_selectedClass}/${_selectedSubject}/$chapter/0'),
                child: Text('Objective', style: TextStyle(color: Colors.black)),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: customYellow,
                  minimumSize: Size(double.infinity, 45),
                ),
                onPressed: () => context.go('/chapter_detail/${_selectedClass}/${_selectedSubject}/$chapter/1'),
                child: Text('Subjective', style: TextStyle(color: Colors.black)),
              ),
            ],
          ),
        );
      },
    );
  }
}

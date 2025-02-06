import 'package:flutter/cupertino.dart';

import '../models/question_model.dart';
import '../models/year_options.dart';
import '../services/delete_service.dart';
import '../services/get_service.dart';
import '../services/update_service.dart';

class QuestionProvider with ChangeNotifier {
  final GetService _getService = GetService();
  final UpdateService _updateService = UpdateService();
  final DeleteService _deleteService = DeleteService();

  List<Question> _questions = [];
  Question? _selectedQuestion;
  bool _isLoading = false;
  YearOption? _selectedYear;
  List<YearOption> _uniqueYears = [];
  bool _isDeleting = false;

  bool get isDeleting => _isDeleting;


  List<Question> get questions => _selectedYear?.year == null
      ? _questions
      : _questions.where((q) => q.year == _selectedYear?.year).toList();

  Question? get selectedQuestion => _selectedQuestion;
  bool get isQuestionLoading => _isLoading;
  YearOption? get selectedYear => _selectedYear;
  List<YearOption> get uniqueYears => _uniqueYears;

  Future<void> loadQuestions(String className, String subject, String chapter) async {
    _isLoading = true;
    notifyListeners();

    _questions = await _getService.getChapterwiseQuestions(className, subject, chapter);
    _isLoading = false;
    _generatequestionUniqueYears();
    notifyListeners();
  }

  void _generatequestionUniqueYears() {
    Set<int> uniqueYearValues = _questions.map((q) => q.year).toSet();
    _uniqueYears = [
      YearOption(null),
      ...uniqueYearValues.map((year) => YearOption(year)).toList()
        ..sort((a, b) => a.year!.compareTo(b.year!)),
    ];
  }

  void selectQuestion(Question question) {
    try {
      _selectedQuestion = _questions.firstWhere((q) => q.id == question.id);
      print("Selected Question: ${_selectedQuestion?.question}");
    } catch (e) {
      _selectedQuestion = null;
    }
    notifyListeners();
  }

  void filterQuestions(YearOption? yearOption) {
    _selectedYear = yearOption;
    notifyListeners();
  }

  Future<void> updateQuestion(String className, String subject, String chapter, Question updatedQuestion) async {
    try {
      await _updateService.updateChapterwiseQuestion(className, subject, chapter, updatedQuestion);

      int index = _questions.indexWhere((q) => q.id == updatedQuestion.id);
      if (index != -1) {
        _questions[index] = updatedQuestion;
        notifyListeners();
      }
    } catch (e) {
      print("Error updating Question: $e");
      throw e;
    }
  }

  Future<void> deleteQuestion(String className, String subject, String chapter, String questionId) async {
    await _deleteService.deleteChapterwiseQuestion(className, subject, chapter, questionId);
    _questions.removeWhere((q) => q.id == questionId);
    _isDeleting = false;
    notifyListeners();
  }

  Future<void> deleteQuestionsByYear(String className, String subject, String chapter, int year) async {
    await _deleteService.deleteQuestionsByYear(className, subject, chapter, year);
    _questions.removeWhere((q) => q.id == year);
    _isDeleting = false;
    _generatequestionUniqueYears();
    notifyListeners();
  }



}

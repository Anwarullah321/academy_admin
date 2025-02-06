import 'package:flutter/cupertino.dart';

import '../services/get_service.dart';
import '../services/update_service.dart';
import '../services/delete_service.dart';
import '../models/mcq_model.dart';
import '../models/question_model.dart';
import '../models/year_options.dart';


class MCQProvider with ChangeNotifier {
  final GetService _getService = GetService();
  final UpdateService _updateService = UpdateService();
  final DeleteService _deleteService = DeleteService();

  List<MCQ> _mcqs = [];
  MCQ? _selectedMCQ;
  bool _isLoading = false;
  YearOption? _selectedYear;
  List<YearOption> _uniqueYears = [];
  bool _isDeleting = false;
  bool get isDeleting => _isDeleting;

  List<MCQ> get mcqs => _selectedYear?.year == null
      ? _mcqs
      : _mcqs.where((mcq) => mcq.year == _selectedYear?.year).toList();
  MCQ? get selectedMCQ => _selectedMCQ;
  bool get isLoading => _isLoading;
  YearOption? get selectedYear => _selectedYear;
  List<YearOption> get uniqueYears => _uniqueYears;



  Future<void> loadMCQs(String className, String subject, String chapter) async {
    _isLoading = true;
    notifyListeners();

    _mcqs = await _getService.getChapterwiseMCQs(className, subject, chapter);
    _isLoading = false;
    _generateUniqueYears();
    notifyListeners();
  }

  Future<void> loadEteaMCQs(String subject, String chapter) async {
    _isLoading = true;
    notifyListeners();

    _mcqs = await _getService.getEteaChapterwiseMCQs(subject, chapter);
    _isLoading = false;
    _generateUniqueYears();
    notifyListeners();
  }

  void _generateUniqueYears() {
    Set<int> uniqueYearValues = _mcqs.map((mcq) => mcq.year).toSet();
    _uniqueYears = [
      YearOption(null),
      ...uniqueYearValues.map((year) => YearOption(year)).toList()
        ..sort((a, b) => a.year!.compareTo(b.year!)),
    ];
  }

  void selectMCQ(MCQ mcq) {
    try {
      _selectedMCQ = _mcqs.firstWhere((m) => m.id == mcq.id);
    } catch (e) {
      _selectedMCQ = null;
    }
    notifyListeners();
  }

  void filterMCQs(YearOption? yearOption) {
    _selectedYear = yearOption;
    notifyListeners();
  }

  Future<void> updateMCQ(String className, String subject, String chapter, MCQ updatedMCQ) async {
    try {
      await _updateService.updateChapterwiseMCQ(className, subject, chapter, updatedMCQ.id, updatedMCQ);

      int index = _mcqs.indexWhere((mcq) => mcq.id == updatedMCQ.id);

      if (index != -1) {
        _mcqs[index] = updatedMCQ;
        notifyListeners();

      }
    } catch (e) {
      print("Error updating MCQ: $e");
      throw e;
    }
  }

  Future<void> updateEteaMCQ(String subject, String chapter, MCQ updatedMCQ) async {
    try {
      await _updateService.updateEteaChapterwiseMCQ(subject, chapter, updatedMCQ.id, updatedMCQ);

      int index = _mcqs.indexWhere((mcq) => mcq.id == updatedMCQ.id);

      if (index != -1) {
        _mcqs[index] = updatedMCQ;
        notifyListeners();

      }
    } catch (e) {
      print("Error updating MCQ: $e");
      throw e;
    }
  }



  Future<void> deleteMCQsByYear(String className, String subject, String chapter, int year) async {
    _mcqs.removeWhere((mcq) => mcq.year == year);
    await _deleteService.deleteMCQsByYear(className, subject, chapter, year);
    _generateUniqueYears();
    notifyListeners();
  }

  Future<void> deleteEteaMCQsByYear(String subject, String chapter, int year) async {
    _mcqs.removeWhere((mcq) => mcq.year == year);
    await _deleteService.deleteEteaMCQsByYear(subject, chapter, year);
    _generateUniqueYears();
    notifyListeners();
  }

  Future<void> deleteMCQ(String selectedClass, String selectedSubject, String selectedChapter, String mcqId) async {
    await _deleteService.deleteChpaterwiseMCQ(selectedClass, selectedSubject, selectedChapter, mcqId);
    _mcqs.removeWhere((mcq) => mcq.id == mcqId);
    _isDeleting = false;
    notifyListeners();
  }


  Future<void> deleteEteaMCQ(String selectedSubject, String selectedChapter, String mcqId) async {
    await _deleteService.deleteEteaChapterwiseMCQ(selectedSubject, selectedChapter, mcqId);
    _mcqs.removeWhere((mcq) => mcq.id == mcqId);
    _isDeleting = false;
    notifyListeners();
  }


}

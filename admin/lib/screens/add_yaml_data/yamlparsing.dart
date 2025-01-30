import 'dart:convert';
import 'package:admin/models/mcq_model.dart';
import 'package:admin/models/question_model.dart';

class YamlParser {
  Map<String, dynamic> parseJson(String jsonString) {
    Map<String, dynamic> jsonData = json.decode(jsonString);

    return {
      'metadata': _extractMetadata(jsonData),
      'mcqs': _parseMCQs(jsonData['Section A'] ?? []),
      'shortQuestions': _parseShortQuestions(jsonData['Section B'] ?? []),
      'longQuestions': _parseLongQuestions(jsonData['Section C'] ?? []),
    };
  }

  Map<String, String> _extractMetadata(Map<String, dynamic> data) {
    return {
      'class': data['Class'] ?? '',
      'subject': data['Subject'] ?? '',
      'chapter': data['Chapter'] ?? '',
    };
  }

  List<MCQ> _parseMCQs(List<dynamic> mcqs) {
    return mcqs.map((mcq) => MCQ(
      id: '',
      question: mcq['question'] ?? '',
      options: List<String>.from(mcq['options'] ?? []),
      correctOption: mcq['correctOption']?.toInt() -1 ?? -1,
      year: DateTime.now().year,
    )).toList();
  }

  List<Question> _parseShortQuestions(List<dynamic> questions) {
    return questions.map((q) => Question(
      id: '',
      question: q ?? '',
      year: DateTime.now().year,
    )).toList();
  }

  List<Question> _parseLongQuestions(List<dynamic> questions) {
    return questions.map((q) => Question(
      id: '',
      question: q ?? '',
      year: DateTime.now().year,
    )).toList();
  }
}
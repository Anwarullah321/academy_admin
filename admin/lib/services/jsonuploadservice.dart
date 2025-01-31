import 'package:admin/services/add_service.dart';
import 'package:yaml/yaml.dart';
import '../models/mcq_model.dart';
import '../models/question_model.dart';

class YamlUploadService {
  final AddService _addService = AddService();

  Future<void> processYamlData(String yamlString, String className, String subject, String chapter) async {
    try {
      // Parse YAML to a Dart object
      YamlList yamlData = loadYaml(yamlString);

      List<MCQ> mcqs = [];
      List<Question> questions = [];

      for (var item in yamlData) {
        if (item is YamlMap) {
          if (item.containsKey('options')) {
            // This is an MCQ
            mcqs.add(_processMCQ(item));
          } else {
            // This is a regular question
            questions.add(_processQuestion(item));
          }
        }
      }

      // Upload MCQs
      for (var mcq in mcqs) {
        await _addService.addChapterwiseMCQ(className, subject, chapter, mcq);
      }

      // Upload regular questions
      for (var question in questions) {
        await _addService.addChapterwiseQuestion(className, subject, chapter, question);
      }

    } catch (e) {
      print('Error processing YAML data: $e');
      rethrow;
    }
  }

  MCQ _processMCQ(YamlMap mcqData) {
    return MCQ(
      id: '',  // ID will be generated by Realtime Database
      question: mcqData['question'],
      options: List<String>.from(mcqData['options']),
      correctOption: mcqData['correctOption']?.toInt() - 1 ?? -1,
      year: DateTime.now().year,
    );
  }

  Question _processQuestion(YamlMap questionData) {
    return Question(
      id: '',  // ID will be generated by Realtime Database
      question: questionData['question'],
      year: DateTime.now().year,
    );
  }

  Future<void> processYamlMcqData(String yamlString, String subject, String chapter) async {
    try {
      // Parse YAML to a Dart object
      YamlList yamlData = loadYaml(yamlString);

      List<MCQ> mcqs = [];

      for (var item in yamlData) {
        if (item is YamlMap) {
          if (item.containsKey('options')) {
            // This is an MCQ
            mcqs.add(_processEteaMCQ(item));
          }
        }
      }

      // Upload MCQs
      for (var mcq in mcqs) {
        await _addService.addEteaChapterwiseMCQ(subject, chapter, mcq);
      }

    } catch (e) {
      print('Error processing YAML data: $e');
      rethrow;
    }
  }

  MCQ _processEteaMCQ(YamlMap mcqData) {
    return MCQ(
      id: '',  // ID will be generated by Realtime Database
      question: mcqData['question'],
      options: List<String>.from(mcqData['options']),
      correctOption: mcqData['correctOption']?.toInt() - 1 ?? -1,
      year: DateTime.now().year,
    );
  }
}
import 'package:admin/services/add_service.dart';
import 'package:yaml/yaml.dart';
import '../models/mcq_model.dart';
import '../models/question_model.dart';

class MutableMCQ {
  String id;
  String question;
  List<String> options;
  int correctOption;
  int year;

  MutableMCQ({
    required this.id,
    required this.question,
    required this.options,
    required this.correctOption,
    required this.year,
  });

  MCQ toImmutableMCQ() {
    return MCQ(
      id: id,
      question: question,
      options: options,
      correctOption: correctOption,
      year: year,
    );
  }
}


class YamlCompleteUploadService {

  final AddService _addService = AddService();

  Future<void> processTextData(String textData) async {
    try {
      List<String> lines = textData.split('\n');
      if (lines.isEmpty) {
        throw Exception('No data found');
      }

      String? className;
      String? subject;
      String? currentChapter;
      List<MutableMCQ> mcqs = [];
      List<Question> questions = [];
      MutableMCQ? currentMcq;
      Question? currentQuestion;

      void addCurrentMcq() {
        if (currentMcq != null) {
          mcqs.add(currentMcq!);
          currentMcq = null;
        }
      }

      void addCurrentQuestion() {
        if (currentQuestion != null) {
          questions.add(currentQuestion!);
          currentQuestion = null;
        }
      }

      Future<void> uploadCurrentChapter() async {
        if (className != null && subject != null && currentChapter != null) {
          if (mcqs.isNotEmpty) {
            await _uploadMCQs(className, subject, currentChapter, mcqs);
            mcqs.clear();
          }
          if (questions.isNotEmpty) {
            await _uploadQuestions(
                className, subject, currentChapter, questions);
            questions.clear();
          }
        }
      }

      for (int i = 0; i < lines.length; i++) {
        String line = lines[i].trim();

        if (line.contains(',') && line
            .split(',')
            .length == 3) {
          // This is a new chapter line
          addCurrentMcq();
          addCurrentQuestion();
          await uploadCurrentChapter(); // Upload previous chapter's MCQs and questions

          List<String> metadata = line.split(',');
          String newClassName = metadata[0].trim();
          String newSubject = metadata[1].trim();
          currentChapter = metadata[2].trim();

          // Update class and subject only if they're different
          if (className == null || subject == null ||
              newClassName != className || newSubject != subject) {
            className = newClassName;
            subject = newSubject;
          }
        } else if (line.startsWith('Q:')) {
          addCurrentMcq();
          addCurrentQuestion();
          currentMcq = MutableMCQ(
            id: '',
            question: line.substring(2).trim(),
            options: [],
            correctOption: -1,
            year: DateTime
                .now()
                .year,
          );
        } else if (line.startsWith('A:') || line.startsWith('B:') ||
            line.startsWith('C:') || line.startsWith('D:')) {
          currentMcq?.options.add(line.substring(2).trim());
        } else if (line.startsWith('Ans:')) {
          String answer = line.substring(4).trim().toUpperCase();
          currentMcq?.correctOption = 'ABCD'.indexOf(answer);
        } else if (line.startsWith('Question:')) {
          addCurrentMcq();
          addCurrentQuestion();
          currentQuestion = Question(
            id: '',
            question: line.substring(9).trim(),
            year: DateTime
                .now()
                .year,

          );
        }
      }

      // Add the last MCQ/Question and upload the last chapter's data
      addCurrentMcq();
      addCurrentQuestion();
      await uploadCurrentChapter();
    } catch (e) {
      print('Error processing text data: $e');
      rethrow;
    }
  }

  Future<void> _uploadMCQs(String className, String subject, String chapter,
      List<MutableMCQ> mcqs) async {
    for (var mutableMcq in mcqs) {
      await _addService.addChapterwiseMCQ(
          className, subject, chapter, mutableMcq.toImmutableMCQ());
    }
  }

  Future<void> _uploadQuestions(String className, String subject,
      String chapter, List<Question> questions) async {
    for (var question in questions) {
      await _addService.addChapterwiseQuestion(
          className, subject, chapter, question);
    }
  }

  Future<void> processCompleteYamlData(String yamlString) async {
    try {
      YamlMap yamlData = loadYaml(yamlString);

      for (var classEntry in yamlData.entries) {
        String className = classEntry.key;
        YamlMap subjects = classEntry.value;

        for (var subjectEntry in subjects.entries) {
          String subject = subjectEntry.key;
          YamlMap chapters = subjectEntry.value;

          for (var chapterEntry in chapters.entries) {
            String chapter = chapterEntry.key;
            YamlList mcqs = chapterEntry.value;

            for (var mcqData in mcqs) {
              MCQ mcq = _processMCQ(mcqData);
              await _addService.addChapterwiseMCQ(
                  className, subject, chapter, mcq);
            }
          }
        }
      }
    } catch (e) {
      print('Error processing YAML data: $e');
      rethrow;
    }
  }

  MCQ _processMCQ(YamlMap mcqData) {
    return MCQ(
      id: '',
      // ID will be generated by Realtime Database
      question: mcqData['question'],
      options: List<String>.from(mcqData['options']),
      correctOption: mcqData['correctOption']?.toInt() - 1 ?? -1,
      year: DateTime
          .now()
          .year,
    );
  }
}
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:admin/models/question_model.dart';
import 'package:firebase_database/firebase_database.dart';
import '../models/mcq_model.dart';
import '../models/pdf_model.dart';

class GetService {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();

  final String _databaseUrl = "https://academy-app-realtimedatabase-default-rtdb.firebaseio.com";




  Future<List<String>> getEteaSubjects() async {
    print("Fetching ETEA subjects...");
    final url = "$_databaseUrl/etea_subjects.json?shallow=true"; // Use the correct URL with shallow query
    print("Requesting URL: $url");

    try {
      final response = await http.get(Uri.parse(url));
      print("Response Status: ${response.statusCode}");
      print("Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        print("ETEA Subjects fetched successfully. Data: $data");
        return data.keys.toList(); // Return subject keys as a list
      } else {
        print("Failed to fetch ETEA subjects. Status Code: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching ETEA subjects: $e");
    }

    return [];
  }


  Future<List<String>> getEteaChapters(String subject) async {
    print("Fetching ETEA chapters for subject: $subject...");
    final url = "$_databaseUrl/etea_subjects/$subject/etea_chapters.json?shallow=true"; // Use the correct URL with shallow query
    print("Requesting URL: $url");

    try {
      final response = await http.get(Uri.parse(url));
      print("Response Status: ${response.statusCode}");
      print("Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        print("ETEA Chapters fetched successfully. Data: $data");

        // Sort the chapter keys alphabetically
        final sortedChapters = data.keys.toList()..sort((a, b) => a.compareTo(b));
        print("Sorted ETEA Chapters: $sortedChapters");

        return sortedChapters; // Return the sorted list
      } else {
        print("Failed to fetch ETEA chapters. Status Code: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching ETEA chapters: $e");
    }

    return [];
  }



  Future<List<String>> getClasses() async {
    print("Fetching classes...");
    final url = "$_databaseUrl/classes.json?shallow=true"; // shallow query to fetch only class keys
    print("Requesting URL: $url");

    try {
      final response = await http.get(Uri.parse(url));
      print("Response Status: ${response.statusCode}");
      print("Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        print("Classes fetched successfully. Data: $data");
        return data.keys.toList(); // Extract only the class keys
      } else {
        print("Failed to fetch classes. Status Code: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching classes: $e");
    }

    return [];
  }

  Future<List<String>> getSubjects(String className) async {
    print("Fetching subjects for class: $className...");
    final url = "$_databaseUrl/classes/$className/subjects.json?shallow=true"; // Update the URL with correct path and `shallow=true`
    print("Requesting URL: $url");

    try {
      final response = await http.get(Uri.parse(url));
      print("Response Status: ${response.statusCode}");
      print("Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        print("Subjects fetched successfully. Data: $data");
        return data.keys.toList(); // Extract only the subject keys
      } else {
        print("Failed to fetch subjects. Status Code: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching subjects: $e");
    }

    return [];
  }

  Future<List<String>> getChapters(String className, String subject) async {
    print("Fetching chapters for class: $className, subject: $subject...");
    final url = "$_databaseUrl/classes/$className/subjects/$subject/chapters.json?shallow=true";
    print("Requesting URL: $url");

    try {
      final response = await http.get(Uri.parse(url));
      print("Response Status: ${response.statusCode}");
      print("Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        print("Chapters fetched successfully. Data: $data");

        // Sort the chapter keys
        final sortedChapters = data.keys.toList()..sort((a, b) => a.compareTo(b));
        print("Sorted Chapters: $sortedChapters");

        return sortedChapters; // Return the sorted list
      } else {
        print("Failed to fetch chapters. Status Code: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching chapters: $e");
    }

    return [];
  }

  Future<MCQ?> getMCQById(String className, String subject, String chapter, String mcqId) async {
    try {

      final ref = _database.child(
          'classes/$className/subjects/$subject/chapters/$chapter/chapterwise_mcqs/$mcqId');

      print('Fetching MCQ from path: ${ref.path}');

      final snapshot = await ref.get();

      if (snapshot.exists && snapshot.value is Map) {
        final mcqData = Map<String, dynamic>.from(snapshot.value as Map);

        print('Fetched MCQ: $mcqData');

        return MCQ.fromMap(mcqData);
      } else {
        print('MCQ not found with ID: $mcqId');
      }
    } catch (e) {
      print('Error fetching MCQ by ID: $e');
    }
    return null;
  }


  Future<Question?> getQuestionById(String className, String subject, String chapter, String questionId) async {
    try {
      final ref = _database.child(
          'classes/$className/subjects/$subject/chapters/$chapter/chapterwise_questions/$questionId');

      print('Fetching Question from path: ${ref.path}');

      final snapshot = await ref.get();

      if (snapshot.exists && snapshot.value is Map) {
        final questionData = Map<String, dynamic>.from(snapshot.value as Map);
        print('Fetched Question: $questionData');

        return Question.fromMap(questionData);
      } else {
        print('Question not found with ID: $questionId');
      }
    } catch (e) {
      print('Error fetching Question by ID: $e');
    }
    return null;
  }


  Future<List<MCQ>> getChapterwiseMCQs(String className, String subject, String chapter) async {
    try {
      final ref = _database
          .child('classes/$className/subjects/$subject/chapters/$chapter/chapterwise_mcqs');

      // Log the full path to verify
      print('Fetching MCQs from path: ${ref.path}');

      final snapshot = await ref.get();

      // Log the raw snapshot value
      print('Raw snapshot value: ${snapshot.value}');

      if (snapshot.value != null) {
        if (snapshot.value is Map) {
          final mcqsMap = snapshot.value as Map<dynamic, dynamic>;

          // Detailed logging of each MCQ
          final mcqs = mcqsMap.entries.map((entry) {
            if (entry.value is Map) {
              final mcqData = Map<String, dynamic>.from(entry.value as Map);

              // Log individual MCQ data
              print('MCQ Entry - Key: ${entry.key}, Data: $mcqData');

              // Explicitly log the year field
              print('Year field: ${mcqData['year']}, Type: ${mcqData['year'].runtimeType}');

              return MCQ.fromMap(mcqData);
            } else {
              print('Invalid MCQ data for key ${entry.key}: ${entry.value}');
              return null;
            }
          }).where((mcq) => mcq != null).cast<MCQ>().toList();

          // Log parsed MCQs
          print('Parsed MCQs: ${mcqs.map((mcq) => mcq.year).toList()}');

          return mcqs;
        } else {
          print('Unexpected data type for chapterwise_mcqs: ${snapshot.value.runtimeType}');
          return [];
        }
      }
    } catch (e, stackTrace) {
      print('Error fetching chapterwise MCQs: $e');
      print('Stack trace: $stackTrace');
    }
    return [];
  }


  int _parseYear(dynamic yearValue) {

    if (yearValue is int && yearValue > 0) {
      return yearValue;
    }


    if (yearValue is String) {
      final parsedYear = int.tryParse(yearValue);
      if (parsedYear != null && parsedYear > 0) {
        return parsedYear;
      }
    }


    return DateTime.now().year;
  }

  Future<MCQ?> getEteaMCQById(String subject, String chapter, String mcqId) async {
    try {
      final ref = _database.child(
          'etea_subjects/$subject/etea_chapters/$chapter/etea_mcqs/$mcqId');

      print('Fetching ETEA MCQ from path: ${ref.path}');

      final snapshot = await ref.get();

      if (snapshot.exists && snapshot.value is Map) {
        final mcqData = Map<String, dynamic>.from(snapshot.value as Map);
        print('Fetched ETEA MCQ: $mcqData');

        return MCQ.fromMap(mcqData);
      } else {
        print('ETEA MCQ not found with ID: $mcqId');
      }
    } catch (e) {
      print('Error fetching ETEA MCQ by ID: $e');
    }
    return null;
  }


  Future<List<MCQ>> getEteaChapterwiseMCQs(String subject, String chapter) async {
    final snapshot = await _database
        .child('etea_subjects/$subject/etea_chapters/$chapter/etea_mcqs')
        .get();

    if (snapshot.value != null) {
      final mcqsMap = snapshot.value as Map<dynamic, dynamic>;
      return mcqsMap.entries.map((entry) => MCQ.fromMap(Map<String, dynamic>.from(entry.value as Map))).toList();
    }
    return [];
  }

  Future<List<Question>> getChapterwiseQuestions(String className, String subject, String chapter) async {
    final snapshot = await _database
        .child('classes/$className/subjects/$subject/chapters/$chapter/chapterwise_questions')
        .get();

    if (snapshot.value != null) {
      final questionsMap = snapshot.value as Map<dynamic, dynamic>;
      return questionsMap.entries.map((entry) => Question.fromMap(Map<String, dynamic>.from(entry.value as Map))).toList();
    }
    return [];
  }

  Future<PdfMetadata?> fetchPdfMetadata(String className, String subject, String chapter) async {
    try {
      final snapshot = await _database
          .child('classes/$className/subjects/$subject/chapters/$chapter/etea_notes/notes')
          .get();

      if (snapshot.value != null) {
        return PdfMetadata.fromMap(Map<String, dynamic>.from(snapshot.value as Map));
      }
    } catch (e) {
      print('Error fetching PDF metadata: $e');
    }
    return null;
  }



}
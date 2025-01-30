import 'package:firebase_database/firebase_database.dart';

class DeleteService {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();

  Future<void> deleteChpaterwiseMCQ(String className, String subject, String chapter, String mcqId) async {
    await _database
        .child('classes')
        .child(className)
        .child('subjects')
        .child(subject)
        .child('chapters')
        .child(chapter)
        .child('chapterwise_mcqs')
        .child(mcqId)
        .remove();
  }

  Future<void> deleteMCQsByYear(String className, String subject, String chapter, int year) async {
    try {
      // Construct the database reference to the chapterwise MCQs
      final mcqsRef = _database
          .child('classes')
          .child(className)
          .child('subjects')
          .child(subject)
          .child('chapters')
          .child(chapter)
          .child('chapterwise_mcqs');

      // Fetch all MCQs from the specified chapter
      final snapshot = await mcqsRef.get();

      if (snapshot.exists) {
        final Map<dynamic, dynamic>? mcqsMap = snapshot.value as Map<dynamic, dynamic>?;

        if (mcqsMap != null) {
          // Collect keys to delete
          final keysToDelete = mcqsMap.entries
              .where((entry) =>
          entry.value != null &&
              entry.value['year'] == year)
              .map((entry) => entry.key)
              .toList();

          // Perform batch deletion
          for (final key in keysToDelete) {
            await mcqsRef.child(key).remove();
          }
        }
      }
    } catch (e) {
      print('Error deleting MCQs by year: $e');
      throw Exception('Failed to delete MCQs for year $year');
    }
  }

  Future<void> deleteQuestionsByYear(String className, String subject, String chapter, int year) async {
    try {
      // Construct the database reference to the chapterwise MCQs
      final questionsRef = _database
          .child('classes')
          .child(className)
          .child('subjects')
          .child(subject)
          .child('chapters')
          .child(chapter)
          .child('chapterwise_questions');

      // Fetch all MCQs from the specified chapter
      final snapshot = await questionsRef.get();

      if (snapshot.exists) {
        final Map<dynamic, dynamic>? questionsMap = snapshot.value as Map<dynamic, dynamic>?;

        if (questionsMap != null) {
          // Collect keys to delete
          final keysToDelete = questionsMap.entries
              .where((entry) =>
          entry.value != null &&
              entry.value['year'] == year)
              .map((entry) => entry.key)
              .toList();

          // Perform batch deletion
          for (final key in keysToDelete) {
            await questionsRef.child(key).remove();
          }
        }
      }
    } catch (e) {
      print('Error deleting MCQs by year: $e');
      throw Exception('Failed to delete MCQs for year $year');
    }
  }


  Future<void> deleteEteaChapterwiseMCQ(String subject, String chapter, String mcqId) async {
    await _database
        .child('etea_subjects')
        .child(subject)
        .child('etea_chapters')
        .child(chapter)
        .child('etea_mcqs')
        .child(mcqId)
        .remove();
  }

  Future<void> deleteEteaMCQsByYear(String subject, String chapter, int year) async {
    try {
      // Construct the database reference to the chapterwise MCQs
      final mcqsRef = _database
          .child('etea_subjects')
          .child(subject)
          .child('etea_chapters')
          .child(chapter)
          .child('etea_mcqs');

      // Fetch all MCQs from the specified chapter
      final snapshot = await mcqsRef.get();

      if (snapshot.exists) {
        final Map<dynamic, dynamic>? mcqsMap = snapshot.value as Map<dynamic, dynamic>?;

        if (mcqsMap != null) {
          // Iterate over each MCQ entry and check if it belongs to the specified year
          for (final entry in mcqsMap.entries) {
            final key = entry.key;
            final data = entry.value;

            if (data != null && data['year'] == year) {
              // Remove the MCQ entry from the database if it matches the specified year
              await mcqsRef.child(key).remove();
            }
          }
        }
      }
    } catch (e) {
      // Error handling to catch and display any issues during the deletion process
      print('Error deleting MCQs by year: $e');
      throw Exception('Failed to delete MCQs for year $year');
    }
  }


  Future<void> deleteChapterwiseQuestion(String className, String subject, String chapter, String questionId) async {
    await _database
        .child('classes')
        .child(className)
        .child('subjects')
        .child(subject)
        .child('chapters')
        .child(chapter)
        .child('chapterwise_questions')
        .child(questionId)
        .remove();
  }
}
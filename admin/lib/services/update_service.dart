import 'package:firebase_database/firebase_database.dart';
import 'package:admin/models/question_model.dart';
import '../models/mcq_model.dart';

class UpdateService {
  final FirebaseDatabase _database = FirebaseDatabase.instance;

  Future<void> updateChapterwiseMCQ(String className, String subject, String chapter,
      String mcqId, MCQ updatedMCQ) async {
    try {
      final ref = _database.ref().child('classes/$className/subjects/$subject/chapters/$chapter/chapterwise_mcqs/$mcqId');

      // First, check if the MCQ exists
      final snapshot = await ref.get();
      if (snapshot.value == null) {
        print('MCQ with ID $mcqId does not exist. Creating a new entry.');
        await ref.set(updatedMCQ.toMap());
      } else {
        // If it exists, update it
        await ref.update(updatedMCQ.toMap());
      }
    } catch (e, stackTrace) {
      print('Error updating chapterwise MCQ: $e');
      print('Stack trace: $stackTrace');
      rethrow; // Rethrow the exception so the caller can handle it
    }
  }

  Future<void> updateEteaChapterwiseMCQ(String subject, String chapter, String mcqId, MCQ updatedMCQ) async {
    final ref = _database.ref().child('etea_subjects/$subject/etea_chapters/$chapter/etea_mcqs/$mcqId');
    await ref.update(updatedMCQ.toMap());
  }

  Future<void> updateChapterwiseQuestion(String className, String subject, String chapter, Question question) async {
    final ref = _database.ref().child('classes/$className/subjects/$subject/chapters/$chapter/chapterwise_questions/${question.id}');
    await ref.update(question.toMap());
  }
}

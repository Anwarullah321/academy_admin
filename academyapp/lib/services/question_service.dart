
import '../models/question_model.dart';

class QuestionService {



  //
  // Future<List<Question>> ChapterwiseQuestions(String className, String subject, String chapter) async {
  //   try {
  //     final querySnapshot = await _firestore
  //         .collection('classes')
  //         .doc(className)
  //         .collection('subjects')
  //         .doc(subject)
  //         .collection('chapters')
  //         .doc(chapter)
  //         .collection('chapterwise_questions')
  //         .get();
  //
  //     return querySnapshot.docs.map((doc) => Question.fromMap(doc.data())).toList();
  //   } catch (e) {
  //     print('Error fetching questions for class $className, subject $subject, chapter $chapter: $e');
  //     return []; // Return empty list on error
  //   }
  // }
  //
  // Future<List<Question>> FirstHalfQuestions(String className, String subject) async {
  //   try {
  //     final querySnapshot = await _firestore
  //         .collection('classes')
  //         .doc(className)
  //         .collection('subjects')
  //         .doc(subject)
  //         .collection('first_half_questions')
  //         .get();
  //
  //     return querySnapshot.docs.map((doc) => Question.fromMap(doc.data()))
  //         .toList();
  //   } catch (e) {
  //     print(
  //         'Error fetching questions for class $className, subject $subject: $e');
  //     return []; // Return empty list on error
  //   }
  // }
  //
  // Future<List<Question>> SecondHalfQuestions(String className, String subject) async {
  //   try {
  //     final querySnapshot = await _firestore
  //         .collection('classes')
  //         .doc(className)
  //         .collection('subjects')
  //         .doc(subject)
  //         .collection('second_half_questions')
  //         .get();
  //
  //     return querySnapshot.docs.map((doc) => Question.fromMap(doc.data()))
  //         .toList();
  //   } catch (e) {
  //     print(
  //         'Error fetching questions for class $className, subject $subject: $e');
  //     return []; // Return empty list on error
  //   }
  // }
  //
  // Future<List<Question>> FullbookQuestions(String className, String subject) async {
  //   try {
  //     final querySnapshot = await _firestore
  //         .collection('classes')
  //         .doc(className)
  //         .collection('subjects')
  //         .doc(subject)
  //         .collection('fullbook_questions')
  //         .get();
  //
  //     return querySnapshot.docs.map((doc) => Question.fromMap(doc.data()))
  //         .toList();
  //   } catch (e) {
  //     print(
  //         'Error fetching questions for class $className, subject $subject: $e');
  //     return []; // Return empty list on error
  //   }
  // }

}

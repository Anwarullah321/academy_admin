import 'package:admin/models/mcq_model.dart';
import 'package:admin/models/question_model.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';

class AddService {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();

  String formatChapterName(String chapterName) {
    final parts = chapterName.split(' ');
    if (parts.length > 1) {
      final chapterNumber = int.tryParse(parts[1]);
      if (chapterNumber != null) {
        return '${parts[0]} ${chapterNumber.toString().padLeft(2, '0')}';
      }
    }
    return chapterName;
  }

  Future<void> addEteaSubject(String subject) async {
    await _database.child('etea_subjects').child(subject).set({});
  }

  Future<void> addEteaChapter(String subject, String chapter) async {
    await _database.child('etea_subjects').child(subject).child('etea_chapters').child(chapter).set({});
  }

  Future<void> addClass(String className) async {
    // Add class without random ID
    await _database.child('classes').child(className).set({'className': className});
  }

  Future<void> addSubject(String className, String subject) async {
    // Add subject directly under the specific class
    await _database.child('classes').child(className).child('subjects').child(subject).set({'subjectName': subject});
  }

  Future<void> addChapter(String className, String subject, String chapter) async {
    String formattedChapter = formatChapterName(chapter);
    // Add chapter directly under the specific subject without random ID
    await _database.child('classes').child(className)
        .child('subjects').child(subject).child('chapters').child(formattedChapter).set({'chapterName': formattedChapter});
  }

  Future<void> addChapterwiseMCQ(String className, String subject, String chapter, MCQ mcq) async {
    // Generate a new unique key for the MCQ
    String mcqKey = _database.child('classes').child(className)
        .child('subjects').child(subject)
        .child('chapters').child(chapter)
        .child('chapterwise_mcqs').push().key!;

    // Update the MCQ's id with the new key
    mcq = MCQ(
      id: mcqKey,
      question: mcq.question,
      options: mcq.options,
      correctOption: mcq.correctOption,
      year: mcq.year,
    );

    // Save the MCQ with the generated key
    await _database.child('classes').child(className)
        .child('subjects').child(subject)
        .child('chapters').child(chapter)
        .child('chapterwise_mcqs').child(mcqKey).set(mcq.toMap());
  }

  Future<void> addEteaChapterwiseMCQ(String subject, String chapter, MCQ mcq) async {
    try {


      // Generate a new unique key for the MCQ
      String mcqKey = _database.child('etea_subjects').child(subject)
          .child('etea_chapters').child(chapter)
          .child('etea_mcqs').push().key!;


      // Update the MCQ's id with the new key
      mcq = MCQ(
        id: mcqKey,
        question: mcq.question,
        options: mcq.options,
        correctOption: mcq.correctOption,
        year: mcq.year,
      );

      // Save the MCQ with the generated key
      await _database.child('etea_subjects').child(subject)
          .child('etea_chapters').child(chapter)
          .child('etea_mcqs').child(mcqKey).set(mcq.toMap());

      print('Successfully added MCQ with key: $mcqKey');
    } catch (e) {
      print('Error adding ETEA Chapterwise MCQ: $e');
      rethrow;
    }
  }

  Future<void> addChapterwiseQuestion(String className, String subject, String chapter, Question question) async {

    String questionkey = await _database.child('classes').child(className)
        .child('subjects').child(subject)
        .child('chapters').child(chapter)
        .child('chapterwise_questions').push().key!;

    question = Question(
      id: questionkey,
      question: question.question,
      year: question.year,
    ) ;

    await _database.child('classes').child(className)
        .child('subjects').child(subject)
        .child('chapters').child(chapter)
        .child('chapterwise_questions').child(questionkey).set(question.toMap());
  }

  Future<void> savePdfMetadata(String subject, String chapter, String storageRef, String title) async {
    String downloadUrl = await FirebaseStorage.instance.ref(storageRef).getDownloadURL();

    // Use title as key for saving PDF metadata
    await _database.child('etea_subjects').child(subject)
        .child('etea_chapters').child(chapter)
        .child('etea_notes').child(title).set({
      'downloadUrl': downloadUrl,
      'title': title,
    });
  }

  Future<void> savePastPaperPdfMetadata(String className, String subject, String storageRef, String title) async {
    String downloadUrl = await FirebaseStorage.instance.ref(storageRef).getDownloadURL();

    // Use title as key for saving past paper metadata
    await _database.child('classes').child(className)
        .child('subjects').child(subject)
        .child('past_papers').child(title).set({
      'downloadUrl': downloadUrl,
      'title': title,
    });
  }
}



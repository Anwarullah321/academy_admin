import 'package:admin/services/add_service.dart';
import 'package:yaml/yaml.dart';
import '../../../models/mcq_model.dart';

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

class EteaYamlCompleteUploadService {
  final AddService _addService = AddService();

  Future<void> processTextData(String textData) async {
    try {
      List<String> lines = textData.split('\n');
      if (lines.isEmpty) {
        throw Exception('No data found');
      }

      String? currentSubject;
      String? currentChapter;
      Map<String, List<MutableMCQ>> chapterMCQs = {};
      MutableMCQ? currentMcq;

      Future<void> addCurrentMcq() async {
        if (currentMcq != null && currentChapter != null) {
          if (!chapterMCQs.containsKey(currentChapter)) {
            chapterMCQs[currentChapter!] = [];
          }
          chapterMCQs[currentChapter!]!.add(currentMcq!);
          currentMcq = null;
        }
      }

      for (int i = 0; i < lines.length; i++) {
        String line = lines[i].trim();

        if (line.contains(',')) {
          // This line contains subject and chapter
          addCurrentMcq(); // Add any pending MCQ before changing chapter
          List<String> parts = line.split(',');
          if (parts.length >= 2) {
            currentSubject = parts[0].trim();
            currentChapter = parts[1].trim();
          }
        } else if (line.startsWith('Q:')) {
          addCurrentMcq(); // Add the previous MCQ before starting a new one
          currentMcq = MutableMCQ(
            id: '',
            question: line.substring(2).trim(),
            options: [],
            correctOption: -1,
            year: DateTime.now().year,
          );
        } else if (line.startsWith('A:') || line.startsWith('B:') ||
            line.startsWith('C:') || line.startsWith('D:') ||
            line.startsWith('E:')) {
          currentMcq?.options.add(line.substring(2).trim());
        } else if (line.startsWith('Ans:')) {
          String answer = line.substring(4).trim().toUpperCase();
          currentMcq?.correctOption = 'ABCDE'.indexOf(answer);
        }
      }

      // Add the last MCQ
      addCurrentMcq();

      // Upload all MCQs for each chapter
      await uploadAllMCQs(currentSubject, chapterMCQs);

    } catch (e) {
      print('Error processing text data: $e');
      rethrow;
    }
  }

  Future<void> uploadAllMCQs(String? subject, Map<String, List<MutableMCQ>> chapterMCQs) async {
    if (subject == null) {
      print('Skipping upload: subject is null');
      return;
    }

    for (var entry in chapterMCQs.entries) {
      String chapter = entry.key;
      List<MutableMCQ> mcqs = entry.value;

      if (mcqs.isNotEmpty) {
        for (var mcq in mcqs) {
          try {
            await _addService.addEteaChapterwiseMCQ(subject, chapter, mcq.toImmutableMCQ());
          } catch (e) {
            print('Error uploading MCQ: ${mcq.question}. Error: $e');
          }
        }
        print('Finished uploading MCQs for $subject, $chapter');
      } else {
        print('Skipping upload for $subject, $chapter: mcqs is empty');
      }
    }

    print('Finished uploading all MCQs for $subject');
  }
}
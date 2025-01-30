import 'dart:math';
import 'package:flutter/material.dart';
import '../../models/mcq_model.dart';
import '../../services/mcq_services.dart';
import 'history/FullBookTestHistoryPage.dart';
import 'FullBookTestPage.dart';

class FullbookTestOptionsScreen extends StatefulWidget {
  final String className;
  final String subjectName;
  final List<String> chapters;
  final MCQService mcqService;

  FullbookTestOptionsScreen({
    required this.className,
    required this.subjectName,
    required this.chapters,
    required this.mcqService,
  });

  @override
  State<FullbookTestOptionsScreen> createState() =>
      _FullbookTestOptionsScreenState();
}

class _FullbookTestOptionsScreenState extends State<FullbookTestOptionsScreen> {
  Future<List<MCQ>> _getAllChaptersMCQs() async {
    List<MCQ> selectedMCQs = [];

    for (String chapter in widget.chapters) {
      List<MCQ> mcqsForChapter = await widget.mcqService.getMCQs(
        widget.className,
        widget.subjectName,
        chapter,
      );

      List<MCQ> randomMCQs = _getRandomMCQs(mcqsForChapter, 5);
      selectedMCQs.addAll(randomMCQs);
    }

    return selectedMCQs;
  }

  List<MCQ> _getRandomMCQs(List<MCQ> mcqs, int count) {
    final random = Random();
    if (mcqs.length <= count) {
      return mcqs;
    }

    List<MCQ> randomMCQs = [];
    Set<int> selectedIndexes = {};

    while (randomMCQs.length < count) {
      int randomIndex = random.nextInt(mcqs.length);
      if (!selectedIndexes.contains(randomIndex)) {
        randomMCQs.add(mcqs[randomIndex]);
        selectedIndexes.add(randomIndex);
      }
    }
    return randomMCQs;
  }

  Widget _buildGradientButton(String text, VoidCallback onPressed) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32.0),
      child: GestureDetector(
        onTap: onPressed,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              colors: [Colors.black, Colors.yellow],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.4),
                blurRadius: 6,
                offset: Offset(2, 4),
              ),
            ],
          ),
          child: Center(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${widget.className} - ${widget.subjectName} - Full Book',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 1,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildGradientButton('MCQs Test', () async {
                final allChaptersMCQs = await _getAllChaptersMCQs();

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FullBookTestPage(
                      selectedClass: widget.className,
                      selectedSubject: widget.subjectName,
                      mcqs: allChaptersMCQs,
                    ),
                  ),
                );
              }),
              SizedBox(height: 16),
              _buildGradientButton('Test History', () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FullBookTestHistoryPage(
                      className: widget.className,
                      subjectName: widget.subjectName,
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}

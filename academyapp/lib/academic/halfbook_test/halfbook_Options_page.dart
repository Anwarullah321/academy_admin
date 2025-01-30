import 'dart:math';
import 'package:flutter/material.dart';
import '../../models/mcq_model.dart';
import '../../services/mcq_services.dart';
import 'history/HalfBookTestHistoryPage.dart';
import 'HalfBookTestPage.dart';

class HalflbookTestOptionsScreen extends StatelessWidget {
  final String className;
  final String subjectName;
  final List<String> chapters;
  final MCQService mcqService;

  HalflbookTestOptionsScreen({
    required this.className,
    required this.subjectName,
    required this.chapters,
    required this.mcqService,
  });

  Future<List<MCQ>> _getHalfBookMCQs(bool isFirstHalf) async {
    List<String> selectedChapters = isFirstHalf
        ? chapters.sublist(0, (chapters.length / 2).ceil())
        : chapters.sublist((chapters.length / 2).ceil());

    List<MCQ> selectedMCQs = [];
    for (var chapter in selectedChapters) {
      List<MCQ> mcqsForChapter = await mcqService.getMCQs(
        className,
        subjectName,
        chapter,
      );
      selectedMCQs.addAll(_getRandomMCQs(mcqsForChapter, 10));
    }
    return selectedMCQs;
  }

  List<MCQ> _getRandomMCQs(List<MCQ> mcqs, int count) {
    final random = Random();
    if (mcqs.length <= count) {
      return mcqs;
    }
    return List.generate(count, (_) => mcqs[random.nextInt(mcqs.length)]);
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
          '$className - $subjectName - Half Book Tests',
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
              _buildGradientButton('First Half MCQs Test', () async {
                final firstHalfMCQs = await _getHalfBookMCQs(true);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => HalfbookTestPage(
                      className: className,
                      subjectName: subjectName,
                      isFirstHalf: true,
                      mcqs: firstHalfMCQs,
                    ),
                  ),
                );
              }),
              SizedBox(height: 16),
              _buildGradientButton('Second Half MCQs Test', () async {
                final secondHalfMCQs = await _getHalfBookMCQs(false);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => HalfbookTestPage(
                      className: className,
                      subjectName: subjectName,
                      isFirstHalf: false,
                      mcqs: secondHalfMCQs,
                    ),
                  ),
                );
              }),
              SizedBox(height: 16),
              _buildGradientButton('Test History', () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => HalfBookTestHistoryPage(
                      className: className,
                      subjectName: subjectName,
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

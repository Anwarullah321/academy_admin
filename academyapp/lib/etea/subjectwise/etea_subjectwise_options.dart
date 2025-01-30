import 'dart:math';
import 'package:flutter/material.dart';
import '../../models/mcq_model.dart';
import '../../services/mcq_services.dart';
import 'history/EteaSubjectwiseTestHistoryPage.dart';
import 'subjectwise_mcq_screen.dart';

class EteaSubjectwiseOptionsPage extends StatefulWidget {
  final String subjectName;
  final MCQService mcqService;

  EteaSubjectwiseOptionsPage({required this.subjectName, required this.mcqService});

  @override
  _EteaSubjectwiseOptionsPageState createState() => _EteaSubjectwiseOptionsPageState();
}

class _EteaSubjectwiseOptionsPageState extends State<EteaSubjectwiseOptionsPage> {
  bool _loading = false; // To show loading state
  Map<String, List<MCQ>> _chapterwiseMCQs = {}; // Store fetched MCQs

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Etea - ${widget.subjectName}',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 1,
      ),
      body: _loading
          ? Center(child: CircularProgressIndicator()) // Show loading indicator when fetching data
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildGradientButton('MCQs Test', () async {
                setState(() {
                  _loading = true; // Start loading
                });

                // Fetch chapter-wise MCQs using mcqService
                _chapterwiseMCQs = await _getChapterwiseMCQs();

                setState(() {
                  _loading = false; // End loading
                });

                // If fetching is successful, proceed
                if (_chapterwiseMCQs.isNotEmpty) {
                  // Prepare the MCQs to pass to the quiz
                  Map<String, List<MCQ>> selectedMCQs = {};
                  _chapterwiseMCQs.forEach((chapter, mcqs) {
                    selectedMCQs[chapter] = _getRandomMCQs(mcqs, 5); // Get 5 random MCQs
                  });

                  // Navigate to quiz page with selected MCQs
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EteaSubjectwiseQuizPage(
                        selectedSubject: widget.subjectName,
                        chapterwiseMCQs: selectedMCQs,
                      ),
                    ),
                  );
                }
              }),
              SizedBox(height: 16),
              _buildGradientButton('Test History', () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EteaSubjectwiseTestHistoryPage(
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

  // Fetch MCQs from mcqService chapter-wise
  Future<Map<String, List<MCQ>>> _getChapterwiseMCQs() async {
    Map<String, List<MCQ>> chapterwiseMCQs = {};

    try {
      List<String> chapters = await widget.mcqService.getEteaChapters(widget.subjectName); // Fetch chapters

      for (String chapter in chapters) {
        List<MCQ> mcqs = await widget.mcqService.getEteaMCQs(widget.subjectName, chapter); // Fetch MCQs for each chapter
        chapterwiseMCQs[chapter] = mcqs;
      }
    } catch (e) {
      print('Error fetching MCQs: $e');
    }

    return chapterwiseMCQs;
  }

  List<MCQ> _getRandomMCQs(List<MCQ> mcqs, int count) {
    if (mcqs.length <= count) {
      return mcqs;
    }

    mcqs.shuffle(Random()); // Shuffle the list randomly
    return mcqs.take(count).toList(); // Take the first 'count' items after shuffle
  }

  Widget _buildGradientButton(String text, VoidCallback onPressed) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 12.0),
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
}

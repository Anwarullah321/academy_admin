import 'package:academyapp/services/question_service.dart';
import 'package:flutter/material.dart';
import '../../models/question_model.dart';

class SubjectiveQuizPage extends StatefulWidget {
  final String className;
  final String subject;
  final String chapter;

  SubjectiveQuizPage({
    required this.className,
    required this.subject,
    required this.chapter,
  });

  @override
  _SubjectiveQuizPageState createState() => _SubjectiveQuizPageState();
}

class _SubjectiveQuizPageState extends State<SubjectiveQuizPage> {
  final QuestionService _questionService = QuestionService();
  List<Question> _questions = [];

  @override
  void initState() {
    super.initState();
   // _loadQuestions();
  }

  // Future<void> _loadQuestions() async {
  //   final questions = await _questionService.ChapterwiseQuestions(
  //     widget.className, widget.subject, widget.chapter,
  //   );
  //   setState(() {
  //     _questions = questions..shuffle(); // Shuffle the list to get random questions
  //     if (_questions.length > 20) {
  //       _questions = _questions.take(20).toList();
  //     }
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Subjective')),
      body: _questions.isEmpty
          ? Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: _questions.length,
          itemBuilder: (context, index) {
            final question = _questions[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Q${index + 1}: ${question.question}',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  // You can add an answer field here if needed
                  Divider(),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

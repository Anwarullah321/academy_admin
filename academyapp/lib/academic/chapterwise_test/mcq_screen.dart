import 'package:academyapp/academic/chapterwise_test/ViewChapterwiseList.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:intl/intl.dart';
import '../../models/mcq_model.dart';

class QuizPage extends StatefulWidget {
  final String className;
  final String subject;
  final String chapter;
  final List<MCQ> mcqs;

  QuizPage({
    required this.className,
    required this.subject,
    required this.chapter,
    required this.mcqs,
  });

  @override
  _QuizPageState createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  Map<int, int> _selectedAnswers = {};
  ScrollController _scrollController = ScrollController();
  int _currentPage = 0;
  bool _quizResultSaved = false;
  late List<MCQ> _quizMCQs;

  @override
  void initState() {
    super.initState();
    _quizResultSaved = false;
    _selectRandomMCQs();
  }

  void _selectRandomMCQs() {
    setState(() {
      _quizMCQs = List.from(widget.mcqs)..shuffle();
      _quizMCQs = _quizMCQs.take(20).toList();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _submitQuiz() {
    int correctAnswers = 0;
    int totalQuestions = _quizMCQs.length;

    _selectedAnswers.forEach((index, selectedAnswer) {
      if (_quizMCQs[index].correctOption == selectedAnswer) {
        correctAnswers++;
      }
    });

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Test Result'),
        content: Text('You scored $correctAnswers out of $totalQuestions questions.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _showDetailedResults(correctAnswers, totalQuestions);
            },
            child: Text('VIEW RESULT'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              if (!_quizResultSaved) {
                _generateTaskName().then((taskName) {
                  _saveResults(taskName, correctAnswers, totalQuestions);
                });
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('This test result has already been saved.')),
                );
              }
            },
            child: Text('SAVE'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('CLOSE'),
          ),
        ],
      ),
    );
  }

  Future<String> _generateTaskName() async {
    final prefs = await SharedPreferences.getInstance();
    final key = '${widget.className}_${widget.subject}_${widget.chapter}_objective';
    final results = prefs.getStringList(key) ?? [];
    final taskNumber = results.length + 1;
    return 'Test $taskNumber';
  }

  void _showDetailedResults(int correctAnswers, int totalQuestions) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetailedResultsPage(
          mcqs: _quizMCQs,
          selectedAnswers: _selectedAnswers,
          correctAnswers: correctAnswers,
          totalQuestions: totalQuestions,
          levelsToPopAfterSave: 2,
          onSave: () {
            _generateTaskName().then((taskName) {
              _saveResults(taskName, correctAnswers, totalQuestions);
            });
          },
        ),
      ),
    );
  }

  Future<void> _saveResults(String taskName, int correctAnswers, int totalQuestions) async {
    if (_quizResultSaved) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('This test result has already been saved.')),
      );
      return;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final key = '${widget.className}_${widget.subject}_${widget.chapter}_objective';
      final results = prefs.getStringList(key) ?? [];

      final dateFormat = DateFormat('yyyy-MM-dd HH:mm:ss');
      final formattedDate = dateFormat.format(DateTime.now());

      final newResult = {
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'taskName': taskName,
        'date': formattedDate,
        'score': correctAnswers,
        'totalQuestions': totalQuestions,
        'summary': _generateQuizSummary(),
      };

      results.add(json.encode(newResult));
      final success = await prefs.setStringList(key, results);

      if (success) {
        setState(() {
          _quizResultSaved = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Results saved successfully')),
        );

        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save results. Please try again.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save results. Please try again.')),
      );
    }
  }

  List<Map<String, dynamic>> _generateQuizSummary() {
    return List<Map<String, dynamic>>.generate(_quizMCQs.length, (index) {
      final mcq = _quizMCQs[index];
      final selectedAnswer = _selectedAnswers[index];
      return {
        'question': mcq.question,
        'selectedAnswer': selectedAnswer != null ? mcq.options[selectedAnswer] : 'Not answered',
        'correctAnswer': mcq.options[mcq.correctOption],
        'isCorrect': selectedAnswer == mcq.correctOption,
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    final startIndex = _currentPage * 10;
    final endIndex = (startIndex + 10 < _quizMCQs.length) ? startIndex + 10 : _quizMCQs.length;
    final currentPageMCQs = _quizMCQs.sublist(startIndex, endIndex);

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.subject} - ${widget.chapter} Test'),
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Page ${_currentPage + 1}/${(_quizMCQs.length / 10).ceil()}',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              ...currentPageMCQs.asMap().entries.map((entry) {
                int index = entry.key + startIndex;
                MCQ mcq = entry.value;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Question ${index + 1}',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Text(
                      mcq.question,
                      style: TextStyle(fontSize: 16),
                    ),
                    ...mcq.options.asMap().entries.map((optionEntry) {
                      int optionIndex = optionEntry.key;
                      String option = optionEntry.value;
                      return RadioListTile<int>(
                        title: Text(option),
                        value: optionIndex,
                        groupValue: _selectedAnswers[index],
                        onChanged: (value) {
                          setState(() {
                            _selectedAnswers[index] = value!;
                          });
                        },
                      );
                    }).toList(),
                    SizedBox(height: 16),
                  ],
                );
              }).toList(),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (_currentPage > 0)
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _currentPage--;
                          _scrollController.animateTo(
                            0.0,
                            duration: Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        });
                      },
                      child: Text('Previous'),
                    )
                  else
                    Spacer(),
                  if (_currentPage < (_quizMCQs.length / 10).ceil() - 1)
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _currentPage++;
                          _scrollController.animateTo(
                            0.0,
                            duration: Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        });
                      },
                      child: Text('Next'),
                    )
                  else
                    ElevatedButton(
                      onPressed: _submitQuiz,
                      child: Text('Submit'),
                    ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
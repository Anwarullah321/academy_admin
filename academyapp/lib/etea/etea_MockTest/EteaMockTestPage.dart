import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/mcq_model.dart';
import '../../services/get_service.dart';
import '../../services/mcq_services.dart';
import 'MockTestDetailResultPage.dart';


class EteaMockTestPage extends StatefulWidget {
  final List<MCQ> mcqs;



  EteaMockTestPage({required this.mcqs});

  @override
  _EteaMockTestPageState createState() => _EteaMockTestPageState();
}

class _EteaMockTestPageState extends State<EteaMockTestPage> {

  final MCQService _mcqService = MCQService();
  List<MCQ> _mcqs = [];
  int _currentIndex = 0;
  Map<int, int> _selectedAnswers = {};
  ScrollController _scrollController = ScrollController();
  bool _isLoading = true;
  bool _hasError = false;
  final Random _random = Random();
  int _currentPage = 0;
  bool _quizResultSaved = false;
  String _loadingMessage = 'Preparing your test...';

  @override
  void initState() {
    super.initState();
    _mcqs = widget.mcqs; // Load MCQs from the widget parameter
    _isLoading = false;  // Set loading to false after initializing MCQs
    print('MCQs loaded: ${_mcqs.length}'); // Debugging
  }





  void _submitQuiz() {
    int correctAnswers = 0;
    int totalQuestions = _mcqs.length;

    _selectedAnswers.forEach((index, selectedAnswer) {
      if (_mcqs[index].correctOption == selectedAnswer) {
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
                  SnackBar(content: Text('This quiz result has already been saved.')),
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
    final key = '_MockTestobjective';
    final results = prefs.getStringList(key) ?? [];
    final taskNumber = results.length + 1;
    return 'Test $taskNumber';
  }




  void _showDetailedResults(int correctAnswers, int totalQuestions) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MockTestDetailedResultsPage(
          mcqs: _mcqs,
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
      final key = '_MockTestobjective';
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

        _navigateBackToPreviousScreen();
      } else {
        print('SharedPreferences failed to save the list.');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save results. Please try again.')),
        );
      }
    } catch (e) {
      print('Error saving results: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save results. Please try again.')),
      );
    }
  }
  void _navigateBackToPreviousScreen() {

    Navigator.pop(context); // Pop the QuizPage
  }
  List<Map<String, dynamic>> _generateQuizSummary() {
    return List<Map<String, dynamic>>.generate(_mcqs.length, (index) {
      final mcq = _mcqs[index];
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
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Etea Mock Test'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 20),
              Text(
                _loadingMessage,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text(
                'This may take a moment...',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    final startIndex = _currentPage * 10;
    final endIndex =
    (startIndex + 10 < _mcqs.length) ? startIndex + 10 : _mcqs.length;
    final currentPageMCQs = _mcqs.sublist(startIndex, endIndex);

    return Scaffold(
      appBar: AppBar(
        title: Text('Etea Mock Test'),

      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Page ${_currentPage + 1}/${(_mcqs.length / 10).ceil()}',
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
                      style:
                      TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                  if (_currentPage < (_mcqs.length / 10).ceil() - 1)
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
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
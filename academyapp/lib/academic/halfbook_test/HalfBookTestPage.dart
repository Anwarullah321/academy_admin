import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/mcq_model.dart';
import '../../services/get_service.dart';
import '../../services/mcq_services.dart';
import 'HalfBookDetailResultPage.dart';

class HalfbookTestPage extends StatefulWidget {
  final String className;
  final String subjectName;
  final bool isFirstHalf;
  final List<MCQ> mcqs;


  HalfbookTestPage({
    required this.className,
    required this.subjectName,
    required this.isFirstHalf,
    required this.mcqs
  });

  @override
  _HalfbookTestPageState createState() => _HalfbookTestPageState();
}

class _HalfbookTestPageState extends State<HalfbookTestPage> {

  late List<MCQ> _mcqs;
  Map<int, int> _selectedAnswers = {};
  ScrollController _scrollController = ScrollController();
  bool _isLoading = true;
  bool _hasError = false;
  int _currentPage = 0;
  bool _quizResultSaved = false;
  String _loadingMessage = 'Preparing your test...';
  double _loadingProgress = 0.0;
  int _batchSize = 10;
  int _totalMCQs = 0;
  Timer? _retryTimer;


  @override
  void initState() {
    super.initState();
    _quizResultSaved = false;
    _selectRandomMCQs();
  }


  void _selectRandomMCQs() {
    setState(() {
      _mcqs = List.from(widget.mcqs)..shuffle();
      _totalMCQs = _mcqs.length; // Set total MCQs
      print('Total MCQs after shuffle: $_totalMCQs'); // Check count
      _isLoading = false;
    });
  }


  @override
  void dispose() {
    _scrollController.dispose();
    _retryTimer?.cancel();
    super.dispose();
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
    final key = '${widget.className}_${widget.subjectName}_halfbookobjective';
    final results = prefs.getStringList(key) ?? [];
    final taskNumber = results.length + 1;
    return 'Test $taskNumber';
  }




  void _showDetailedResults(int correctAnswers, int totalQuestions) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => HalfBookDetailedResultsPage(
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
      final key = '${widget.className}_${widget.subjectName}_halfbookobjective';
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
      return _buildLoadingScreen();
    }

    final startIndex = _currentPage * _batchSize;
    final endIndex = (startIndex + _batchSize < _totalMCQs) ? startIndex + _batchSize : _totalMCQs;
    final currentPageMCQs = _mcqs.sublist(startIndex, endIndex);
    print('Current Page MCQs: ${currentPageMCQs.length}'); // Check if this shows 10

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.className} - ${widget.subjectName} - ${widget.isFirstHalf ? "First Half " : "Second Half "}'),
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Page ${_currentPage + 1}/${(_totalMCQs / _batchSize).ceil()}',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              ...currentPageMCQs.asMap().entries.map((entry) {
                int index = entry.key + startIndex;
                MCQ mcq = entry.value;
                return _buildMCQItem(index, mcq);
              }).toList(),
              SizedBox(height: 16),
              _buildNavigationButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingScreen() {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.className} - ${widget.subjectName} - ${widget.isFirstHalf ? "First Half " : "Second Half "}'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(value: _loadingProgress),
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

  Widget _buildMCQItem(int index, MCQ mcq) {
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
  }

  Widget _buildNavigationButtons() {
    return Row(
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
        if (_currentPage < (_totalMCQs / _batchSize).ceil() - 1)
          ElevatedButton(
            onPressed: () {
              setState(() {
                _currentPage++;
                _scrollController.jumpTo(0.0);
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
    );
  }
}
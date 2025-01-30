import 'package:flutter/material.dart';
import 'package:academyapp/etea/etea_GrandTest/EteaGrandTestPage.dart';
import 'package:academyapp/etea/etea_GrandTest/history/GrandTestHistoryPage.dart';
import 'package:academyapp/models/mcq_model.dart';
import '../../services/mcq_services.dart';

class GrandTestOptionsPage extends StatefulWidget {
  final MCQService mcqService;

  GrandTestOptionsPage({required this.mcqService});

  @override
  State<GrandTestOptionsPage> createState() => _GrandTestOptionsPageState();
}

class _GrandTestOptionsPageState extends State<GrandTestOptionsPage> {
  bool _isLoading = false;
  String _errorMessage = '';
  Map<String, String> _subjectStatus = {};

  Future<List<MCQ>> _getAllMCQs() async {
    List<MCQ> allMCQs = [];
    Map<String, int> subjectCounts = {
      'Chemistry': 60,
      'Biology': 60,
      'Physics': 60,
      'English': 20
    };

    _subjectStatus.clear();
    bool hasError = false;

    for (var entry in subjectCounts.entries) {
      try {
        List<MCQ> subjectMCQs = await widget.mcqService.getRandomSubjectMCQs(
          entry.key,
          entry.value,
        );

        if (subjectMCQs.length == entry.value) {
          allMCQs.addAll(subjectMCQs);
          _subjectStatus[entry.key] = 'Success: ${subjectMCQs.length} MCQs fetched';
        } else {
          hasError = true;
          _subjectStatus[entry.key] =
          'Error: Expected ${entry.value}, got ${subjectMCQs.length}';
        }
      } catch (e) {
        hasError = true;
        _subjectStatus[entry.key] = 'Error: ${e.toString()}';
      }
    }

    if (hasError) {
      throw Exception('Failed to fetch required MCQs for some subjects');
    }

    allMCQs.shuffle();
    return allMCQs;
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


  Future<void> _startTest() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      List<MCQ> grandTestMCQs = await _getAllMCQs();
      if (!mounted) return;

      int expectedTotal = 200; // Total MCQs expected
      if (grandTestMCQs.length != expectedTotal) {
        setState(() {
          _errorMessage = 'Incorrect number of MCQs loaded (Expected: $expectedTotal, Got: ${grandTestMCQs.length}).\n\n' +
              _subjectStatus.entries.map((e) => '${e.key}: ${e.value}').join('\n');
        });
        return;
      }

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => EteaGrandTestPage(mcqs: grandTestMCQs),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Failed to load MCQs:\n\n' +
            _subjectStatus.entries.map((e) => '${e.key}: ${e.value}').join('\n');
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'ETEA Grand Test',
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
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: _isLoading
              ? Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text(
                'Loading MCQs...',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              if (_subjectStatus.isNotEmpty)
                ..._subjectStatus.entries.map(
                      (entry) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Text(
                      '${entry.key}: ${entry.value}',
                      style: TextStyle(
                        color: entry.value.startsWith('Error')
                            ? Colors.red
                            : Colors.green,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
            ],
          )
              : Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_errorMessage.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    _errorMessage,
                    style: TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                ),
              _buildGradientButton('Start Test', _startTest),
              SizedBox(height: 16),
              _buildGradientButton('View History', () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => GrandTestHistoryPage(),
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

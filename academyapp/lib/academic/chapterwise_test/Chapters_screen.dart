import 'package:flutter/material.dart';
import 'package:academyapp/models/mcq_model.dart';
import 'package:academyapp/academic/chapterwise_test/history/TestHistoryPage.dart';
import '../../services/mcq_services.dart';
import 'mcq_screen.dart';
import 'question_quiz_screen.dart';

class ChaptersScreen extends StatefulWidget {
  final String className;
  final String subjectName;
  final List<String> chapters;
  final MCQService mcqService;

  ChaptersScreen({
    required this.className,
    required this.subjectName,
    required this.chapters,
    required this.mcqService,
  });

  @override
  _ChaptersScreenState createState() => _ChaptersScreenState();
}

class _ChaptersScreenState extends State<ChaptersScreen> {
  bool _showChapters = true;
  String? _selectedChapter;
  List<MCQ> _chapterMCQs = [];

  @override
  void initState() {
    super.initState();
    widget.chapters.sort((a, b) {
      final numA = _extractNumberFromString(a);
      final numB = _extractNumberFromString(b);
      return numA.compareTo(numB);
    });
  }

  int _extractNumberFromString(String chapter) {
    final match = RegExp(r'\d+').firstMatch(chapter);
    return match != null ? int.parse(match.group(0)!) : 0;
  }

  void _onChapterTap(String chapter) async {
    List<MCQ> mcqs = await widget.mcqService.getMCQs(
      widget.className,
      widget.subjectName,
      chapter,
    );
    mcqs.shuffle();
    setState(() {
      _selectedChapter = chapter;
      _showChapters = false;
      _chapterMCQs = mcqs.length >= 100 ? mcqs.sublist(0, 100) : mcqs;
    });
  }

  Widget _buildChapterList() {
    return ListView.builder(
      itemCount: widget.chapters.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 2,
            color: Colors.yellow,
            child: ListTile(
              title: Text(
                widget.chapters[index],
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
              ),
              trailing: Icon(Icons.arrow_forward_ios, color: Colors.grey[600]),
              onTap: () => _onChapterTap(widget.chapters[index]),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTestOptions() {
    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildGradientButton('MCQs Test', () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => QuizPage(
                    className: widget.className,
                    subject: widget.subjectName,
                    chapter: _selectedChapter!,
                    mcqs: _chapterMCQs,
                  ),
                ),
              );
            }),
            SizedBox(height: 16),
            _buildGradientButton('Subjective Test', () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SubjectiveQuizPage(
                    className: widget.className,
                    subject: widget.subjectName,
                    chapter: _selectedChapter!,
                  ),
                ),
              );
            }),
            SizedBox(height: 16),
            _buildGradientButton('Test History', () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TestHistoryPage(
                    className: widget.className,
                    subjectName: widget.subjectName,
                    chapter: _selectedChapter!,
                  ),
                ),
              );
            }),
            SizedBox(height: 16),
            TextButton(
              onPressed: () {
                setState(() {
                  _showChapters = true;
                  _selectedChapter = null;
                  _chapterMCQs = [];
                });
              },
              child: Text(
                'Back to Chapters',
                style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
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
        title: Text('${widget.subjectName} Chapters'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 1,
      ),
      body: _showChapters ? _buildChapterList() : _buildTestOptions(),
    );
  }
}

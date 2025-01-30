import 'package:academyapp/etea/etea_chapterwise/etea_key_notes.dart';
import 'package:flutter/material.dart';
import '../../models/mcq_model.dart';
import '../../services/mcq_services.dart';
import 'history/EteaTestHistoryPage.dart';
import 'chapterwise_mcq_screen.dart';

class EteaChapterwiseChaptersScreen extends StatefulWidget {
  final String subjectName;
  final List<String> chapters;
  final MCQService mcqService;

  EteaChapterwiseChaptersScreen({
    required this.subjectName,
    required this.chapters,
    required this.mcqService,
  });

  @override
  _EteaChapterwiseChaptersScreenState createState() =>
      _EteaChapterwiseChaptersScreenState();
}

class _EteaChapterwiseChaptersScreenState
    extends State<EteaChapterwiseChaptersScreen> {
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
    try {
      List<MCQ> mcqs =
      await widget.mcqService.getEteaMCQs(widget.subjectName, chapter);
      mcqs.shuffle();

      setState(() {
        _selectedChapter = chapter;
        _showChapters = false;
        _chapterMCQs = mcqs.length >= 100 ? mcqs.sublist(0, 100) : mcqs;
      });
    } catch (e) {
      print('Error fetching MCQs: $e');
    }
  }

  Widget _buildChapterList() {
    return ListView.builder(
      key: ValueKey<bool>(_showChapters),
      itemCount: widget.chapters.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 4,
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

  Widget _buildTestOptions() {
    return Center(
      child: SingleChildScrollView(
        child: Column(
          key: ValueKey<String>(_selectedChapter!),
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildGradientButton('Key Notes', () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DisplayPdfScreen(
                    selectedSubject: widget.subjectName,
                    selectedChapter: _selectedChapter!,
                  ),
                ),
              );
            }),
            SizedBox(height: 16),
            _buildGradientButton('MCQs Test', () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EteaChapterwiseQuizPage(
                    subject: widget.subjectName,
                    chapter: _selectedChapter!,
                    mcqs: _chapterMCQs,
                  ),
                ),
              );
            }),
            SizedBox(height: 16),
            _buildGradientButton('Test History', () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EteaChapterwiseTestHistoryPage(
                    subjectName: widget.subjectName,
                    chapter: _selectedChapter!,
                  ),
                ),
              );
            }),
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
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Etea - ${widget.subjectName}',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
        ),
        backgroundColor: Colors.white,

      ),
      body: _showChapters ? _buildChapterList() : _buildTestOptions(),
    );
  }
}

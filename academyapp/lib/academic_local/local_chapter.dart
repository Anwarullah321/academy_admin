import 'package:academyapp/academic_local/history/TestHistoryPage.dart';
import 'package:flutter/material.dart';
import '../models/mcq_model.dart';
import '../services/mcq_services.dart';
import '../whatsapp.dart';
import 'local_mcqs.dart';

class ChapterScreen extends StatefulWidget {
  final String selectedClass;
  final String selectedSubject;

  ChapterScreen({required this.selectedClass, required this.selectedSubject});

  @override
  _ChapterScreenState createState() => _ChapterScreenState();
}

class _ChapterScreenState extends State<ChapterScreen> {
  final MCQService _mcqService = MCQService();
  late List<String> _chapters = [];
  late List<MCQ> _mcqs = [];
  bool _showChapters = true;
  String? _selectedChapter;
  bool _isLoading = true;
  bool _isFetchingMCQs = false;

  @override
  void initState() {
    super.initState();
    _loadChapters();
  }

  Future<void> _loadChapters() async {
    await _mcqService.loadData();
    final chapters =
    await _mcqService.getPreLocalChapters(widget.selectedClass, widget.selectedSubject);

    setState(() {
      _chapters = chapters;
    });
  }

  Future<void> _onChapterTap(String chapter) async {
    setState(() {
      _selectedChapter = chapter;
      _isFetchingMCQs = true;
      _showChapters = false;
    });

    try {
      final mcqs = await _mcqService.getPreLocalMCQs(widget.selectedClass, widget.selectedSubject, chapter);
      setState(() {
        _mcqs = mcqs;
        _isFetchingMCQs = false;
      });
    } catch (e) {
      print("Error fetching MCQs: $e");
      setState(() {
        _isFetchingMCQs = false;
      });
    }
  }

  Widget _buildChapterList() {
    return ListView.builder(
      key: ValueKey<bool>(_showChapters),
      itemCount: _chapters.length,
      itemBuilder: (context, index) {
        final chapter = _chapters[index];
        final isUnlocked = index == 0;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 4,
            color: Colors.yellow,
            child: ListTile(
              title: Text(
                chapter,
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
              ),
              trailing: isUnlocked
                  ? Icon(Icons.arrow_forward_ios, color: Colors.grey[600])
                  : Icon(Icons.lock, color: Colors.black),
              onTap: isUnlocked
                  ? () => _onChapterTap(chapter)
                  : () => _showLockedChapterDialog(context),
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
            _buildGradientButton('MCQs Test', () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => LocalMCQPage(
                    mcqs: _mcqs,
                    selectedClass: widget.selectedClass,
                    selectedSubject: widget.selectedSubject,
                    selectedChapter: _selectedChapter!,
                  ),
                ),
              );
            }),
            SizedBox(height: 16),
            _buildGradientButton('Test History', () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => LocalTestHistoryPage(
                    selectedClass: widget.selectedClass,
                    selectedSubject: widget.selectedSubject,
                    selectedChapter: _selectedChapter!,
                  ),
                ),
              );
            }),
            TextButton(
              onPressed: () {
                setState(() {
                  _showChapters = true;
                  _selectedChapter = null;
                  _mcqs = [];
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

  void _showLockedChapterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Feature Locked'),
          content: Text('This chapter is available only for paid users. Do you want to buy it?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => StudentRequestPage(), // Replace with your buy page widget
                  ),
                );
              },
              child: Text('Buy'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${widget.selectedSubject}',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
        ),
        backgroundColor: Colors.white,

      ),
      body: _showChapters ? _buildChapterList() : _buildTestOptions(),
    );
  }
}



import 'package:academyapp/etea/etealocal/history/TestHistoryPage.dart';
import 'package:flutter/material.dart';
import '../../models/mcq_model.dart';
import '../../services/mcq_services.dart';
import '../../widgets/lock.dart';
import 'etea_local_mcqs.dart';

class EteaChapterScreen extends StatefulWidget {
  final String selectedSubject;

  EteaChapterScreen({required this.selectedSubject});

  @override
  _EteaChapterScreenState createState() => _EteaChapterScreenState();
}

class _EteaChapterScreenState extends State<EteaChapterScreen> {
  final MCQService _mcqService = MCQService();
  late List<String> _chapters = [];
  bool _showChapters = true;
  String? _selectedChapter;
  late List<MCQ> _mcqs = [];
  bool _isFetchingMCQs = false;

  @override
  void initState() {
    super.initState();
    _loadChapters();
  }

  Future<void> _loadChapters() async {
    await _mcqService.loadEteaData();
    final chapters = await _mcqService.getEteaPreLocalChapters(widget.selectedSubject);

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
      final mcqs = await _mcqService.getEteaPreLocalMCQs(widget.selectedSubject, chapter);
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
        final isLocked = index != 0;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            color: Colors.yellow,
            elevation: 4,
            child: ListTile(
              title: Text(
                _chapters[index],
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
              ),
              trailing: Icon(
                isLocked ? Icons.lock : Icons.arrow_forward_ios,
                color: isLocked ? Colors.black : Colors.grey[600],
              ),
              onTap: () {
                if (isLocked) {
                  showLockedFeatureDialog(context);
                } else {
                  _onChapterTap(_chapters[index]);
                }
              },
            ),
          ),
        );
      },
    );
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

  Widget _buildTestOptions() {
    return Center(
      child: SingleChildScrollView(
        child: Column(
          key: ValueKey<String>(_selectedChapter ?? 'NoChapter'),
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildGradientButton('MCQs Test', () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EteaLocalMCQPage(
                    mcqs: _mcqs,
                    selectedSubject: widget.selectedSubject,
                    selectedChapter: _selectedChapter!,
                  ),
                ),
              );
            }),
            _buildGradientButton('Test History', () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EteaLocalTestHistoryPage(
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



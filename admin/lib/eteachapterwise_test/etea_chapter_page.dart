import 'package:admin/constants/colors.dart';
import 'package:admin/services/get_service.dart';
import 'package:flutter/material.dart';
import '../loginscreen.dart';
import 'etea_detail_page.dart';

class SelectChapterPage extends StatefulWidget {
  final String selectedSubject;

  const SelectChapterPage({
    Key? key,
    required this.selectedSubject,
  }) : super(key: key);

  @override
  _SelectChapterPageState createState() => _SelectChapterPageState();
}

class _SelectChapterPageState extends State<SelectChapterPage> {
  final GetService _getService = GetService();
  List<String> _chapters = [];
  Map<String, bool> _isHovered = {};

  @override
  void initState() {
    super.initState();
    _loadChapters();
  }

  Future<void> _loadChapters() async {
    final chapters = await _getService.getEteaChapters(widget.selectedSubject);
    setState(() {
      _chapters = chapters;
      for (var chapter in _chapters) {
        _isHovered[chapter] = false;
      }
    });
  }

  void _navigateToChapterDetail(String chapter) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChapterDetailPage(
          selectedSubject: widget.selectedSubject,
          selectedChapter: chapter,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: customYellow,
        elevation: 0,
        actions: [
          TextButton.icon(
            icon: Icon(Icons.exit_to_app),
            label: Text('Logout'),
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => LoggedInScreen()),
                    (Route<dynamic> route) => false,
              );
            },
          ),
        ],
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'ETEA',
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              widget.selectedSubject,
              style: TextStyle(
                color: darkGrey,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _chapters.isEmpty
            ? Center(
          child: CircularProgressIndicator(),
        )
            : GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 6,
            crossAxisSpacing: 16.0,
            mainAxisSpacing: 16.0,
            childAspectRatio: 1,
          ),
          itemCount: _chapters.length,
          itemBuilder: (context, index) {
            String currentChapter = _chapters[index];
            bool isHovered = _isHovered[currentChapter] ?? false;
            return MouseRegion(
              cursor: SystemMouseCursors.click,
              onEnter: (_) {
                setState(() {
                  _isHovered[currentChapter] = true;
                });
              },
              onExit: (_) {
                setState(() {
                  _isHovered[currentChapter] = false;
                });
              },
              child: GestureDetector(
                onTap: () => _navigateToChapterDetail(currentChapter),
                child: Transform.scale(
                  scale: isHovered ? 1.1 : 1.0,
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    elevation: 5.0,
                    child: AnimatedContainer(
                      duration: Duration(milliseconds: 200),
                      padding: EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: customYellow,
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      child: Center(
                        child: Text(
                          currentChapter,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 17.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

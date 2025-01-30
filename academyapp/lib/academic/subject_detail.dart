import 'package:flutter/material.dart';

import 'package:academyapp/academic/past_papers/past_paper.dart';
import 'package:academyapp/academic/chapterwise_test/Chapters_screen.dart';
import 'package:academyapp/academic/halfbook_test/halfbook_Options_page.dart';
import 'package:academyapp/academic/fullbook_test/FullBookOptionsPage.dart';

import '../services/mcq_services.dart';

class SubjectDetailPage extends StatefulWidget {
  final String className;
  final String subjectName;
  final List<String> chapters;
  final MCQService mcqService;

  SubjectDetailPage({
    required this.className,
    required this.subjectName,
    required this.chapters,
    required this.mcqService,
  });

  @override
  _SubjectDetailPageState createState() => _SubjectDetailPageState();
}

class _SubjectDetailPageState extends State<SubjectDetailPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.subjectName} - Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildOptionCard(
              context,
              'Chapterwise Tests',
              Icons.book,
              Colors.black,
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChaptersScreen(
                      className: widget.className,
                      subjectName: widget.subjectName,
                      chapters: widget.chapters,
                      mcqService: widget.mcqService,
                    ),
                  ),
                );
              },
            ),
            _buildOptionCard(
              context,
              'Half Book Test',
              Icons.book_online,
              Colors.black,
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => HalflbookTestOptionsScreen(
                      className: widget.className,
                      subjectName: widget.subjectName,
                      chapters: widget.chapters,
                      mcqService: widget.mcqService,
                    ),
                  ),
                );
              },
            ),
            _buildOptionCard(
              context,
              'Full Book Test',
              Icons.book_online,
              Colors.black,
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FullbookTestOptionsScreen(
                      className: widget.className,
                      subjectName: widget.subjectName,
                      chapters: widget.chapters,
                      mcqService: widget.mcqService,
                    ),
                  ),
                );
              },
            ),
            _buildOptionCard(
              context,
              'Past Papers (Last 3 Years)',
              Icons.history_edu,
              Colors.black,
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DisplayPastPaperPdfScreen(
                      selectedClass: widget.className,
                      selectedSubject: widget.subjectName,
                    ),
                  ),
                );
              },
            ),
            _buildOptionCard(
              context,
              'Online/Video Lectures',
              Icons.video_library,
              Colors.black,
              () {
                // Implement online/video lectures navigation
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionCard(BuildContext context, String title, IconData icon,
      Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 4,
        color: Colors.yellow,
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 3.5),
        child: ListTile(
          leading: Icon(icon, color: color, size: 36),
          title: Text(
            title,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          trailing: Icon(Icons.arrow_forward, color: color),
        ),
      ),
    );
  }
}

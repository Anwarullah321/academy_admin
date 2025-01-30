import 'package:flutter/material.dart';

import 'package:academyapp/academic/past_papers/past_paper.dart';
import 'package:academyapp/academic/chapterwise_test/Chapters_screen.dart';
import 'package:academyapp/academic/halfbook_test/halfbook_Options_page.dart';
import 'package:academyapp/academic/fullbook_test/FullBookOptionsPage.dart';

import '../services/mcq_services.dart';
import '../whatsapp.dart';
import '../widgets/lock.dart';
import 'local_chapter.dart';

class localSubjectDetailPage extends StatefulWidget {
  final String selectedClass;
  final String selectedSubject;

  localSubjectDetailPage({required this.selectedClass, required this.selectedSubject});

  @override
  _localSubjectDetailPageState createState() => _localSubjectDetailPageState();
}

class _localSubjectDetailPageState extends State<localSubjectDetailPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.selectedSubject} - Details'),
        backgroundColor: Colors.white,
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
                    builder: (context) =>
                        ChapterScreen(
                          selectedClass: widget.selectedClass,
                          selectedSubject: widget.selectedSubject,
                        ),
                  ),
                );
              },
            ),
            buildLockedOptionCard(
              context,
              'Half Book Test',
              Icons.book_online,
              Colors.black,
            ),
            buildLockedOptionCard(
              context,
              'Full Book Test',
              Icons.book_online,
              Colors.black,
            ),
            buildLockedOptionCard(
              context,
              'Past Papers (Last 3 Years)',
              Icons.history_edu,
              Colors.black,
            ),
            buildLockedOptionCard(
              context,
              'Online/Video Lectures',
              Icons.video_library,
              Colors.black,
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



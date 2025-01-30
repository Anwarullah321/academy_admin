import 'package:flutter/material.dart';

import 'package:academyapp/etea/etea_chapterwise/chapterwise_options_Page.dart';
import 'package:academyapp/etea/subjectwise/etea_subjectwise_options.dart';

import '../../whatsapp.dart';
import '../../widgets/lock.dart';
import 'etea_local_chapters.dart';

class LocalEteaSubjectDetailPage extends StatefulWidget {
  final String subjectName;

  LocalEteaSubjectDetailPage({
    required this.subjectName,
  });

  @override
  _LocalEteaSubjectDetailPageState createState() => _LocalEteaSubjectDetailPageState();
}

class _LocalEteaSubjectDetailPageState extends State<LocalEteaSubjectDetailPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.subjectName} - Details'),
        backgroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildOptionCard(
              context,
              'ETEA Chapterwise Test',
              Icons.book_online,
              Colors.black,
                  () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EteaChapterScreen(
                      selectedSubject: widget.subjectName,
                    ),
                  ),
                );
              },
            ),
            buildLockedOptionCard(
              context,
              'ETEA Subjectwise Test',
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


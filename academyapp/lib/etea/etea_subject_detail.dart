import 'package:flutter/material.dart';
import '../models/mcq_model.dart';
import 'package:academyapp/etea/etea_chapterwise/chapterwise_options_Page.dart';
import 'package:academyapp/etea/subjectwise/etea_subjectwise_options.dart';

import '../services/mcq_services.dart';

class EteaSubjectDetailPage extends StatefulWidget {
  final String subjectName;
  final MCQService mcqService;
  final List<String> chapters;

  EteaSubjectDetailPage({required this.subjectName,
  required this.mcqService,
    required this.chapters
  });

  @override
  _EteaSubjectDetailPageState createState() => _EteaSubjectDetailPageState();
}

class _EteaSubjectDetailPageState extends State<EteaSubjectDetailPage> {


  @override
  void initState() {

    super.initState();


  }



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
              'ETEA Chapterwise Test',
              Icons.book_online,
              Colors.black,
                  () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EteaChapterwiseChaptersScreen(
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
              'ETEA Subjectwise Test',
              Icons.history_edu,
              Colors.black,
                  () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EteaSubjectwiseOptionsPage(
                      subjectName: widget.subjectName,
                      mcqService: widget.mcqService,
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
                // Placeholder: Add functionality to navigate to Online/Video Lectures page
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionCard(BuildContext context, String title, IconData? icon, Color color, VoidCallback? onTap, {Key? key, bool isLoading = false}) {
    return GestureDetector(
      onTap: !isLoading ? onTap : null,
      child: Card(
        elevation: 4,
        color: Colors.yellow,
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 3.5),
        child: ListTile(
          leading: icon != null
              ? isLoading
              ? CircularProgressIndicator(color: color)
              : Icon(icon, color: color, size: 36)
              : null,
          title: Text(
            title,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          trailing: !isLoading
              ? Icon(Icons.arrow_forward, color: color)
              : null,
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:academyapp/models/mcq_model.dart';

import '../services/mcq_services.dart';
import 'subject_detail.dart';

class SubjectGridPage extends StatelessWidget {
  final String className;
  final List<String> subjects;
  final MCQService mcqService;

  SubjectGridPage({
    required this.className,
    required this.subjects,
    required this.mcqService,
  });

  void _navigateToSubjectDetail(BuildContext context, String subjectName) async {
    List<String> chapters = await mcqService.getChapters(className, subjectName);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SubjectDetailPage(
          className: className,
          subjectName: subjectName,
          chapters: chapters,
          mcqService: mcqService,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Subjects for $className'),
      backgroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 3 / 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemCount: subjects.length,
          itemBuilder: (context, index) {
            String subject = subjects[index];
            return GestureDetector(
              onTap: () => _navigateToSubjectDetail(context, subject),
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),

                color: Colors.yellow,
                child: Center(
                  child: Text(
                    subject,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
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
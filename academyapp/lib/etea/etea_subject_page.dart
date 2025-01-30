import 'package:academyapp/models/mcq_model.dart';
import 'package:academyapp/services/mcq_services.dart';
import 'package:flutter/material.dart';
import 'package:academyapp/etea/etea_subject_detail.dart';
import 'package:academyapp/etea/etea_GrandTest/EteaGrandTestOptionsPage.dart';
import 'package:academyapp/etea/etea_MockTest/EteaMockTestOptionsPage.dart';

class EteaSubjectGridPage extends StatelessWidget {
  final List<String> subjects;
  final MCQService mcqService;


  EteaSubjectGridPage({
    required this.subjects,
    required this.mcqService,

  });

  // Function to navigate to the subject detail page
  Future<void> _navigateToSubjectDetail(BuildContext context, String subjectName) async {
    List<String> chapters = await mcqService.getEteaChapters(subjectName);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EteaSubjectDetailPage(
          subjectName: subjectName,
          chapters: chapters,
          mcqService: mcqService,
        ),
      ),
    );
    print("etea chapters are: $chapters");

  }

  // Function to navigate to different pages based on option selected
  void _navigateToPage(BuildContext context, String option) {
    if (option == 'ETEA Mock Test') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MockTestOptionsPage(
            mcqService: mcqService,
          ),
        ),
      );
    } else if (option == 'ETEA Grand Test') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => GrandTestOptionsPage(
            mcqService: mcqService,

          ),
        ),
      );
    } else {
      // For subjects, call the navigateToSubjectDetail function
      _navigateToSubjectDetail(context, option);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('ETEA Subjects')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 3 / 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: subjects.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      _navigateToPage(context, subjects[index]);
                    },
                    child: Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      color: Colors.yellow,
                      child: Center(
                        child: Text(
                          subjects[index],
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _navigateToPage(context, 'ETEA Mock Test'),
              child: Text('ETEA Mock Test'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.yellow),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => _navigateToPage(context, 'ETEA Grand Test'),
              child: Text('ETEA Grand Test'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.yellow),
            ),
          ],
        ),
      ),
    );
  }
}

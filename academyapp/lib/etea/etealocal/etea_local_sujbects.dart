import 'package:flutter/material.dart';

import '../../services/mcq_services.dart';
import 'etea_local_chapters.dart';
import 'etea_local_subject_detail.dart';


class EteaSubjectScreen extends StatefulWidget {




  @override
  _EteaSubjectScreenState createState() => _EteaSubjectScreenState();
}

class _EteaSubjectScreenState extends State<EteaSubjectScreen> {
  final MCQService _mcqService = MCQService();
  late List<String> _subjects = [];

  @override
  void initState() {
    super.initState();
    _loadEteaSubjects();
  }



  Future<void> _loadEteaSubjects() async {
   await _mcqService.loadEteaData();
    final subjects = await _mcqService.getEteaPreLocalSubjects();
    setState(() {
      _subjects = subjects;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Etea Subjects'),
        backgroundColor: Colors.white,
      ),
      body: _subjects == null
          ? Center(child: CircularProgressIndicator())
          : _buildSubjectGrid(),
    );
  }

  Widget _buildSubjectGrid() {
    return GridView.builder(
      padding: EdgeInsets.all(16.0),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16.0,
        mainAxisSpacing: 16.0,
      ),
      itemCount: _subjects.length,
      itemBuilder: (context, index) {
        final subject = _subjects[index];
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => LocalEteaSubjectDetailPage(
                  subjectName: subject,
                ),
              ),
            );
          },
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
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        );
      },
    );
  }
}

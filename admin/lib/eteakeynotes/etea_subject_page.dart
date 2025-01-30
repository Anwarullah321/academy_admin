import 'package:admin/eteachapterwise_test/etea_chapter_page.dart';
import 'package:admin/services/get_service.dart';
import 'package:flutter/material.dart';

import 'etea_chapter_page.dart';




class EteaKeyNotesSubjectPage extends StatefulWidget {


  const EteaKeyNotesSubjectPage({Key? key}) : super(key: key);

  @override
  _EteaKeyNotesSubjectPageState createState() => _EteaKeyNotesSubjectPageState();
}

class _EteaKeyNotesSubjectPageState extends State<EteaKeyNotesSubjectPage> {
  final GetService _getService = GetService();
  List<String> _subjects = [];

  @override
  void initState() {
    super.initState();
    _loadSubjects();
  }

  Future<void> _loadSubjects() async {
    final subjects = await _getService.getEteaSubjects();
    setState(() {
      _subjects = subjects;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Select Subject')),
      body: ListView.builder(
        itemCount: _subjects.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(_subjects[index]),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EteaKeyNotesChapterPage(
                    selectedSubject: _subjects[index],

                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

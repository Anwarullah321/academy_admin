import 'package:academyapp/services/mcq_services.dart';
import 'package:flutter/material.dart';

import 'local_subject_detail.dart';

class SubjectScreen extends StatefulWidget {
  final String selectedClass;

  SubjectScreen({required this.selectedClass});

  @override
  _SubjectScreenState createState() => _SubjectScreenState();
}

class _SubjectScreenState extends State<SubjectScreen> {
  final MCQService _mcqService = MCQService();
  late List<String> _subjects = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSubjects();
  }

  Future<void> _loadSubjects() async {
    try {
      await _mcqService.loadData();
      final subjects = await _mcqService.getPreLocalSubjects(widget.selectedClass);
      setState(() {
        _subjects = subjects;
        _isLoading = false;
      });
    } catch (e) {
      print("Error loading subjects: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Subjects for ${widget.selectedClass}',
          style: TextStyle(color: Colors.black),

        ),
backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: Colors.black))
          : _subjects.isEmpty
          ? Center(
        child: Text(
          'No subjects available.',
          style: TextStyle(fontSize: 18.0, color: Colors.black),
        ),
      )
          : _buildSubjectGrid(),
    );
  }

  Widget _buildSubjectGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(16.0),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16.0,
        mainAxisSpacing: 16.0,
        childAspectRatio: 3 / 2, // Adjusted for better proportions
      ),
      itemCount: _subjects.length,
      itemBuilder: (context, index) {
        final subject = _subjects[index];
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => localSubjectDetailPage(
                  selectedClass: widget.selectedClass,
                  selectedSubject: subject,
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
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.2,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        );
      },
    );
  }
}

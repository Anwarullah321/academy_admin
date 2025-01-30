import 'package:flutter/material.dart';
import 'package:academyapp/academic/subject_screen.dart';
import 'package:academyapp/etea/etea_subject_page.dart';
import 'package:academyapp/whatsapp.dart';

import '../academic_local/local_subject.dart';
import '../etea/etealocal/etea_local_sujbects.dart';
import '../services/mcq_services.dart';

final MCQService _mcqService = MCQService();

void navigateToWhatsApp(BuildContext context) {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => StudentRequestPage()),
  );
}

void navigateToEteaSubjects(BuildContext context, bool isLocal) {
  if (isLocal) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EteaSubjectScreen(),
      ),
    );
  } else {
    _mcqService.getEteaSubjects().then((subjects) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => EteaSubjectGridPage(
            mcqService: _mcqService,
            subjects: subjects,
          ),
        ),
      );
    });
  }
}

Future<void> navigateToClassSubjects(BuildContext context, String className, bool isLocal) async {
  if (isLocal) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SubjectScreen(selectedClass: className),
      ),
    );
  } else {
    List<String> subjects = await _mcqService.getSubjects(className);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SubjectGridPage(
          className: className,
          subjects: subjects,
          mcqService: _mcqService,
        ),
      ),
    );
  }
}


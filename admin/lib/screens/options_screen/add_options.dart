import 'package:flutter/material.dart';

import '../add_screens/add_mcqs.dart';
import '../add_screens/add_question.dart';



class AddOptionsDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Add Options'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              showDialog(
                context: context,
                builder: (context) => AddMCQPage(),
              );
            },
            child: Text('Add MCQ'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              showDialog(
                context: context,
                builder: (context) => AddQuestionPage(),
              );
            },
            child: Text('Add Question'),
          ),
        ],
      ),
    );
  }
}
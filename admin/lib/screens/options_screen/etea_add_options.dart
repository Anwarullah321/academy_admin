import 'package:flutter/material.dart';
import '../add_screens/etea/etea_add_chapterwise.dart';
import '../add_screens/etea/etea_key_notes.dart';


class EteaAddOptionsDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Select Category'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => UploadPdfScreen()),
              );
            },
            child: Text('ETEA Key Notes'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddETEAMCQPage()),
              );
            },
            child: Text('ETEA Chapterwise MCQS'),
          ),

          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('Online/Video Lectures'),
          ),

        ],
      ),
    );
  }
}
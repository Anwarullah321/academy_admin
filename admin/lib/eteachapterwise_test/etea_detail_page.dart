import 'package:admin/screens/view_screens/etea_view/etea_view_chapterwise.dart';

import 'package:flutter/material.dart';

import '../constants/colors.dart';
import '../loginscreen.dart';


class ChapterDetailPage extends StatefulWidget {
  final String selectedSubject;
  final String selectedChapter;

  const ChapterDetailPage({
    Key? key,
    required this.selectedSubject,
    required this.selectedChapter,
  }) : super(key: key);

  @override
  _ChapterDetailPageState createState() => _ChapterDetailPageState();
}

class _ChapterDetailPageState extends State<ChapterDetailPage> {


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: customYellow,
        elevation: 0,
        actions: [
          TextButton.icon(
            icon: Icon(Icons.exit_to_app),
            label: Text('Logout'),
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => LoggedInScreen()),
                    (Route<dynamic> route) => false,
              );
            },
          ),
        ],
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'ETEA',
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '${widget.selectedSubject} - ${widget.selectedChapter}',
              style: const TextStyle(
                color: darkGrey,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [

          Expanded(
            child: ViewEteaMCQsPage(
              selectedSubject: widget.selectedSubject,
              selectedChapter: widget.selectedChapter,
            )

          ),
        ],
      ),
    );
  }
}

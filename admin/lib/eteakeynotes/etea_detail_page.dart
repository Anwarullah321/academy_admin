import 'package:flutter/material.dart';
import '../screens/view_screens/etea_view/etea_view_keynotes.dart';


class KeyNotesChapterDetailPage extends StatefulWidget {
  final String selectedSubject;
  final String selectedChapter;

  const KeyNotesChapterDetailPage({
    Key? key,
    required this.selectedSubject,
    required this.selectedChapter,
  }) : super(key: key);

  @override
  _KeyNotesChapterDetailPageState createState() => _KeyNotesChapterDetailPageState();
}

class _KeyNotesChapterDetailPageState extends State<KeyNotesChapterDetailPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Select PDF')),
      body: Column(
        children: [
          Expanded(
            child: DisplayPdfScreen(
              selectedSubject: widget.selectedSubject,
              selectedChapter: widget.selectedChapter,
            ),
          ),
        ],
      ),
    );
  }
}

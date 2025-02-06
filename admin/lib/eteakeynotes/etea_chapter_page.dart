
import 'package:admin/services/get_service.dart';
import 'package:flutter/material.dart';
import 'etea_detail_page.dart';



class EteaKeyNotesChapterPage extends StatefulWidget {
  final String selectedSubject;

  const EteaKeyNotesChapterPage({
    Key? key,
    required this.selectedSubject,
  }) : super(key: key);

  @override
  _EteaKeyNotesChapterPageState createState() => _EteaKeyNotesChapterPageState();
}

class _EteaKeyNotesChapterPageState extends State<EteaKeyNotesChapterPage> {
  final GetService _getService = GetService();
  List<String> _chapters = [];

  @override
  void initState() {
    super.initState();
    _loadChapters();
  }

  Future<void> _loadChapters() async {
    final chapters = await _getService.getEteaChapters(widget.selectedSubject);
    setState(() {
      _chapters = chapters;
    });
  }

  void _navigateToChapterDetail(String chapter) {
    // Navigator.push(
    //   context,
    //   MaterialPageRoute(
    //     builder: (context) => KeyNotesChapterDetailPage(
    //       selectedSubject: widget.selectedSubject,
    //       selectedChapter: chapter,
    //     ),
    //   ),
    // );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Select Chapter')),
      body: ListView.builder(
        itemCount: _chapters.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(_chapters[index]),
            onTap: () => _navigateToChapterDetail(_chapters[index]),
          );
        },
      ),
    );
  }
}

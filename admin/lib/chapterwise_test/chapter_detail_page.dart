import 'package:admin/screens/view_screens/view_mcqs.dart';
import 'package:admin/screens/view_screens/view_question.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../constants/colors.dart';
import '../loginscreen.dart';
import '../mcq_provider.dart';
import '../providers/AuthProvider.dart';

class ChapterDetailPage extends StatefulWidget {
  final String selectedClass;
  final String selectedSubject;
  final String selectedChapter;
  final int initialIndex;

  const ChapterDetailPage({
    Key? key,
    required this.selectedClass,
    required this.selectedSubject,
    required this.selectedChapter,
    this.initialIndex = 0,
  }) : super(key: key);

  @override
  _ChapterDetailPageState createState() => _ChapterDetailPageState();
}

class _ChapterDetailPageState extends State<ChapterDetailPage> {
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
  }

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
            onPressed: () async {

              Provider.of<AuthManager>(context, listen: false).logout(context);

              context.go('/login');
            },
          ),
        ],
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.selectedClass,
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
      body: _selectedIndex == 0
          ? ViewMCQsPage(
        selectedClass: widget.selectedClass,
        selectedSubject: widget.selectedSubject,
        selectedChapter: widget.selectedChapter,
      )
          : ViewQuestionsScreen(
        selectedClass: widget.selectedClass,
        selectedSubject: widget.selectedSubject,
        selectedChapter: widget.selectedChapter,
      ),
    );
  }
}
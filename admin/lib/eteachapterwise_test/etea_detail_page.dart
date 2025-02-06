import 'package:admin/providers/AuthProvider.dart';
import 'package:admin/screens/view_screens/etea_view/etea_view_chapterwise.dart';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../constants/colors.dart';
import '../loginscreen.dart';
import '../mcq_provider.dart';


class EteaChapterDetailPage extends StatefulWidget {
  final String selectedSubject;
  final String selectedChapter;

  const EteaChapterDetailPage({
    Key? key,
    required this.selectedSubject,
    required this.selectedChapter,
  }) : super(key: key);

  @override
  _EteaChapterDetailPageState createState() => _EteaChapterDetailPageState();
}

class _EteaChapterDetailPageState extends State<EteaChapterDetailPage> {


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

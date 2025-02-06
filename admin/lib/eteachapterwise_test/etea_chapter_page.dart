import 'package:admin/constants/colors.dart';
import 'package:admin/services/get_service.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../loginscreen.dart';
import '../providers/AuthProvider.dart';
import '../providers/etea/EteaChapterProvider.dart';

class SelectEteaChapterPage extends StatelessWidget {
  final String selectedSubject;

  const SelectEteaChapterPage({Key? key, required this.selectedSubject}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final chapterProvider = Provider.of<EteaChapterProvider>(context, listen: false);
    chapterProvider.setSelectedSubject(selectedSubject);
    chapterProvider.loadChapters();

    return Consumer<EteaChapterProvider>(
      builder: (context, chapterProvider, child) {
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
                  "ETEA",
                  style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  selectedSubject,
                  style: TextStyle(
                    color: darkGrey,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: chapterProvider.isLoading
                ? Center(child: CircularProgressIndicator())
                : GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 6,
                crossAxisSpacing: 16.0,
                mainAxisSpacing: 16.0,
                childAspectRatio: 1,
              ),
              itemCount: chapterProvider.chapters.length,
              itemBuilder: (context, index) {
                String currentChapter = chapterProvider.chapters[index];
                return _buildChapterCard(context, currentChapter, chapterProvider);
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildChapterCard(BuildContext context, String chapter, EteaChapterProvider chapterProvider) {
    return MouseRegion(
      onEnter: (_) => chapterProvider.setHover(chapter, true),
      onExit: (_) => chapterProvider.setHover(chapter, false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => context.go('/eteachapter_detail/${chapterProvider.selectedSubject}/$chapter'),
        child: Transform.scale(
          scale: chapterProvider.isHovered(chapter) ? 1.1 : 1.0,
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
            elevation: 5.0,
            child: AnimatedContainer(
              duration: Duration(milliseconds: 200),
              padding: EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: customYellow,
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Center(
                child: Text(
                  chapter,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 17.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
import 'package:admin/constants/colors.dart';
import 'package:admin/services/get_service.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../loginscreen.dart';
import '../providers/AuthProvider.dart';
import '../providers/SubjectProvider.dart';

class SelectMainSubjectPage extends StatelessWidget {
  final String selectedClass;

  const SelectMainSubjectPage({Key? key, required this.selectedClass}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final subjectProvider = Provider.of<SubjectProvider>(context, listen: false);
    subjectProvider.setSelectedClass(selectedClass);
    subjectProvider.loadSubjects();

    return Consumer<SubjectProvider>(
      builder: (context, subjectProvider, child) {
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
            title: Text(
              selectedClass,
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white,
                  Colors.grey[100]!,
                ],
              ),
            ),
            child: Center(
              child: subjectProvider.isLoading
                  ? CircularProgressIndicator()
                  : LayoutBuilder(
                builder: (context, constraints) {
                  final screenSize = MediaQuery.of(context).size;
                  double cardWidth = ((screenSize.width - 600) / 4).clamp(100.0, double.infinity);
                  double cardHeight = cardWidth;

                  return SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Column(
                        children: [
                          Wrap(
                            spacing: 60.0,
                            runSpacing: 60.0,
                            alignment: WrapAlignment.center,
                            children: subjectProvider.subjects.map((subject) {
                              return _buildSubjectCard(context, subject, cardWidth, cardHeight, subjectProvider);
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSubjectCard(BuildContext context, String subject, double cardWidth, double cardHeight, SubjectProvider subjectProvider) {
    return MouseRegion(
      onEnter: (_) => subjectProvider.setHover(subject, true),
      onExit: (_) => subjectProvider.setHover(subject, false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => context.go('/select_chapter/${subjectProvider.selectedClass}/$subject'),
        child: Column(
          children: [
            TweenAnimationBuilder(
              duration: Duration(milliseconds: 200),
              curve: Curves.easeOutCubic,
              tween: Tween<double>(
                begin: 1.0,
                end: subjectProvider.isHovered(subject) ? 1.1 : 1.0,
              ),
              builder: (context, double scale, child) {
                return Transform.scale(
                  scale: scale,
                  child: Container(
                    width: cardWidth,
                    height: cardHeight,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20.0),
                      boxShadow: [
                        BoxShadow(
                          color: subjectProvider.isHovered(subject) ? Colors.black.withOpacity(0.3) : Colors.transparent,
                          offset: Offset(0, 8),
                          blurRadius: 15,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20.0),
                      child: Image.asset(
                        SubjectProvider.subjectImages[subject] ?? 'assets/images/subjects/default.png',
                        width: cardWidth,
                        height: cardHeight,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                );
              },
            ),
            SizedBox(height: 12),
            Text(
              subject,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
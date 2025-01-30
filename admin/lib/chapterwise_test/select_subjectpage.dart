import 'package:admin/constants/colors.dart';
import 'package:admin/services/get_service.dart';
import 'package:flutter/material.dart';
import '../loginscreen.dart';
import 'chapter_page.dart';

class SelectMainSubjectPage extends StatefulWidget {
  final String selectedClass;

  const SelectMainSubjectPage({Key? key, required this.selectedClass}) : super(key: key);

  @override
  _SelectMainSubjectPageState createState() => _SelectMainSubjectPageState();
}

class _SelectMainSubjectPageState extends State<SelectMainSubjectPage> {
  final GetService _getService = GetService();
  List<String> _subjects = [];
  Map<String, bool> _isHovered = {};

  Map<String, String> _subjectImages = {
    'English': 'assets/images/subjects/english.png',
    'Physics': 'assets/images/subjects/physics.png',
    'Chemistry': 'assets/images/subjects/chemistry.png',
    'Biology': 'assets/images/subjects/biology.png',
    'Maths': 'assets/images/subjects/maths.png',
    'Urdu': 'assets/images/subjects/urdu.png',
    'Computer Science': 'assets/images/subjects/computer.png',
    'PakStudy': 'assets/images/subjects/pakistanstudy.png',
    'Islamiat': 'assets/images/subjects/islamiyat.png',
  };

  @override
  void initState() {
    super.initState();
    _loadSubjects();
  }

  Future<void> _loadSubjects() async {
    print("Loading subjects for class: ${widget.selectedClass}");
    final stopwatch = Stopwatch()..start();

    try {
      final subjects = await _getService.getSubjects(widget.selectedClass);
      setState(() {
        _subjects = subjects;
      });
      print("Subjects loaded: $_subjects");
    } catch (e) {
      print("Error loading subjects: $e");
    } finally {
      print("Subjects load time: ${stopwatch.elapsedMilliseconds} ms");
      stopwatch.stop();
    }
  }

  Widget _buildSubjectCard({
    required String subject,
    required double cardWidth,
    required double cardHeight,
  }) {
    return MouseRegion(
      onEnter: (_) {
        setState(() {
          _isHovered[subject] = true;
        });
      },
      onExit: (_) {
        setState(() {
          _isHovered[subject] = false;
        });
      },
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SelectChapterPage(
                selectedClass: widget.selectedClass,
                selectedSubject: subject,
              ),
            ),
          );
        },
        child: Column(
          children: [
            TweenAnimationBuilder(
              duration: Duration(milliseconds: 200),
              curve: Curves.easeOutCubic,
              tween: Tween<double>(
                begin: 1.0,
                end: _isHovered[subject] == true ? 1.1 : 1.0,
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
                          color: _isHovered[subject] == true
                              ? Colors.black.withOpacity(0.3)
                              : Colors.transparent,
                          offset: Offset(0, 8),
                          blurRadius: 15,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20.0),
                      child: Stack(
                        children: [
                          Image.asset(
                            _subjectImages[subject] ?? 'images/subjects/default.png',
                            width: cardWidth,
                            height: cardHeight,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              print('Error loading image for $subject: $error');
                              return Container(
                                color: Colors.grey[300],
                                child: Icon(
                                  Icons.book,
                                  size: 50,
                                  color: Colors.grey[600],
                                ),
                              );
                            },
                          ),
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  Colors.black.withOpacity(0.1),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
            SizedBox(height: 12),
            TweenAnimationBuilder(
              duration: Duration(milliseconds: 200),
              curve: Curves.easeOutCubic,
              tween: Tween<double>(
                begin: 1.0,
                end: _isHovered[subject] == true ? 1.1 : 1.0,
              ),
              builder: (context, double scale, child) {
                return Transform.scale(
                  scale: scale,
                  child: Text(
                    subject,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                      letterSpacing: 0.5,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
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
              widget.selectedClass,
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
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
          child: _subjects.isEmpty
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
                        children: _subjects.map((subject) {
                          return _buildSubjectCard(
                            subject: subject,
                            cardWidth: cardWidth,
                            cardHeight: cardHeight,
                          );
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
  }
}
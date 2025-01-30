import 'package:admin/chapterwise_test/select_subjectpage.dart';
import 'package:admin/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:admin/services/get_service.dart';
import '../loginscreen.dart';
import '../main.dart';

class SelectClassPage extends StatefulWidget {
  @override
  _SelectClassPageState createState() => _SelectClassPageState();
}

class _SelectClassPageState extends State<SelectClassPage> {
  final GetService _getService = GetService();
  List<String> _classes = [];
  Map<String, bool> _isHovered = {};

  final List<String> _classOrder = [
    'Class 9',
    'Class 10',
    '1st Year',
    '2nd Year'
  ];

  Map<String, String> _classImages = {
    'Class 9': 'assets/images/class9.png',
    'Class 10': 'assets/images/class10.png',
    '1st Year': 'assets/images/1styear.png',
    '2nd Year': 'assets/images/2ndyear.png',
  };

  @override
  void initState() {
    super.initState();
    _loadClasses();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _loadClasses() async {
    print("Loading classes...");
    final stopwatch = Stopwatch()..start();
    try {
      final cls = await _getService.getClasses();
      if (mounted) {
        setState(() {
          _classes = cls
              .where((classItem) => _classOrder.contains(classItem))
              .toList()
            ..sort((a, b) =>
                _classOrder.indexOf(a).compareTo(_classOrder.indexOf(b)));
        });

        // Preload images
        for (var className in _classes) {
          final imagePath = _classImages[className] ?? 'assets/images/default.png';
          precacheImage(AssetImage(imagePath), context);
        }

        print("Ordered Classes loaded: $_classes");
      }
    } catch (e) {
      print("Error loading classes: $e");
    } finally {
      print("Classes load time: ${stopwatch.elapsedMilliseconds} ms");
      stopwatch.stop();
    }
  }

  Widget _buildClassCard({
    required String className,
    required double cardWidth,
    required double cardHeight,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          MouseRegion(
            onEnter: (_) {
              setState(() {
                _isHovered[className] = true;
              });
            },
            onExit: (_) {
              setState(() {
                _isHovered[className] = false;
              });
            },
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SelectMainSubjectPage(
                      selectedClass: className,
                    ),
                  ),
                );
              },
              child: TweenAnimationBuilder(
                duration: Duration(milliseconds: 200),
                curve: Curves.easeOutCubic,
                tween: Tween<double>(
                  begin: 1.0,
                  end: _isHovered[className] == true ? 1.1 : 1.0,
                ),
                builder: (context, double scale, child) {
                  return Transform.scale(
                    scale: scale,
                    child: Container(
                      width: cardWidth,
                      height: cardHeight,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16.0),
                        boxShadow: [
                          BoxShadow(
                            color: _isHovered[className] == true
                                ? Colors.black.withOpacity(0.3)
                                : Colors.transparent,
                            offset: Offset(0, 8),
                            blurRadius: 15,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16.0),
                        child: Container(
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: AssetImage(
                                _classImages[className] ??
                                    'assets/images/default.png',
                              ),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          SizedBox(height: 10),
          TweenAnimationBuilder(
            duration: Duration(milliseconds: 200),
            curve: Curves.easeOutCubic,
            tween: Tween<double>(
              begin: 1.0,
              end: _isHovered[className] == true ? 1.1 : 1.0,
            ),
            builder: (context, double scale, child) {
              return Transform.scale(
                scale: scale,
                child: Text(
                  className,
                  style: TextStyle(
                    fontSize: _isHovered[className] == true ? 17 : 17,
                    fontWeight: _isHovered[className] == true ? FontWeight.bold : FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Class'),
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
      ),
      body: Center(
        child: _classes.isEmpty
            ? CircularProgressIndicator()
            : LayoutBuilder(
          builder: (context, constraints) {
            final screenSize = MediaQuery.of(context).size;
            double cardWidth = screenSize.width * 0.19;
            double cardHeight = cardWidth;

            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _classes.map((className) {
                  return _buildClassCard(
                    className: className,
                    cardWidth: cardWidth,
                    cardHeight: cardHeight,
                  );
                }).toList(),
              ),
            );
          },
        ),
      ),
    );
  }
}
import 'package:admin/chapterwise_test/select_subjectpage.dart';
import 'package:admin/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:admin/services/get_service.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../loginscreen.dart';
import '../main.dart';
import '../mcq_provider.dart';
import '../providers/AuthProvider.dart';
import '../providers/ClassProvider.dart';

class SelectClassPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ClassProvider()..loadClasses(),
      child: Consumer<ClassProvider>(
        builder: (context, classProvider, child) {
          return Scaffold(
            appBar: AppBar(
              title: Text(
                'Select Class',
                style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
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
            ),
            body: Center(
              child: classProvider.isLoading
                  ? CircularProgressIndicator()
                  : LayoutBuilder(
                builder: (context, constraints) {
                  final screenSize = MediaQuery.of(context).size;
                  double cardWidth = screenSize.width * 0.19;
                  double cardHeight = cardWidth;

                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: classProvider.classes.map((className) {
                        return _buildClassCard(
                          context,
                          className,
                          cardWidth,
                          cardHeight,
                          classProvider,
                        );
                      }).toList(),
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildClassCard(
      BuildContext context,
      String className,
      double cardWidth,
      double cardHeight,
      ClassProvider classProvider,
      ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          MouseRegion(
            onEnter: (_) => classProvider.setHover(className, true),
            onExit: (_) => classProvider.setHover(className, false),
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: () {
                context.go('/select_subject/$className');
              },
              child: TweenAnimationBuilder(
                duration: Duration(milliseconds: 200),
                curve: Curves.easeOutCubic,
                tween: Tween<double>(
                  begin: 1.0,
                  end: classProvider.isHovered(className) ? 1.1 : 1.0,
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
                            color: classProvider.isHovered(className)
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
                                ClassProvider.classImages[className] ??
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
              end: classProvider.isHovered(className) ? 1.1 : 1.0,
            ),
            builder: (context, double scale, child) {
              return Transform.scale(
                scale: scale,
                child: Text(
                  className,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: classProvider.isHovered(className) ? FontWeight.bold : FontWeight.w600,
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
}
import 'package:admin/eteakeynotes/etea_subject_page.dart';
import 'package:admin/widgets/option_card.dart';
import 'package:admin/widgets/option_image_card.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../constants/colors.dart';
import '../../eteachapterwise_test/etea_subject_page.dart';
import '../../loginscreen.dart';
import '../../main.dart';
import '../../mcq_provider.dart';
import '../../providers/AuthProvider.dart';
import 'internaluser_Dashboard.dart';

class EteaManageOptionsDialog extends StatefulWidget {
  @override
  State<EteaManageOptionsDialog> createState() => _EteaManageOptionsDialogState();
}

class _EteaManageOptionsDialogState extends State<EteaManageOptionsDialog> {
  Map<String, bool> _isHovered = {};

  Widget _buildOptionCard({
    required String title,
    required String imagePath,
    required VoidCallback onTap,
    required double cardWidth,
    required double cardHeight,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        MouseRegion(
          onEnter: (_) {
            setState(() {
              _isHovered[title] = true;
            });
          },
          onExit: (_) {
            setState(() {
              _isHovered[title] = false;
            });
          },
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: onTap,
            child: TweenAnimationBuilder(
              duration: Duration(milliseconds: 200),
              curve: Curves.easeOutCubic,
              tween: Tween<double>(
                begin: 1.0,
                end: _isHovered[title] == true ? 1.1 : 1.0,
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
                          color: _isHovered[title] == true
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
                            image: AssetImage(imagePath),
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
        SizedBox(height: 12),
        TweenAnimationBuilder(
          duration: Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          tween: Tween<double>(
            begin: 1.0,
            end: _isHovered[title] == true ? 1.1 : 1.0,
          ),
          builder: (context, double scale, child) {
            return Transform.scale(
              scale: scale,
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final cardWidth = screenSize.width * 0.19;
    final cardHeight = cardWidth;

    return Scaffold(
      appBar: AppBar(
        title: Text('ETEA Manage',
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
        child: Container(
          width: cardWidth * 3 + 40 * 2,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _buildOptionCard(
                  title: 'Key Notes',
                  imagePath: 'assets/images/keynotes.png',
                  onTap: () => (),
                  // onTap: () => Navigator.push(
                  //   context,
                  //   MaterialPageRoute(builder: (context) => EteaKeyNotesSubjectPage()),
                  // ),
                  cardWidth: cardWidth,
                  cardHeight: cardHeight,
                ),
              ),
              SizedBox(width: 40),
              Expanded(
                child: _buildOptionCard(
                  title: 'ETEA Chapterwise',
                  imagePath: 'assets/images/etea.png',
                  onTap: () => context.go( '/etea/selecteatesubjectpage'),
                  cardWidth: cardWidth,
                  cardHeight: cardHeight,
                ),
              ),
              SizedBox(width: 40),
              Expanded(
                child: _buildOptionCard(
                  title: 'Online/Video Lectures',
                  imagePath: 'assets/images/videolectures.png',
                  onTap: () => (),
                  cardWidth: cardWidth,
                  cardHeight: cardHeight,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
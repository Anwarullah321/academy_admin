import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../chapterwise_test/selectclasspage.dart';
import '../../constants/colors.dart';
import '../../loginscreen.dart';
import '../../widgets/option_image_card.dart';
import 'etea_manage_options.dart';

class ManageDataPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final cardWidth = screenSize.width * 0.3;
    final cardHeight = cardWidth * 0.7;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Manage Data'),
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
        child: Container(
          width: cardWidth * 2 + 20,
          height: cardHeight,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
            child:
              Container(
                width: cardWidth,
                height: cardHeight,
                child: AdminOptionImageCard(
                  image: 'assets/images/academicdata.png',
                  title: 'Academic Data',
                  subtitle: 'Edit or Delete Academic Data.',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SelectClassPage()),
                  ),
                ),
              ),
              ),
              SizedBox(width: 40),
              Expanded(
                child: Container(
                  width: cardWidth,
                  height: cardHeight,
                  child: AdminOptionImageCard(
                    image: 'assets/images/eteadata.png',
                    title: 'ETEA Data',
                    subtitle: 'Edit or Delete ETEA Data.',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => EteaManageOptionsDialog()),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


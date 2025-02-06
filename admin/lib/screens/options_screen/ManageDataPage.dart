import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../chapterwise_test/selectclasspage.dart';
import '../../constants/colors.dart';
import '../../loginscreen.dart';
import '../../mcq_provider.dart';
import '../../providers/AuthProvider.dart';
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
        title: Text('Manage Data',
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
                  onTap: () => context.go( '/chapterwise_test'),
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
                    onTap: () => context.go('/etea/manage'),
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


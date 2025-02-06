import 'dart:convert';
import 'dart:io';

import 'package:admin/chapterwise_test/selectclasspage.dart';
import 'package:admin/constants/colors.dart';
import 'package:admin/mcq_provider.dart';
import 'package:admin/screens/add_screens/subjectwise_past_papers.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../export_data/export_class_data.dart';
import '../../export_data/export_data_page.dart';
import '../../export_data/export_etea_data.dart';

import '../../loginscreen.dart';
import '../../main.dart';
import '../../providers/AuthProvider.dart';
import '../../widgets/option_card.dart';
import '../add_yaml_data/etea/eteatexttoyamluploadscreen.dart';
import '../add_yaml_data/texttoyamluploadscreen.dart';
import 'ManageDataPage.dart';
import 'add_options.dart';
import 'etea_add_options.dart';
import 'etea_manage_options.dart';



class Dashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(

      onWillPop: () async {
        print("[DEBUG] Back button press blocked on login screen.");
        return false;
      },

      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(130),
          child: AppBar(
            backgroundColor: customYellow,
            elevation: 0,
            automaticallyImplyLeading: false,
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
            flexibleSpace: Padding(
              padding: const EdgeInsets.all(10),
      
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/logo.png',
                    height: 128,
      
                  ),
                  SizedBox(width: 15),
                  Text(
                    'Dashboard',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        body: Center(
          child: Container(
            color: Colors.white,
            constraints: BoxConstraints(maxWidth: 1200),
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: 32),
                Expanded(
                  child: GridView.count(
                    crossAxisCount: 3,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 4 / 3,
                    children: [
                      AdminOptionCard(
                        icon: Icons.upload_file,
                        title: 'Upload Data',
                        subtitle: 'Upload Academic or ETEA Data',
      
                        onTap: () => context.go('/upload'),
                      ),
                      AdminOptionCard(
                        icon: Icons.manage_search,
                        title: 'Manage Data',
                        subtitle: 'Manage Academic or ETEA Data',
                        onTap: () => context.go('/manage'),
                      ),
                      AdminOptionCard(
                        icon: Icons.explore_outlined,
                        title: 'Download Data',
                        subtitle: 'Download Academic or ETEA Data',
                        onTap: () => context.go('/export')
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


class UploadDataPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Upload Data',
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
      body: ListView(
        padding: EdgeInsets.all(16.0),
        children: [
          AdminOptionCard(
            icon: Icons.upload,
            title: 'Upload Academic',
            subtitle: 'Upload Academic Data',
            onTap: () => context.go('/upload/academic')
          ),
          SizedBox(height: 15),
          AdminOptionCard(
            icon: Icons.cloud_upload,
            title: 'Upload ETEA',
            subtitle: 'Upload ETEA Data',
            onTap: () => context.go('/upload/etea')
          ),
          SizedBox(height: 15),
          AdminOptionCard(
            icon: Icons.history_edu_outlined,
            title: 'Past Papers',
            subtitle: 'Upload Past Papers',
              onTap: () => (),
            // onTap: () => Navigator.push(
            //   context,
            //   MaterialPageRoute(builder: (context) => UploadPastPaperPdfScreen()),
            // ),
          ),
        ],
      ),
    );
  }
}




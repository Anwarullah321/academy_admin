import 'dart:convert';
import 'dart:io';

import 'package:admin/chapterwise_test/selectclasspage.dart';
import 'package:admin/constants/colors.dart';
import 'package:admin/screens/add_screens/subjectwise_past_papers.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import '../../export_data/export_class_data.dart';
import '../../export_data/export_data_page.dart';
import '../../export_data/export_etea_data.dart';

import '../../loginscreen.dart';
import '../../main.dart';
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
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(130),
        child: AppBar(
          backgroundColor: customYellow,
          elevation: 0,
          automaticallyImplyLeading: false, // Removes the back button
          actions: [

            TextButton.icon(

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
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => UploadDataPage()),
                      ),
                    ),
                    AdminOptionCard(
                      icon: Icons.manage_search,
                      title: 'Manage Data',
                      subtitle: 'Manage Academic or ETEA Data',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ManageDataPage()),
                      ),
                    ),
                    AdminOptionCard(
                      icon: Icons.explore_outlined,
                      title: 'Download Data',
                      subtitle: 'Download Academic or ETEA Data',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ExportDataPage()),
                      ),
                    ),
                  ],
                ),
              ),
            ],
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
        title: Text('Upload Data'),
        backgroundColor: customYellow,
        elevation: 0,
        actions: [
          TextButton.icon(
            icon: Icon(Icons.exit_to_app),
            label: Text('Logout'),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => LoggedInScreen(),
                ),
              );
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
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => TextToYamlUploadScreen()),
            ),
          ),
          SizedBox(height: 15),
          AdminOptionCard(
            icon: Icons.cloud_upload,
            title: 'Upload ETEA',
            subtitle: 'Upload ETEA Data',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => EteaTextToYamlUploadScreen()),
            ),
          ),
          SizedBox(height: 15),
          AdminOptionCard(
            icon: Icons.history_edu_outlined,
            title: 'Past Papers',
            subtitle: 'Upload Past Papers',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => UploadPastPaperPdfScreen()),
            ),
          ),
        ],
      ),
    );
  }
}




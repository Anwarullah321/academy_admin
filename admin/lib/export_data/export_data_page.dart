
import 'package:admin/constants/colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../loginscreen.dart';
import '../main.dart';
import '../mcq_provider.dart';
import '../providers/AuthProvider.dart';
import '../widgets/option_card.dart';
import 'export_class_data.dart';
import 'export_etea_data.dart';

class ExportDataPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Download Data',
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: customYellow,
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
            icon: Icons.file_download_outlined,
            title: 'Download Academic Data',
            subtitle: 'Download Academic Data.',
            onTap: () => context.go('/export/academic'),
          ),
          SizedBox(height: 15),
          AdminOptionCard(
            icon: Icons.download_for_offline_outlined,
            title: 'Download ETEA Data',
            subtitle: 'Download ETEA Data.',
            onTap: () => context.go('/export/etea'),
          ),
        ],
      ),
    );
  }
}


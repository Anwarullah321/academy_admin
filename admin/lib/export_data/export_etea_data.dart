import 'dart:convert';
import 'dart:io';
import 'package:admin/constants/colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'dart:html' as html;
import '../loginscreen.dart';
import '../main.dart';
import '../mcq_provider.dart';
import '../providers/AuthProvider.dart';
import '../providers/etea/EteaSubjectProvider.dart';
import '../services/decryption_service.dart';
import '../services/get_service.dart';
import 'package:encrypt/encrypt.dart' as encrypt;

class ExportEteaScreen extends StatefulWidget {
  @override
  _ExportEteaScreenState createState() => _ExportEteaScreenState();
}

class _ExportEteaScreenState extends State<ExportEteaScreen> {
  final GetService _getService = GetService();
  List<String> _eteaSubjects = [];
  bool isExporting = false;
  double exportProgress = 0.0;

  @override
  void initState() {
    super.initState();
    // Load subjects only if they are not already loaded
    final subjectProvider = Provider.of<EteaSubjectProvider>(context, listen: false);
    if (subjectProvider.subjects.isEmpty) {
      subjectProvider.loadSubjects();
    }
  }


  String encryptData(String data, String decryptedKey) {
    try {
      final iv = encrypt.IV.fromSecureRandom(16);
      final encrypter = encrypt.Encrypter(encrypt.AES(encrypt.Key(base64.decode(decryptedKey))));
      final encrypted = encrypter.encrypt(data, iv: iv);
      return '${base64.encode(iv.bytes)}:${encrypted.base64}';
    } catch (e) {
      throw Exception('Encryption failed: $e');
    }
  }

  Future<void> _exportSpecificSubjects() async {
    final subjectProvider = Provider.of<EteaSubjectProvider>(context, listen: false);

    final selectedSubjects = await showDialog<List<String>>(
      context: context,
      builder: (context) {
        List<String> selected = [];
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Select Subjects to Download'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: subjectProvider.subjects.map((subject) {
                    return CheckboxListTile(
                      title: Text(subject),
                      value: selected.contains(subject),
                      onChanged: (isChecked) {
                        setState(() {
                          if (isChecked == true) {
                            selected.add(subject);
                          } else {
                            selected.remove(subject);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, null),
                  child: Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, selected),
                  child: Text('Download'),
                ),
              ],
            );
          },
        );
      },
    );

    if (selectedSubjects != null && selectedSubjects.isNotEmpty) {
      await _exportData(selectedSubjects);
    }
  }

  Future<void> _exportData(List<String> selectedSubjects) async {
    setState(() {
      isExporting = true;
      exportProgress = 0.0;
    });

    try {
      final decryptedKey = DecrytionService.getDecryptedKey();
      if (decryptedKey == null) throw Exception('Failed to decrypt the AES key');

      Map<String, dynamic> eteaData = {'ETEA': {}};
      String subjectsList = selectedSubjects.join('_');
      String timestamp = DateTime.now().toString().replaceAll(':', '-').split('.')[0];
      String fileName = 'ETEA_${subjectsList}_$timestamp.yaml';

      int totalItems = 0;
      for (var subject in selectedSubjects) {
        final chapters = await _getService.getEteaChapters(subject);
        totalItems += chapters.length;
      }

      int processedItems = 0;

      for (String subject in selectedSubjects) {
        final chapters = await _getService.getEteaChapters(subject);
        eteaData['ETEA'][subject] = {};

        for (String chapter in chapters) {
          final mcqs = await _getService.getEteaChapterwiseMCQs(subject, chapter);
          eteaData['ETEA'][subject][chapter] = {
            'mcqs': mcqs.map((mcq) => mcq.toMap()).toList(),
          };

          processedItems++;
          setState(() => exportProgress = (processedItems / totalItems) * 100);
          await Future.delayed(Duration(milliseconds: 50));
        }
      }

      final yamlString = convertMapToYaml(eteaData);
      final encryptedData = encryptData(yamlString, decryptedKey);

      _saveFile(fileName, encryptedData);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Selected subjects data Downloaded successfully.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error Downloading subjects data: $e')),
      );
    } finally {
      setState(() {
        isExporting = false;
        exportProgress = 0.0;
      });
    }
  }

  Future<void> _exportAllSubjects() async {
    final subjectProvider = Provider.of<EteaSubjectProvider>(context, listen: false);
    await _exportData(subjectProvider.subjects);
  }

  void _saveFile(String fileName, String encryptedData) {
    if (kIsWeb) {
      final bytes = utf8.encode(encryptedData);
      final blob = html.Blob([bytes]);
      final url = html.Url.createObjectUrlFromBlob(blob);
      final anchor = html.AnchorElement(href: url)
        ..setAttribute("download", fileName)
        ..click();
      html.Url.revokeObjectUrl(url);
    } else {
      getApplicationDocumentsDirectory().then((directory) {
        final file = File('${directory.path}/$fileName');
        file.writeAsString(encryptedData);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final subjectProvider = Provider.of<EteaSubjectProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Download ETEA Data',
          style: TextStyle(
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
            onPressed: () {
              Provider.of<AuthManager>(context, listen: false).logout(context);
              context.go('/login');
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          subjectProvider.isLoading
              ? Center(child: CircularProgressIndicator())
              : Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton(
                  onPressed: _exportSpecificSubjects,
                  child: Text('Download Specific Subjects'),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _exportAllSubjects,
                  child: Text('Download All Subjects'),
                ),
              ],
            ),
          ),
          if (isExporting)
            Container(
              color: Colors.black54,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(value: exportProgress / 100),
                    SizedBox(height: 20),
                    Text(
                      'Downloading... ${exportProgress.toStringAsFixed(1)}%',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }



  String convertMapToYaml(Map<String, dynamic> data) {
    String yamlString = '';
    data.forEach((key, value) {
      yamlString += '$key:\n';
      yamlString += _convertToYaml(value, 2);
    });
    return yamlString;
  }

  String _convertToYaml(dynamic data, int indent) {
    String yamlString = '';
    if (data is Map) {
      data.forEach((key, value) {
        yamlString += '${' ' * indent}$key:\n';
        yamlString += _convertToYaml(value, indent + 2);
      });
    } else if (data is List) {
      for (var item in data) {
        yamlString += '${' ' * indent}- ';
        if (item is Map) {
          yamlString += '\n' + _convertToYaml(item, indent + 2);
        } else {
          yamlString += '$item\n';
        }
      }
    } else {
      yamlString += '${' ' * indent}$data\n';
    }
    return yamlString;
  }


}

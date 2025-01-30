import 'dart:convert';
import 'dart:io';
import 'package:admin/constants/colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:html' as html;
import 'package:encrypt/encrypt.dart' as encrypt;
import '../loginscreen.dart';
import '../main.dart';
import '../services/decryption_service.dart';
import '../services/get_service.dart';

class ExportClassesScreen extends StatefulWidget {
  @override
  _ExportClassesScreenState createState() => _ExportClassesScreenState();
}

class _ExportClassesScreenState extends State<ExportClassesScreen> {
  final GetService _getService = GetService();
  List<String> _classes = [];
  bool isExporting = false;
  double exportProgress = 0.0;
  bool isDecryptingKey = false;
  String? selectedClass;
  List<String> selectedSubjects = [];
  Map<String, bool> _isHovered = {};


  final List<String> _classOrder = [
    'Class 9',
    'Class 10',
    '1st Year',
    '2nd Year'
  ];

  @override
  void initState() {
    super.initState();
    _loadClasses();
  }

  Future<void> _loadClasses() async {
    print("Loading classes...");
    final stopwatch = Stopwatch()..start();
    try {
      final cls = await _getService.getClasses();
      if (mounted) {
        setState(() {
          // Sort classes based on the predefined order
          _classes = cls.where((classItem) => _classOrder.contains(classItem))
              .toList()
            ..sort((a, b) => _classOrder.indexOf(a).compareTo(_classOrder.indexOf(b)));
        });
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
                setState(() {
                  selectedClass = className;
                });
                _showExportOptionDialog();
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
                        color: customYellow,
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
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.download,
                            size: 24,
                            color: Colors.black87,
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Download\n$className',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          // SizedBox(height: 20),
          // TweenAnimationBuilder(
          //   duration: Duration(milliseconds: 200),
          //   curve: Curves.easeOutCubic,
          //   tween: Tween<double>(
          //     begin: 1.0,
          //     end: _isHovered[className] == true ? 1.1 : 1.0,
          //   ),
          //   builder: (context, double scale, child) {
          //     return Transform.scale(
          //       scale: scale,
          //       child: Text(
          //         className,
          //         style: TextStyle(
          //           fontSize: _isHovered[className] == true ? 17 : 17,
          //           fontWeight: _isHovered[className] == true ? FontWeight.bold : FontWeight.w600,
          //           color: Colors.black,
          //         ),
          //       ),
          //     );
          //   },
          // ),
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



  Future<void> _exportData() async {
    setState(() {
      isExporting = true;
      isDecryptingKey = true;
      exportProgress = 0.0;
    });

    try {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Decrypting key, please wait...')),
      );

      final decryptedKey = KeyDecryptionService.getDecryptedKey();
      if (decryptedKey == null) {
        throw Exception('Failed to decrypt the AES key');
      }

      Map<String, dynamic> exportData = {};
      if (selectedSubjects.isEmpty) {
        // Export complete class data
        final subjects = await _getService.getSubjects(selectedClass!);
        selectedSubjects = subjects;
      }

      exportData[selectedClass!] = {};

      // Calculate total items to track progress
      int totalItems = 0;
      for (var subject in selectedSubjects) {
        final chapters = await _getService.getChapters(selectedClass!, subject);
        totalItems += chapters.length;
      }

      int processedItems = 0;

      for (var subject in selectedSubjects) {
        final chapters = await _getService.getChapters(selectedClass!, subject);
        exportData[selectedClass!][subject] = {};

        for (var chapter in chapters) {
          final mcqs = await _getService.getChapterwiseMCQs(selectedClass!, subject, chapter);
          exportData[selectedClass!][subject][chapter] = {
            'mcqs': mcqs.map((mcq) => mcq.toMap()).toList(),
          };

          // Update progress
          processedItems++;
          setState(() {
            exportProgress = (processedItems / totalItems) * 100;
          });

          // Optional: Add a small delay to make progress visible
          await Future.delayed(Duration(milliseconds: 100));
        }
      }

      final yamlString = _convertMapToYaml(exportData);
      final encryptedData = encryptData(yamlString, decryptedKey);

      // Adjust file name to include all subjects and date/time
      final formattedDate =  DateTime.now().toString().replaceAll(':', '-').split('.')[0];
      final subjectsPart = selectedSubjects.join('_').replaceAll(' ', '_');
      final fileName = '${selectedClass}_${subjectsPart}_$formattedDate.yaml';

      if (kIsWeb) {
        final bytes = utf8.encode(encryptedData);
        final blob = html.Blob([bytes]);
        final url = html.Url.createObjectUrlFromBlob(blob);
        final anchor = html.AnchorElement(href: url)
          ..setAttribute("download", fileName)
          ..click();
        html.Url.revokeObjectUrl(url);
      } else {
        final directory = await getApplicationDocumentsDirectory();
        final file = File('${directory.path}/$fileName');
        await file.writeAsString(encryptedData);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Download completed successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Download failed: $e')),
      );
    } finally {
      setState(() {
        isExporting = false;
        exportProgress = 0.0;
      });
    }
  }

  String _convertMapToYaml(Map<String, dynamic> data) {
    String yamlString = '';
    data.forEach((key, value) {
      yamlString += '$key:\n${_convertToYaml(value, 2)}';
    });
    return yamlString;
  }

  String _convertToYaml(dynamic data, int indent) {
    String yamlString = '';
    if (data is Map) {
      data.forEach((key, value) {
        yamlString += '${' ' * indent}$key:\n${_convertToYaml(value, indent + 2)}';
      });
    } else if (data is List) {
      for (var item in data) {
        yamlString += '${' ' * indent}- ';
        if (item is Map) {
          yamlString += '\n${_convertToYaml(item, indent + 2)}';
        } else {
          yamlString += '$item\n';
        }
      }
    } else {
      yamlString += '${' ' * indent}$data\n';
    }
    return yamlString;
  }

  String encryptData(String data, String decryptedKey) {
    try {
      final iv = encrypt.IV.fromSecureRandom(16);
      final encrypter = encrypt.Encrypter(encrypt.AES(encrypt.Key(base64.decode(decryptedKey!))));

      final encrypted = encrypter.encrypt(data, iv: iv);
      return '${base64.encode(iv.bytes)}:${encrypted.base64}';
    } catch (e) {
      print("Encryption error: $e");
      throw Exception('Encryption failed: $e');
    }
  }

  void _showExportOptionDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Download Options for $selectedClass'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text('Download Specific Subjects'),
                onTap: () async {
                  final subjects = await _selectMultipleSubjects();
                  if (subjects.isNotEmpty) {
                    setState(() {
                      selectedSubjects = subjects;
                    });
                    Navigator.pop(context);
                    _exportData();
                  }
                },
              ),
              ListTile(
                title: Text('Download Class Data'),
                onTap: () {
                  setState(() {
                    selectedSubjects.clear(); // Clear specific subjects selection
                  });
                  Navigator.pop(context);
                  _exportData();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<List<String>> _selectMultipleSubjects() async {
    final subjects = await _getService.getSubjects(selectedClass!);
    return await showDialog(
      context: context,
      builder: (context) {
        return MultiSelectDialog(
          items: subjects,
          title: 'Select Subjects',
        );
      },
    );
  }
}

// MultiSelectDialog Widget for selecting multiple items
class MultiSelectDialog extends StatefulWidget {
  final List<String> items;
  final String title;

  const MultiSelectDialog({Key? key, required this.items, required this.title})
      : super(key: key);

  @override
  _MultiSelectDialogState createState() => _MultiSelectDialogState();
}

class _MultiSelectDialogState extends State<MultiSelectDialog> {
  List<String> selectedItems = [];

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: SingleChildScrollView(
        child: Column(
          children: widget.items.map((item) {
            return CheckboxListTile(
              title: Text(item),
              value: selectedItems.contains(item),
              onChanged: (bool? selected) {
                setState(() {
                  if (selected == true) {
                    selectedItems.add(item);
                  } else {
                    selectedItems.remove(item);
                  }
                });
              },
            );
          }).toList(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, []), // Return empty if cancelled
          child: Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, selectedItems),
          child: Text('Download'),
        ),
      ],
    );
  }
}


import 'package:admin/main.dart';
import 'package:admin/mcq_provider.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../constants/colors.dart';
import '../../../loginscreen.dart';
import '../../../providers/AuthProvider.dart';
import '../../../services/eteayamluploadservice.dart';

class EteaTextToYamlUploadScreen extends StatefulWidget {
  @override
  _EteaTextToYamlUploadScreenState createState() => _EteaTextToYamlUploadScreenState();
}

class _EteaTextToYamlUploadScreenState extends State<EteaTextToYamlUploadScreen> {
  final EteaYamlCompleteUploadService _yamlUploadService = EteaYamlCompleteUploadService();
  final TextEditingController _textController = TextEditingController();
  int _uploadingCount = 0;

  Future<void> _uploadText() async {
    if (_textController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter some text')),
      );
      return;
    }

    String textToUpload = _textController.text.trim();
    if (!_isValidFormat(textToUpload)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Invalid format! Please follow the specified ETEA MCQ format.')),
      );
      return;
    }

    setState(() {
      _uploadingCount++;
    });

    try {

      List<String> sections = [];
      String currentSection = "";

      for (String line in textToUpload.split('\n')) {
        if (line.trim().startsWith('ETEA,')) {
          if (currentSection.isNotEmpty) {
            sections.add(currentSection.trim());
          }
          currentSection = line.trim().replaceFirst('ETEA, ', '') + '\n';
        } else {
          if (line.trim().isNotEmpty) {
            currentSection += line.trim() + '\n';
          }
        }
      }


      if (currentSection.isNotEmpty) {
        sections.add(currentSection.trim());
      }


      for (String section in sections) {
        await _yamlUploadService.processTextData(section);
      }

      _textController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Data uploaded successfully')),
      );
    } catch (e) {
      print('Upload error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error uploading data: $e')),
      );
    } finally {
      setState(() {
        _uploadingCount--;
      });
    }
  }

  bool _isValidFormat(String text) {
    final lines = text.split('\n')
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList();

    if (lines.isEmpty) return false;

    final headerPattern = RegExp(r'^ETEA,\s*[a-zA-Z\s]+,\s(Chapter\s\d+|[A-Za-z\s]+)$');
    bool foundHeader = false;
    int questionCount = 0;

    for (int i = 0; i < lines.length; i++) {
      String line = lines[i];


      if (headerPattern.hasMatch(line)) {
        foundHeader = true;
        continue;
      }


      if (!foundHeader) return false;


      if (line.startsWith('Q:')) {

        if (line == 'Q:' || !line.substring(2).startsWith(' ')) {
          return false;
        }

        questionCount++;
        int optionCount = 0;
        bool foundAnswer = false;


        while (++i < lines.length) {
          String currentLine = lines[i];


          if (currentLine.startsWith('Q:') || headerPattern.hasMatch(currentLine)) {
            i--;
            break;
          }


          if (RegExp(r'^[A-E]:').hasMatch(currentLine)) {
            String optionLetter = currentLine[0];
            if (currentLine == '$optionLetter:' || !currentLine.substring(2).startsWith(' ')) {
              return false;
            }
            optionCount++;
          } else if (currentLine.startsWith('Ans:')) {
            if (!RegExp(r'^Ans:\s*[A-E]$').hasMatch(currentLine)) {
              return false;
            }
            foundAnswer = true;
            break;
          } else {
            return false;
          }
        }

        if (optionCount < 4 || optionCount > 5 || !foundAnswer) {
          return false;
        }
      } else {
        return false;
      }
    }

    return foundHeader && questionCount > 0;
  }



  void _showFormatExample() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Input Format Example'),
          content: SingleChildScrollView(
            child: Text(
              'ETEA, Physics, Chapter 01\n'
                  'Q: This is 2nd Year Physics Chapter 01 mcq no 1?\n'
                  'A: yes\n'
                  'B: no\n'
                  'C: both\n'
                  'D: none\n'
                  'Ans: A\n\n'
                  'Q: This is 2nd Year Physics Chapter 01 mcq no 2?\n'
                  'A: no\n'
                  'B: both\n'
                  'C: yes\n'
                  'D: none\n'
                  'E: not applicable\n'
                  'Ans: C',
              style: TextStyle(fontSize: 16, height: 1.5),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Upload ETEA MCQs',
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
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Instructions',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Paste your ETEA MCQs here in the following format: "ETEA, Subject, Chapter" on the first line. '
                          'Then each MCQ starts with "Q:" followed by options "A:", "B:", "C:", "D:", and the correct answer "Ans:".',
                      style: TextStyle(fontSize: 14, color: Colors.grey.shade700, height: 1.5),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),
            TextButton.icon(
              onPressed: _showFormatExample,
              icon: Icon(Icons.info_outline),
              label: Text('Show Example'),
              style: TextButton.styleFrom(
                foregroundColor: Colors.black87, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
            SizedBox(height: 16),
            Expanded(
              child: Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextField(
                    controller: _textController,
                    maxLines: null,
                    expands: true,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Paste your ETEA MCQs here...',
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _uploadText,
              child: Text('Upload ETEA MCQs', style: TextStyle(fontSize: 16)),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
            if (_uploadingCount > 0)
              Padding(
                padding: EdgeInsets.only(top: 16.0),
                child: Text(
                  'Uploading $_uploadingCount set(s) of ETEA MCQs in the background...',
                  style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey.shade700),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../constants/colors.dart';
import '../../loginscreen.dart';
import '../../main.dart';
import '../../services/yamluploadservicewithcompletedata.dart';

class TextToYamlUploadScreen extends StatefulWidget {
  @override
  _TextToYamlUploadScreenState createState() => _TextToYamlUploadScreenState();
}

class _TextToYamlUploadScreenState extends State<TextToYamlUploadScreen> {
  final YamlCompleteUploadService _yamlUploadService = YamlCompleteUploadService();
  final TextEditingController _textController = TextEditingController();
  int _uploadingCount = 0;

  Future<void> _uploadText() async {
    if (_textController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter some text')),
      );
      return;
    }


    String textToUpload = _textController.text;
    if (!_isValidFormat(textToUpload)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Invalid format! Please follow the specified structure.')),
      );
      return;
    }

    setState(() {
      _uploadingCount++;
    });

    _textController.clear();


    _yamlUploadService.processTextData(textToUpload).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Data uploaded successfully')),
      );
    }).catchError((e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error uploading data: $e')),
      );
    }).whenComplete(() {
      setState(() {
        _uploadingCount--;
      });
    });
  }



  bool _isValidFormat(String text) {
    // Split lines and trim whitespace, but keep empty lines
    final lines = text.split('\n').map((line) => line.trim()).toList();
    if (lines.isEmpty) return false;

    // Updated regex to match the exact format (Year, Subject, Chapter)
    final headerPattern = RegExp(r'^(Class\s\d+|1st\sYear|2nd\sYear),\s[A-Za-z\s]+,\s(Chapter\s\d+|[A-Za-z\s]+)$');


    int i = 0;
    while (i < lines.length) {
      // Skip any empty lines before the header
      while (i < lines.length && lines[i].isEmpty) {
        i++;
      }
      if (i >= lines.length) break;

      // Validate header (year, subject, chapter)
      if (!headerPattern.hasMatch(lines[i])) {
        print('Invalid header format: "${lines[i]}"');
        return false;
      }
      i++;

      // Process questions under this header
      while (i < lines.length) {
        // Skip any empty lines between questions or options
        while (i < lines.length && lines[i].isEmpty) {
          i++;
        }
        if (i >= lines.length) break;

        // If we find a new header, break inner loop to process it
        if (headerPattern.hasMatch(lines[i])) {
          break;
        }

        // Validate MCQ format
        if (lines[i].startsWith('Q:')) {
          i++;
          // Skip empty lines between question and options
          while (i < lines.length && lines[i].isEmpty) i++;

          // Ensure options A:, B:, C:, D: are not empty
          if (i >= lines.length || !lines[i].startsWith('A:') || lines[i].substring(2).trim().isEmpty) return false;
          i++;
          while (i < lines.length && lines[i].isEmpty) i++;

          if (i >= lines.length || !lines[i].startsWith('B:') || lines[i].substring(2).trim().isEmpty) return false;
          i++;
          while (i < lines.length && lines[i].isEmpty) i++;

          if (i >= lines.length || !lines[i].startsWith('C:') || lines[i].substring(2).trim().isEmpty) return false;
          i++;
          while (i < lines.length && lines[i].isEmpty) i++;

          if (i >= lines.length || !lines[i].startsWith('D:') || lines[i].substring(2).trim().isEmpty) return false;
          i++;
          while (i < lines.length && lines[i].isEmpty) i++;

          if (i >= lines.length || !lines[i].startsWith('Ans:') || lines[i].substring(4).trim().isEmpty) return false;
          i++;
        }
        // Validate standalone question format
        else if (lines[i].startsWith('Question:')) {
          i++;
        }
        else {
          return false;
        }
      }
    }

    return true;
  }




  void _showFormatExample() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Input Format Example'),
          content: SingleChildScrollView(
            child: Text(
              'Class 10, Physics, Motion\n'
                  'Q: What is the SI unit of velocity?\n'
                  'A: m/s\n'
                  'B: km/h\n'
                  'C: m/s²\n'
                  'D: km/s\n'
                  'Ans: A\n\n'
                  'Q: Which of the following is a vector quantity?\n'
                  'A: Mass\n'
                  'B: Temperature\n'
                  'C: Displacement\n'
                  'D: Time\n'
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
        title: Text('Upload MCQs'),
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
                      'Paste your MCQs here in the following format: Class, Subject, Chapter on the first line. '
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
                      hintText: 'Paste your MCQs here...',
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _uploadText,
              child: Text('Upload MCQs', style: TextStyle(fontSize: 16)),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
            if (_uploadingCount > 0)
              Padding(
                padding: EdgeInsets.only(top: 16.0),
                child: Text(
                  'Uploading $_uploadingCount set(s) of MCQs in the background...',
                  style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey.shade700),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

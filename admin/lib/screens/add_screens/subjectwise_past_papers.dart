import 'dart:io';
import 'package:admin/services/add_service.dart';
import 'package:admin/services/get_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

import '../../constants/colors.dart';
import '../../loginscreen.dart';

class UploadPastPaperPdfScreen extends StatefulWidget {
  @override
  _UploadPastPaperPdfScreenState createState() => _UploadPastPaperPdfScreenState();
}

class _UploadPastPaperPdfScreenState extends State<UploadPastPaperPdfScreen> {
  FirebaseStorage _storage = FirebaseStorage.instance;
  final AddService _addService = AddService();
  final GetService _getService = GetService();

  bool _isUploadingPDF = false;
  String? _selectedClass;
  String? _selectedSubject;
  final _classController = TextEditingController();
  final _subjectController = TextEditingController();
  List<String> _classes = [];
  List<String> _subjects = [];
  final _formKey = GlobalKey<FormState>();
  String fileName = 'past_papers/${DateTime.now().millisecondsSinceEpoch}.pdf';

  @override
  void initState() {
    super.initState();
    _loadClasses().then((_) => _validateAndUpdateSelectedValues());
  }




  Future<void> _loadClasses() async {
    final classes = await _getService.getClasses();
    setState(() {
      _classes = classes.toSet().toList();
      _validateAndUpdateSelectedValues();
    });
  }

  Future<void> _loadSubjects(String className) async {
    final subjects = await _getService.getSubjects(className);
    setState(() {
      _subjects = subjects.toSet().toList();
      _validateAndUpdateSelectedValues();
    });
  }



  void _validateAndUpdateSelectedValues() {
    if (_selectedClass != null && !_classes.contains(_selectedClass)) {
      _selectedClass = null;
    }
    if (_selectedSubject != null && !_subjects.contains(_selectedSubject)) {
      _selectedSubject = null;
    }

  }

  void _createAndAddClass() async {
    final cls = _classController.text;
    if (cls.isNotEmpty) {
      await _addService.addClass(cls);
      await _loadClasses();
      setState(() {
        _selectedClass = cls;
        _selectedSubject = null;

        _subjects.clear();

      });
      _classController.clear();
    }
  }

  void _createAndAddSubject() async {
    final subject = _subjectController.text;
    if (subject.isNotEmpty) {
      await _addService.addSubject(_selectedClass!,subject);
      await _loadSubjects(_selectedClass!);
      setState(() {
        _selectedSubject = subject;
      });
      _subjectController.clear();
    }
  }



  Future<void> _uploadPdf() async {
    print("Starting file picker");
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      withData: true,
    );

    if (result == null || result.files.isEmpty) {
      print("No file selected");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No file selected')),
      );
      return;
    }

    print("File selected");
    PlatformFile file = result.files.first;
    String originalFileName = file.name;


    setState(() {
      _isUploadingPDF = true;
    });

    try {
      print("Starting upload");
      String fileName = 'past_papers/${DateTime.now().millisecondsSinceEpoch}.pdf';
      TaskSnapshot uploadTask;

      if (file.bytes != null) {
        print("Uploading with bytes");
        uploadTask = await _storage.ref(fileName).putData(file.bytes!);
      } else if (file.path != null) {
        print("Uploading with file path");
        File localFile = File(file.path!);
        uploadTask = await _storage.ref(fileName).putFile(localFile);
      } else {
        throw Exception('Neither file path nor byte data available');
      }

      print("Upload completed, getting download URL");
      String downloadUrl = await uploadTask.ref.getDownloadURL();

      print('Download URL: $downloadUrl');
      setState(() {
        _isUploadingPDF = false;
      });

      print("Saving metadata");
      await _addService.savePastPaperPdfMetadata(
        _selectedClass!,
        _selectedSubject!,
        fileName,
        originalFileName, // Pass the original name
      );

      print("Upload process completed");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('PDF uploaded successfully')),
      );
    } catch (e) {
      print("Error during upload: $e");
      setState(() {
        _isUploadingPDF = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to upload PDF: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    print('Classes: $_classes');
    print('Selected Class: $_selectedClass');
    print('Subjects: $_subjects');
    print('Selected Subject: $_selectedSubject');

    return Scaffold(
      appBar: AppBar(title: Text('Upload PDF'),
        backgroundColor: customYellow,
        elevation: 0,
        actions: [
          TextButton.icon(
            icon: Icon(Icons.exit_to_app),
            label: Text('Logout'),
            onPressed: () {

            },
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                DropdownButtonFormField<String>(
                  value: _classes.contains(_selectedClass) ? _selectedClass : null,
                  items: _classes.map((cls) {
                    return DropdownMenuItem<String>(
                      value: cls,
                      child: Text(cls),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedClass = value;
                      _selectedSubject = null;
                      _subjects.clear();
                      if (value != null) {
                        _loadSubjects(value);
                      }
                    });
                  },
                  decoration: InputDecoration(labelText: 'Select Class'),
                  validator: (value) => value == null ? 'Please select a class' : null,
                ),
                if (_selectedClass == null) ...[
                  TextFormField(
                    controller: _classController,
                    decoration: InputDecoration(labelText: 'Or Create New Class'),
                    validator: (value) => value!.isEmpty ? 'Class is required' : null,
                  ),
                  ElevatedButton(
                    onPressed: _createAndAddClass,
                    child: Text('Create Class'),
                  ),
                ],

                DropdownButtonFormField<String>(
                  value: _subjects.contains(_selectedSubject) ? _selectedSubject : null,
                  items: _subjects.map((subject) {
                    return DropdownMenuItem<String>(
                      value: subject,
                      child: Text(subject),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedSubject = value;


                    });
                  },
                  decoration: InputDecoration(labelText: 'Select Subject'),
                  validator: (value) => value == null ? 'Please select a subject' : null,
                ),
                if (_selectedSubject == null) ...[
                  TextFormField(
                    controller: _subjectController,
                    decoration: InputDecoration(labelText: 'Or Create New Subject'),
                    validator: (value) => value!.isEmpty ? 'Subject is required' : null,
                  ),
                  ElevatedButton(
                    onPressed: _createAndAddSubject,
                    child: Text('Create Subject'),
                  ),
                ],


                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _isUploadingPDF ? null : _uploadPdf, // Disable button if uploading
                  child: _isUploadingPDF
                      ? Text('Uploading...') // Change text to indicate uploading
                      : Text('Upload PDF'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

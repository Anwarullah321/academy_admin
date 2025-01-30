import 'dart:io';
import 'package:admin/services/add_service.dart';
import 'package:admin/services/get_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class UploadPdfScreen extends StatefulWidget {
  @override
  _UploadPdfScreenState createState() => _UploadPdfScreenState();
}

class _UploadPdfScreenState extends State<UploadPdfScreen> {
  FirebaseStorage _storage = FirebaseStorage.instance;
  final AddService _addService = AddService();
  final GetService _getService = GetService();

  bool _isUploadingPDF = false;
  String? _selectedSubject;
  String? _selectedChapter;
  final _subjectController = TextEditingController();
  final _chapterController = TextEditingController();
  List<String> _subjects = [];
  List<String> _chapters = [];
  final _formKey = GlobalKey<FormState>();
  String fileName = 'pdf_notes/${DateTime.now().millisecondsSinceEpoch}.pdf';

  @override
  void initState() {
    super.initState();
    _loadSubjects().then((_) => _validateAndUpdateSelectedValues());
  }



  Future<void> _loadSubjects() async {
    final subjects = await _getService.getEteaSubjects();
    setState(() {
      _subjects = subjects.toSet().toList();
      _validateAndUpdateSelectedValues();
    });
  }

  Future<void> _loadChapters(String subject) async {
    final chapters = await _getService.getEteaChapters(subject);
    setState(() {
      _chapters = chapters.toSet().toList();
      _validateAndUpdateSelectedValues();
    });
  }

  void _validateAndUpdateSelectedValues() {
    if (_selectedSubject != null && !_subjects.contains(_selectedSubject)) {
      _selectedSubject = null;
    }
    if (_selectedChapter != null && !_chapters.contains(_selectedChapter)) {
      _selectedChapter = null;
    }
  }



  void _createAndAddSubject() async {
    final subject = _subjectController.text;
    if (subject.isNotEmpty) {
      await _addService.addEteaSubject(subject);
      await _loadSubjects();
      setState(() {
        _selectedSubject = subject;
        _selectedChapter = null;
        _chapters.clear();
      });
      _subjectController.clear();
    }
  }

  void _createAndAddChapter() async {
    final chapter = _chapterController.text;
    if (chapter.isNotEmpty && _selectedSubject != null) {
      await _addService.addEteaChapter( _selectedSubject!, chapter);
      await _loadChapters( _selectedSubject!);
      setState(() {
        _selectedChapter = chapter;
      });
      _chapterController.clear();
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
      String fileName = 'pdf_notes/${DateTime.now().millisecondsSinceEpoch}.pdf';
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
      await _addService.savePdfMetadata(
        _selectedSubject!,
        _selectedChapter!,
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
    print('Subjects: $_subjects');
    print('Selected Subject: $_selectedSubject');
    print('Chapters: $_chapters');
    print('Selected Chapter: $_selectedChapter');

    return Scaffold(
      appBar: AppBar(title: Text('Upload PDF')),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                
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
                      _selectedChapter = null;
                      _chapters.clear();
                      if (value != null) {
                        _loadChapters( value);
                      }
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
                if (_selectedSubject != null) ...[
                  DropdownButtonFormField<String>(
                    value: _chapters.contains(_selectedChapter) ? _selectedChapter : null,
                    items: _chapters.map((chapter) {
                      return DropdownMenuItem<String>(
                        value: chapter,
                        child: Text(chapter),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedChapter = value;
                      });
                    },
                    decoration: InputDecoration(labelText: 'Select Chapter'),
                    validator: (value) => value == null ? 'Please select a chapter' : null,
                  ),
                  if (_selectedChapter == null) ...[
                    TextFormField(
                      controller: _chapterController,
                      decoration: InputDecoration(labelText: 'Or Create New Chapter'),
                      validator: (value) => value!.isEmpty ? 'Chapter is required' : null,
                    ),
                    ElevatedButton(
                      onPressed: _createAndAddChapter,
                      child: Text('Create Chapter'),
                    ),
                  ],
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

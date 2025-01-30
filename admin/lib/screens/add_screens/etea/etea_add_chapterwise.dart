import 'package:admin/models/mcq_model.dart';
import 'package:admin/services/add_service.dart';
import 'package:admin/services/delete_service.dart';
import 'package:admin/services/get_service.dart';
import 'package:flutter/material.dart';

class AddETEAMCQPage extends StatefulWidget {
  @override
  _AddETEAMCQPageState createState() => _AddETEAMCQPageState();
}

class _AddETEAMCQPageState extends State<AddETEAMCQPage> {
  final AddService _addService = AddService();
  final GetService _getService = GetService();
  final DeleteService _deleteService = DeleteService();
  final _formKey = GlobalKey<FormState>();
  final _questionController = TextEditingController();
  final _optionsController = List<TextEditingController>.generate(4, (_) => TextEditingController());
  int _correctOption = 0;
  bool _isSavingMCQ = false;

  String? _selectedSubject;
  String? _selectedChapter;
  final _subjectController = TextEditingController();
  final _chapterController = TextEditingController();
  List<String> _subjects = [];
  List<String> _chapters = [];
  List<MCQ> _mcqs = [];

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

  Future<void> _loadMCQs(String subject, String chapter) async {
    final mcqs = await _getService.getEteaChapterwiseMCQs(subject, chapter);
    setState(() {
      _mcqs = mcqs;
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

  void _clearMCQForm() {
    _questionController.clear();
    _optionsController.forEach((controller) => controller.clear());
    _correctOption = 0;
  }

  void _saveMCQ() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSavingMCQ = true;
      });
      final mcq = MCQ(
        id: '',
        question: _questionController.text,
        options: _optionsController.map((controller) => controller.text).toList(),
        correctOption: _correctOption,
        year: DateTime.now().year,
      );
      await _addService.addEteaChapterwiseMCQ(_selectedSubject!, _selectedChapter!, mcq);
      _loadMCQs(_selectedSubject!, _selectedChapter!);
      _clearMCQForm();
      setState(() {
        _isSavingMCQ = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('MCQ added successfully')));
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
        _mcqs.clear();
      });
      _subjectController.clear();
      _clearMCQForm();
    }
  }

  void _createAndAddChapter() async {
    final chapter = _chapterController.text;
    if (chapter.isNotEmpty && _selectedSubject != null) {
      await _addService.addEteaChapter(_selectedSubject!, chapter);
      await _loadChapters(_selectedSubject!);
      setState(() {
        _selectedChapter = chapter;
        _mcqs.clear();
      });
      _chapterController.clear();
      _clearMCQForm();
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add MCQ')),
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
                      _mcqs.clear();
                      if (value != null) {
                        _loadChapters(value);
                      }
                    });
                    _clearMCQForm();
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
                        _mcqs.clear();
                      });
                      _clearMCQForm();
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
                TextFormField(
                  controller: _questionController,
                  decoration: InputDecoration(labelText: 'Question'),
                  validator: (value) => value!.isEmpty ? 'Question is required' : null,
                ),
                ..._optionsController.map((controller) {
                  return TextFormField(
                    controller: controller,
                    decoration: InputDecoration(labelText: 'Option'),
                    validator: (value) => value!.isEmpty ? 'Option is required' : null,
                  );
                }).toList(),
                DropdownButtonFormField<int>(
                  value: _correctOption,
                  items: List.generate(4, (index) {
                    return DropdownMenuItem<int>(
                      value: index,
                      child: Text('Option ${index + 1}'),
                    );
                  }),
                  onChanged: (value) {
                    setState(() {
                      _correctOption = value!;
                    });
                  },
                  decoration: InputDecoration(labelText: 'Correct Option'),
                  validator: (value) => value == null ? 'Please select the correct option' : null,
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _isSavingMCQ ? null : _saveMCQ,
                  child: _isSavingMCQ
                      ? Text('Saving...')
                      : Text('Save MCQ'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
import 'package:admin/services/add_service.dart';
import 'package:admin/services/get_service.dart';
import 'package:flutter/material.dart';

import '../../models/question_model.dart';

class AddQuestionPage extends StatefulWidget {
  @override
  _AddQuestionPageState createState() => _AddQuestionPageState();
}

class _AddQuestionPageState extends State<AddQuestionPage> {
  final AddService _addService = AddService();
  final GetService _getService = GetService();
  final _formKey = GlobalKey<FormState>();
  final _questionController = TextEditingController();
  bool _isSavingQuestion = false;
  String? _selectedClass;
  String? _selectedSubject;
  String? _selectedChapter;
  final _classController = TextEditingController();
  final _subjectController = TextEditingController();
  final _chapterController = TextEditingController();
  List<String> _classes = [];
  List<String> _subjects = [];
  List<String> _chapters = [];
  List<Question> _questions = [];

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

  Future<void> _loadChapters(String className, String subject) async {
    final chapters = await _getService.getChapters(className, subject);
    setState(() {
      _chapters = chapters.toSet().toList();
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
    if (_selectedChapter != null && !_chapters.contains(_selectedChapter)) {
      _selectedChapter = null;
    }
  }

  Future<void> _loadQuestions(String className, String subject, String chapter) async {
    final questions = await _getService.getChapterwiseQuestions(className, subject, chapter);
    setState(() {
      _questions = questions;
    });
  }

  void _clearQuestionForm() {
    _questionController.clear();
  }

  void _saveQuestion() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSavingQuestion = true; // Show loading indicator
      });
      final question = Question(
        id: '',
        question: _questionController.text,
        // answer: _answerController.text,
        year: DateTime.now().year
      );
      await _addService.addChapterwiseQuestion(_selectedClass!, _selectedSubject!, _selectedChapter!, question);
      _loadQuestions(_selectedClass!, _selectedSubject!, _selectedChapter!);

      _clearQuestionForm();
      setState(() {
        _isSavingQuestion = false; // Hide loading indicator
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Question added successfully!')),
      );
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
      _clearQuestionForm();
    }
  }

  void _createAndAddSubject() async {
    final subject = _subjectController.text;
    if (subject.isNotEmpty) {
      await _addService.addSubject(_selectedClass!, subject);
      await _loadSubjects(_selectedClass!);
      setState(() {
        _selectedSubject = subject;
        _selectedChapter = null;
        _chapters.clear();
      });
      _subjectController.clear();
      _clearQuestionForm();
    }
  }

  void _createAndAddChapter() async {
    final chapter = _chapterController.text;
    if (chapter.isNotEmpty && _selectedSubject != null) {
      await _addService.addChapter(_selectedClass!, _selectedSubject!, chapter);
      await _loadChapters(_selectedClass!, _selectedSubject!);
      setState(() {
        _selectedChapter = chapter;
      });
      _chapterController.clear();
      _clearQuestionForm();
    }
  }

  @override
  Widget build(BuildContext context) {
    print('classes: $_classes');
    print('selected Class: $_selectedClass');
    print('Subjects: $_subjects');
    print('Selected Subject: $_selectedSubject');
    print('Chapters: $_chapters');
    print('Selected Chapter: $_selectedChapter');

    return Scaffold(
      appBar: AppBar(title: Text('Add Question')),
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
                    _clearQuestionForm();
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
                      _selectedChapter = null;
                      _chapters.clear();
                      if (value != null) {
                        _loadChapters(_selectedClass!, value);
                      }
                    });
                    _clearQuestionForm();
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
                      _clearQuestionForm();
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
                // SizedBox(height: 20),
                // TextFormField(
                //   controller: _answerController,
                //   decoration: InputDecoration(labelText: 'Answer (Optional)'),
                //   // No specific validation for answer field
                // ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _isSavingQuestion ? null : _saveQuestion, // Disable button if saving
                  child: Text(_isSavingQuestion ? 'Saving...' : 'Save Question'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
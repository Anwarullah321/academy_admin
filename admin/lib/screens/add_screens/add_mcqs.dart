import 'package:admin/services/add_service.dart';
import 'package:admin/services/get_service.dart';
import 'package:flutter/material.dart';
import '../../models/mcq_model.dart';

class AddMCQPage extends StatefulWidget {
  @override
  _AddMCQPageState createState() => _AddMCQPageState();
}

class _AddMCQPageState extends State<AddMCQPage> {
  final AddService _addService = AddService();
  final GetService _getService = GetService();
  final _formKey = GlobalKey<FormState>();
  final _questionController = TextEditingController();
  final _optionsController = List<TextEditingController>.generate(4, (_) => TextEditingController());
  int _correctOption = 0;
  bool _isSavingMCQ = false;

  String? _selectedClass;
  String? _selectedSubject;
  String? _selectedChapter;
  final _classController = TextEditingController();
  final _subjectController = TextEditingController();
  final _chapterController = TextEditingController();
  List<String> _classes = [];
  List<String> _subjects = [];
  List<String> _chapters = [];
  List<MCQ> _mcqs = [];

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

  Future<void> _loadMCQs(String className, String subject, String chapter) async {
    final mcqs = await _getService.getChapterwiseMCQs(className, subject, chapter);
    setState(() {
      _mcqs = mcqs;
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
      await _addService.addChapterwiseMCQ(_selectedClass!, _selectedSubject!, _selectedChapter!, mcq);
      _loadMCQs(_selectedClass!, _selectedSubject!, _selectedChapter!);
      _clearMCQForm();
      setState(() {
        _isSavingMCQ = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('MCQ added successfully!')),
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
        _selectedChapter = null;
        _subjects.clear();
        _chapters.clear();
        _mcqs.clear();
      });
      _classController.clear();
      _clearMCQForm();
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
        _mcqs.clear();
      });
      _subjectController.clear();
      _clearMCQForm();
    }
  }

  void _createAndAddChapter() async {
    final chapter = _chapterController.text;
    if (chapter.isNotEmpty && _selectedSubject != null) {
      await _addService.addChapter(_selectedClass!, _selectedSubject!, chapter);
      await _loadChapters(_selectedClass!, _selectedSubject!);
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
                      _selectedChapter = null;
                      _subjects.clear();
                      _chapters.clear();
                      _mcqs.clear();
                      if (value != null) {
                        _loadSubjects(value);
                      }
                    });
                    _clearMCQForm();
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
                      _mcqs.clear();
                      if (value != null) {
                        _loadChapters(_selectedClass!, value);
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
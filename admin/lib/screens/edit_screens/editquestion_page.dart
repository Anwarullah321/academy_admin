import 'package:admin/providers/AuthProvider.dart';
import 'package:admin/services/update_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../constants/colors.dart';
import '../../loginscreen.dart';
import '../../mcq_provider.dart';
import '../../models/question_model.dart';
import '../../providers/QuestionProvider.dart';

enum SaveDiscardCancel { save, discard, cancel }

class EditQuestionPage extends StatefulWidget {
  final String selectedClass;
  final String selectedSubject;
  final String selectedChapter;
  final Question question;

  const EditQuestionPage({
    Key? key,
    required this.selectedClass,
    required this.selectedSubject,
    required this.selectedChapter,
    required this.question,
  }) : super(key: key);

  @override
  _EditQuestionPageState createState() => _EditQuestionPageState();
}

class _EditQuestionPageState extends State<EditQuestionPage> {
  final UpdateService _updateService = UpdateService();
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _questionController;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _questionController = TextEditingController(text: widget.question.question);
    _questionController.addListener(_checkForChanges);
    Future.microtask(() {
      final provider = Provider.of<QuestionProvider>(context, listen: false);
      provider.loadQuestions(widget.selectedClass, widget.selectedSubject, widget.selectedChapter);
    });
  }

  @override
  void dispose() {
    _questionController.removeListener(_checkForChanges);
    super.dispose();
  }

  void _checkForChanges() {
    final hasChanges = _questionController.text != widget.question.question;
    if (hasChanges != _hasChanges) {
      setState(() => _hasChanges = hasChanges);
    }
  }

  bool get hasUnsavedChanges => _hasChanges;

  Future<bool> _saveEditedQuestion() async {
    if (_formKey.currentState!.validate()) {
      try {
        final updatedQuestion = Question(
            id: widget.question.id,
            question: _questionController.text,
            year: DateTime.now().year
        );

        await _updateService.updateChapterwiseQuestion(
          widget.selectedClass,
          widget.selectedSubject,
          widget.selectedChapter,
          updatedQuestion,
        );
        return true;
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Save failed: $e'))
        );
        return false;
      }
    }
    return false;
  }

  Future<SaveDiscardCancel?> _showSaveDiscardDialog() async {
    return await showDialog<SaveDiscardCancel>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Unsaved Changes'),
        content: Text('You have unsaved changes. Save before leaving?'),
        actions: [
          TextButton(
            child: Text('Cancel'),
            onPressed: () => Navigator.pop(context, SaveDiscardCancel.cancel),
          ),
          TextButton(
            child: Text('Discard'),
            onPressed: () => Navigator.pop(context, SaveDiscardCancel.discard),
          ),
          TextButton(
            child: Text('Save'),
            onPressed: () => Navigator.pop(context, SaveDiscardCancel.save),
          ),
        ],
      ),
    );
  }

  Future<bool> _handleExitConditions() async {
    if (!hasUnsavedChanges) return true;

    final choice = await _showSaveDiscardDialog();
    switch (choice) {
      case SaveDiscardCancel.save:
        final saved = await _saveEditedQuestion();
        return saved;
      case SaveDiscardCancel.discard:
        return true;
      case SaveDiscardCancel.cancel:
      default:
        return false;
    }
  }

  void _navigateToLogin() {
    GoRouter.of(context).pushReplacement('/login');

  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => true,
      child: Consumer<QuestionProvider>(
        builder: (context, provider, child) {
          final mcq = provider.selectedQuestion;

          if (mcq == null) {
            return Scaffold(
              appBar: AppBar(title: Text('Edit MCQ')),
              body: Center(child: Text('No Questions selected!')),
            );
          }

          return Scaffold(
            appBar: AppBar(
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
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ETEA',
                    style: const TextStyle(
                      color: Colors.black87,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${widget.selectedSubject} - ${widget.selectedChapter}',
                    style: const TextStyle(
                      color: darkGrey,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            body: Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: Text(
                        'Edit Question',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    TextFormField(
                      controller: _questionController,
                      decoration: InputDecoration(
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: customYellow, width: 3.0),
                        ),
                      ),
                      validator: (value) => value!.isEmpty ? 'Question is required' : null,
                    ),


                    SizedBox(height: 20),
                    Center(
                      child: Card(
                        elevation: 4,
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              final updatedQuestion = Question(
                                id: widget.question.id,
                                question: _questionController.text,
                                year: DateTime.now().year,
                              );

                              final questionProvider = Provider.of<QuestionProvider>(context, listen: false);

                              try {

                                await questionProvider.updateQuestion(
                                  widget.selectedClass,
                                  widget.selectedSubject,
                                  widget.selectedChapter,
                                  updatedQuestion,
                                );


                                if (context.canPop()) {
                                  context.pop();
                                } else {
                                  context.go('/chapter_detail/${widget.selectedClass}/${widget.selectedSubject}/${widget.selectedChapter}/1');
                                }

                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Error updating MCQ: $e')),
                                );
                              }
                            }
                          },



                          style: ElevatedButton.styleFrom(
                            backgroundColor: customYellow,
                          ),
                          icon: Icon(Icons.save, color: Colors.black),
                          label: Text(
                            'Save Changes',
                            style: TextStyle(color: Colors.black),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
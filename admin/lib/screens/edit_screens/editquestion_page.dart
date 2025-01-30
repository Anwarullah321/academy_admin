import 'package:admin/services/update_service.dart';
import 'package:flutter/material.dart';
import '../../constants/colors.dart';
import '../../loginscreen.dart';
import '../../models/question_model.dart';

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
  final _questionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _questionController.text = widget.question.question;
  }

  void _saveEditedQuestion() async {
    if (_formKey.currentState!.validate()) {
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
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.selectedClass,
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
                padding: const EdgeInsets.only(bottom: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Edit Question',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(vertical: 8.0),

                child: TextFormField(
                  controller: _questionController,
                  maxLines: null,
                  decoration: InputDecoration(

                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: customYellow, width: 3.0),
                    ),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey, width: 1.0),
                    ),
                    floatingLabelStyle: TextStyle(
                      color: customYellow,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  validator: (value) => value!.isEmpty ? 'Question is required' : null,
                ),
              ),
              SizedBox(height: 32),
              Center(
                child: Card(
                  elevation: 4,
                  child: ElevatedButton.icon(
                    onPressed: _saveEditedQuestion,
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
  }
}
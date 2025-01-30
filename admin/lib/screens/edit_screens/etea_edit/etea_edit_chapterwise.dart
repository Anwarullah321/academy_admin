import 'package:admin/models/mcq_model.dart';
import 'package:admin/services/update_service.dart';
import 'package:flutter/material.dart';

import '../../../constants/colors.dart';
import '../../../loginscreen.dart';

class EditMCQPage extends StatefulWidget {
  final String subject;
  final String chapter;
  final MCQ mcq;

  EditMCQPage({required this.subject, required this.chapter, required this.mcq});

  @override
  _EditMCQPageState createState() => _EditMCQPageState();
}

class _EditMCQPageState extends State<EditMCQPage> {
  final UpdateService _updateService = UpdateService();
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _questionController;
  late List<TextEditingController> _optionsController;
  late int _correctOption;

  @override
  void initState() {
    super.initState();
    _questionController = TextEditingController(text: widget.mcq.question);
    _optionsController = widget.mcq.options
        .map((option) => TextEditingController(text: option))
        .toList();
    _correctOption = widget.mcq.correctOption;
  }

  void _saveMCQ() async {
    if (_formKey.currentState!.validate()) {
      final updatedMCQ = MCQ(
        id: widget.mcq.id,
        question: _questionController.text,
        options: _optionsController.map((controller) => controller.text).toList(),
        correctOption: _correctOption,
        year: DateTime.now().year,
      );
      await _updateService.updateEteaChapterwiseMCQ(widget.subject, widget.chapter, widget.mcq.id, updatedMCQ);
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
              'ETEA',
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '${widget.subject} - ${widget.chapter}',
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Edit MCQ',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
              TextFormField(
                controller: _questionController,
                decoration: InputDecoration(
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: customYellow, width: 3.0),
                  ),
                ),
                validator: (value) => value!.isEmpty ? 'MCQ is required' : null,
              ),
              SizedBox(height: 35),
              ..._optionsController.asMap().entries.map((entry) {
                int index = entry.key;
                var controller = entry.value;
                return Padding(
                  padding: const EdgeInsets.all(1.0),
                  child: TextFormField(
                    controller: controller,
                    decoration: InputDecoration(
                      labelText: 'Option ${String.fromCharCode(65 + index)}',
                      labelStyle: TextStyle(
                        color: index == _correctOption ? customYellow : Colors.black87,
                        fontWeight: index == _correctOption ? FontWeight.bold : FontWeight.normal,
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: index == _correctOption ? customYellow : Colors.grey,
                          width: index == _correctOption ? 3.0 : 2.0,
                        ),
                      ),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: index == _correctOption ? customYellow : Colors.grey,
                          width: index == _correctOption ? 3.0 : 2.0,
                        ),
                      ),
                    ),
                    validator: (value) => value!.isEmpty ? 'Option is required' : null,
                  ),
                );
              }).toList(),
              SizedBox(height: 35),
              Theme(
                data: Theme.of(context).copyWith(
                  canvasColor: customGrey,
                ),

                child: DropdownButtonFormField<int>(
                  borderRadius: BorderRadius.circular(10),
                  value: _correctOption,
                  items: List.generate(
                    _optionsController.length,
                        (index) => DropdownMenuItem<int>(
                      value: index,
                      child: Text(
                        String.fromCharCode(65 + index),
                        style: TextStyle(
                          color: index == _correctOption ? customYellow : Colors.black,
                          fontWeight: index == _correctOption ? FontWeight.bold: FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _correctOption = value!;
                    });
                  },
                  decoration: InputDecoration(
                    labelText: 'Correct Option',
                    labelStyle: TextStyle(
                      color: customYellow,
                      fontWeight: FontWeight.bold,
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: customYellow, width: 3.0),
                    ),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: customYellow, width: 3.0),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),
              Center(
                child: Card(
                  elevation: 4,
                  child: ElevatedButton.icon(
                    onPressed: _saveMCQ,
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

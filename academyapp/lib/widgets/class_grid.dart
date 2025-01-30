import 'package:flutter/material.dart';

import '../services/mcq_services.dart';
import 'class_button.dart';

class ClassGrid extends StatefulWidget {
  final List<String> classes;
  final MCQService mcqService;

  const ClassGrid({Key? key, required this.classes, required this.mcqService}) : super(key: key);

  @override
  State<ClassGrid> createState() => _ClassGridState();
}

class _ClassGridState extends State<ClassGrid> {
  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: EdgeInsets.all(16.0),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16.0,
        mainAxisSpacing: 16.0,
      ),
      itemCount: widget.classes.length,
      itemBuilder: (context, index) {
        final className = widget.classes[index];
        return ClassButton(className: className, mcqService: widget.mcqService);
      },
    );
  }
}

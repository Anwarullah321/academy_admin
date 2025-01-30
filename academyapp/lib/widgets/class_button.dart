import 'package:flutter/material.dart';
import '../services/mcq_services.dart';
import '../utils/navigation.dart';

class ClassButton extends StatefulWidget {
  final String className;
  final MCQService mcqService;

  const ClassButton({Key? key, required this.className, required this.mcqService}) : super(key: key);

  @override
  State<ClassButton> createState() => _ClassButtonState();
}

class _ClassButtonState extends State<ClassButton> {



  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: widget.className == 'ETEA'
          ? widget.mcqService.isEteaLocal()
          : widget.mcqService.isClassLocal(widget.className),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Colors.black,
            ),
          );
        }

        bool isLocal = snapshot.data ?? false;
        return GestureDetector(
          onTap: () {
            if (widget.className == 'ETEA') {
              navigateToEteaSubjects(context, isLocal);
            } else {
              navigateToClassSubjects(context, widget.className, isLocal);
            }
          },
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            color: isLocal ? Colors.yellow : Colors.yellow,

            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 24.0),
              child: Center(
                child: Text(
                  widget.className,
                  style: TextStyle(
                    color: isLocal ? Colors.black : Colors.black,
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 1,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

import 'package:flutter/material.dart';

class Button extends StatelessWidget {
  final VoidCallback onPressed;
  final String text;
  final Color? clr;
  final IconData? iconData;
  final IconData? iconData1;
  const Button({
    super.key,
    this.clr,
    required this.text,
    this.iconData1 = Icons.javascript,
    this.iconData = Icons.javascript,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        height: 50,
        width: 335,
        child: ElevatedButton(
          style: ButtonStyle(
            shape: WidgetStatePropertyAll(RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25))),
            backgroundColor:
            const  WidgetStatePropertyAll<Color>(Colors.black),
          ),
          onPressed: onPressed,
          child: iconData != Icons.javascript
              ? Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Icon(
                  iconData,
                  color: Colors.black,
                ),
              ),
              Expanded(
                child: Text(
                  text,
                  style: const TextStyle(
                      color: Colors.black,
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                ),
              ),
              iconData1 == Icons.javascript
                  ? const SizedBox()
                  : Padding(
                padding: const EdgeInsets.all(8.0),
                child: Icon(
                  iconData1,
                  color: Colors.black,
                ),
              ),
            ],
          )
              : Center(
            child: Text(
              text,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold),
            ),
          ),
        ));
  }
}

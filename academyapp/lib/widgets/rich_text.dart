import 'package:flutter/material.dart';
class RichTextCust extends StatelessWidget {
  final String title;
  final String data;

  const RichTextCust({super.key, required this.data, required this.title});

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        style: const TextStyle(
          color: Colors.black,
          fontSize: 16,
        ),
        children: [
          TextSpan(
            text: "$title:",
            style: const TextStyle(
              fontWeight: FontWeight.normal,
            ),
          ),
          const TextSpan(
            text: "  ",
          ),
          TextSpan(
            text: data,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

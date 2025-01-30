
import 'package:flutter/cupertino.dart';

class RichTextCust extends StatelessWidget {
  final String title;
  final String data;

  const RichTextCust({required this.title, required this.data, super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "$title: ",
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Expanded(child: Text(data)),
        ],
      ),
    );
  }
}
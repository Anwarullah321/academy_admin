import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../whatsapp.dart';

Widget buildLockedOptionCard(BuildContext context, String title, IconData icon,
    Color color) {
  return GestureDetector(
    onTap: () {
      showLockedFeatureDialog(context);
    },
    child: Card(
      elevation: 4,
      color: Colors.yellow,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 3.5),
      child: ListTile(
        leading: Icon(icon, color: color, size: 36),
        title: Text(
          title,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        trailing: Icon(Icons.lock, color: color),
      ),
    ),
  );
}

void showLockedFeatureDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Feature Locked'),
        content: Text('This feature is available only for paid users. Do you want to buy it?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close the dialog
            },
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close the dialog
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => StudentRequestPage(), // Replace with your buy page widget
                ),
              );
            },
            child: Text('Buy'),
          ),
        ],
      );
    },
  );
}

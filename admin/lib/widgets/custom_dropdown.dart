import 'package:flutter/material.dart';

class CustomDropdown extends StatelessWidget {
  final String label;
  final Future<List<String>> items;
  final Function(String?) onChanged;

  const CustomDropdown({
    Key? key,
    required this.label,
    required this.items,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<String>>(
      future: items,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        }
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }
        final itemsList = snapshot.data ?? [];
        return DropdownButtonFormField<String>(
          decoration: InputDecoration(labelText: label),
          items: itemsList.map((item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(item),
            );
          }).toList(),
          onChanged: onChanged,
        );
      },
    );
  }
}
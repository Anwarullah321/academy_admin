import 'package:flutter/material.dart';

class SelectionOrCreationWidget extends StatefulWidget {
  final String label;
  final List<String> items;
  final Function(String?) onSelected;
  final Function(String) onCreate;
  final String? selectedValue;

  const SelectionOrCreationWidget({
    Key? key,
    required this.label,
    required this.items,
    required this.onSelected,
    required this.onCreate,
    this.selectedValue,
  }) : super(key: key);

  @override
  _SelectionOrCreationWidgetState createState() => _SelectionOrCreationWidgetState();
}

class _SelectionOrCreationWidgetState extends State<SelectionOrCreationWidget> {
  final TextEditingController _controller = TextEditingController();
  String? _errorMessage;
  bool _showCreateField = true;

  @override
  void initState() {
    super.initState();
    _showCreateField = widget.selectedValue == null;
  }

  @override
  void didUpdateWidget(SelectionOrCreationWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedValue != oldWidget.selectedValue) {
      setState(() {
        _showCreateField = widget.selectedValue == null;
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool _isValidChapter(String chapter) {
    final RegExp regex = RegExp(r'^chapter \d{2}$');
    return regex.hasMatch(chapter);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownButtonFormField<String>(
          value: widget.items.contains(widget.selectedValue) ? widget.selectedValue : null,
          decoration: InputDecoration(labelText: widget.label),
          items: widget.items.map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          onChanged: (value) {
            widget.onSelected(value);
            setState(() {
              _showCreateField = value == null;
            });
          },
        ),
        if (_showCreateField) ...[
          TextFormField(
            controller: _controller,
            decoration: InputDecoration(
              labelText: 'Create new ${widget.label}',
              errorText: _errorMessage,
            ),
          ),
          ElevatedButton(
            onPressed: () {
              if (_controller.text.isNotEmpty) {
                if (widget.label.toLowerCase() == 'chapter' && !_isValidChapter(_controller.text)) {
                  setState(() {
                    _errorMessage = "Please enter a valid chapter format (e.g., 'chapter 01')";
                  });
                } else {
                  String newItem = _controller.text;
                  widget.onCreate(newItem);
                  _controller.clear();
                  setState(() {
                    _errorMessage = null;
                    _showCreateField = false;
                  });
                }
              } else {
                setState(() {
                  _errorMessage = "Please enter a value";
                });
              }
            },
            child: Text('Create ${widget.label}'),
          ),
        ],
      ],
    );
  }
}
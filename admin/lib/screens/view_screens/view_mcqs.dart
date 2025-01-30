import 'package:admin/services/delete_service.dart';
import 'package:admin/services/get_service.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import '../../../models/mcq_model.dart';
import '../../constants/colors.dart';
import '../edit_screens/editmcq_page.dart';
class YearOption {
  final int? year;
  YearOption(this.year);

  @override
  String toString() => year == null ? 'All' : year.toString();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is YearOption &&
              runtimeType == other.runtimeType &&
              year == other.year;

  @override
  int get hashCode => year.hashCode;
}

class ViewMCQsPage extends StatefulWidget {
  final String selectedClass;
  final String selectedSubject;
  final String selectedChapter;

  const ViewMCQsPage({
    Key? key,
    required this.selectedClass,
    required this.selectedSubject,
    required this.selectedChapter,
  }) : super(key: key);

  @override
  _ViewMCQsPageState createState() => _ViewMCQsPageState();
}

class _ViewMCQsPageState extends State<ViewMCQsPage> {
  final GetService _getService = GetService();
  final DeleteService _deleteService = DeleteService();

  List<MCQ> _mcqs = [];
  YearOption? _selectedYear;
  List<MCQ> _filteredMcqs = [];
  List<YearOption> _uniqueYears = [];
  bool _isDeleting = false;
  bool _isFilterVisible = false;

  @override
  void initState() {
    super.initState();
    _loadMCQs();
    _filteredMcqs = _mcqs;
  }

  Future<void> _loadMCQs() async {
    final mcqs = await _getService.getChapterwiseMCQs(
      widget.selectedClass,
      widget.selectedSubject,
      widget.selectedChapter,
    );

    setState(() {
      _mcqs = mcqs;
      Set<int> uniqueYearValues = mcqs
          .map((mcq) => mcq.year)
          .where((year) => year > 0)
          .toSet();

      _uniqueYears = [
        YearOption(null),
        ...uniqueYearValues.map((year) => YearOption(year)).toList()
          ..sort((a, b) => a.year!.compareTo(b.year!)),
      ];

      _filteredMcqs = mcqs;
      _selectedYear = _uniqueYears.first;
    });
  }

  // void _toggleFilterVisibility() {
  //   setState(() {
  //     _isFilterVisible = !_isFilterVisible;
  //   });
  // }

  void _filterMCQs(YearOption? yearOption) {
    setState(() {
      _selectedYear = yearOption;
      _filteredMcqs = _selectedYear?.year == null
          ? _mcqs
          : _mcqs.where((mcq) => mcq.year == _selectedYear?.year).toList();
    });
  }


  void _editMCQ(MCQ mcq) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            EditMCQPage(
              cls: widget.selectedClass,
              subject: widget.selectedSubject,
              chapter: widget.selectedChapter,
              mcq: mcq,
            ),
      ),
    ).then((_) => _loadMCQs());
  }

  void _deleteMCQ(MCQ mcq) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete MCQ'),
          content: Text('Are you sure you want to delete this MCQ?'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Delete'),
              onPressed: () async {
                setState(() {
                  _isDeleting = true;
                });
                await _deleteService.deleteChpaterwiseMCQ(
                  widget.selectedClass,
                  widget.selectedSubject,
                  widget.selectedChapter,
                  mcq.id,
                );
                setState(() {
                  _isDeleting = false;
                });
                Navigator.of(context).pop();
                _loadMCQs();
              },
            ),
          ],
        );
      },
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Filter by Year'),
          content: SizedBox(

            child: DropdownButtonFormField<YearOption>(
              value: _selectedYear,
              decoration: InputDecoration(
                labelText: 'Select Year',
                labelStyle: TextStyle(color: darkGrey, fontSize: 15),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: darkGrey.withOpacity(0.2)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: darkGrey.withOpacity(0.2)),
                ),
              ),
              items: _uniqueYears.map((yearOption) {
                return DropdownMenuItem<YearOption>(
                  value: yearOption,
                  child: Text(yearOption.toString(), style: TextStyle(fontSize: 14)),
                );
              }).toList(),
              onChanged: (YearOption? newValue) {
                _filterMCQs(newValue); // Filter content
                Navigator.of(context).pop(); // Close dialog
              },
            ),
          ),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog without applying filter
              },
            ),
          ],
        );
      },
    );
  }

  void _showDeleteYearDialog() {
    showDialog(
      context: context,
      builder: (context) {
        YearOption? selectedYearToDelete = _uniqueYears.first;
        bool _isDeleting = false;


        int _calculateTotalMcqsForYear(int? year) {
          return _mcqs.where((mcq) => mcq.year == year).length;
        }

        return StatefulBuilder(
          builder: (context, setState) {

            final totalMcqsForYear = _calculateTotalMcqsForYear(selectedYearToDelete?.year);

            return AlertDialog(
              title: const Text('Delete MCQs by Year'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<YearOption>(
                    value: selectedYearToDelete,
                    decoration: InputDecoration(
                      labelText: 'Select Year',
                      labelStyle: TextStyle(color: darkGrey, fontSize: 15),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: darkGrey.withOpacity(0.2)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: darkGrey.withOpacity(0.2)),
                      ),
                    ),
                    items: _uniqueYears.map((yearOption) {
                      return DropdownMenuItem<YearOption>(
                        value: yearOption,
                        child: Text(yearOption.toString()),
                      );
                    }).toList(),
                    onChanged: _isDeleting
                        ? null
                        : (newValue) {
                      setState(() {
                        selectedYearToDelete = newValue!;
                      });
                    },
                  ),
                  if (_isDeleting) ...[
                    const SizedBox(height: 16),
                    LinearProgressIndicator(
                      value: totalMcqsForYear > 0 ? null : 0,
                    ),
                    const SizedBox(height: 8),
                    Text('Deleting MCQs for year ${selectedYearToDelete?.year}'),
                  ],
                ],
              ),
              actions: [
                TextButton(
                  child: const Text('Cancel'),
                  onPressed: _isDeleting
                      ? null
                      : () {
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: const Text('Delete'),
                  onPressed: _isDeleting
                      ? null
                      : () async {
                    if (selectedYearToDelete != null && selectedYearToDelete!.year != null) {

                      final bool confirm = await showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: const Text('Confirm Deletion'),
                            content: Text(
                              'Are you sure you want to delete all MCQs for the year ${selectedYearToDelete!.year}?',
                            ),
                            actions: [
                              TextButton(
                                child: const Text('Cancel'),
                                onPressed: () {
                                  Navigator.of(context).pop(false);
                                },
                              ),
                              TextButton(
                                child: const Text('Delete'),
                                onPressed: () {
                                  Navigator.of(context).pop(true);
                                },
                              ),
                            ],
                          );
                        },
                      );

                      if (confirm) {
                        setState(() {
                          _isDeleting = true;
                        });

                        try {
                          await _deleteService.deleteMCQsByYear(
                            widget.selectedClass,
                            widget.selectedSubject,
                            widget.selectedChapter,
                            selectedYearToDelete!.year!,
                          );

                          Navigator.of(context).pop();
                          await _loadMCQs();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Deleted MCQs for year ${selectedYearToDelete!.year} successfully',
                              ),
                            ),
                          );
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Failed to delete MCQs: $e'),
                            ),
                          );
                        }
                      }
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: customGrey,
      body: _mcqs.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.quiz_outlined, size: 64, color: darkGrey),
            const SizedBox(height: 16),
            Text(
              'No MCQs available',
              style: TextStyle(
                color: darkGrey,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      )
          : Column(
        children: [

          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [

                IconButton(
                  icon: Icon(Icons.filter_alt, color: Colors.blue),
                  tooltip: 'Filter by Year',
                  onPressed: _showFilterDialog,
                ),
                const SizedBox(width: 8),

                // Delete Icon
                Container(
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: IconButton(
                    icon: Icon(Icons.delete_forever, color: Colors.red),
                    tooltip: 'Delete MCQs by Year',
                    onPressed: _showDeleteYearDialog,
                  ),
                ),
                Expanded(
                  child: Text(
                    '${_filteredMcqs.length} ${_filteredMcqs.length == 1 ? 'MCQ' : 'MCQs'}',
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      color: darkGrey,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),


          // if (_isFilterVisible)
          //   Padding(
          //     padding: const EdgeInsets.all(8),
          //     child: SizedBox(
          //       width: 200,
          //       child: DropdownButtonFormField<YearOption>(
          //         value: _selectedYear,
          //         decoration: InputDecoration(
          //           labelText: 'Filter Year',
          //           labelStyle: TextStyle(color: darkGrey, fontSize: 15),
          //           contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          //           border: OutlineInputBorder(
          //             borderRadius: BorderRadius.circular(8),
          //             borderSide: BorderSide(color: darkGrey.withOpacity(0.2)),
          //           ),
          //           enabledBorder: OutlineInputBorder(
          //             borderRadius: BorderRadius.circular(8),
          //             borderSide: BorderSide(color: darkGrey.withOpacity(0.2)),
          //           ),
          //         ),
          //         items: _uniqueYears.map((yearOption) {
          //           return DropdownMenuItem<YearOption>(
          //             value: yearOption,
          //             child: Text(yearOption.toString(), style: TextStyle(fontSize: 15)),
          //           );
          //         }).toList(),
          //         onChanged: (YearOption? newValue) => _filterMCQs(newValue),
          //       ),
          //     ),
          //   ),

          // MCQs List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _filteredMcqs.length,
              itemBuilder: (context, index) {
                final mcq = _filteredMcqs[index];
                return Container(
                  margin: EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Text(
                          mcq.question,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(5),
                        child: Column(
                          children: mcq.options.asMap().entries.map((entry) {
                            final optionIndex = entry.key;
                            final optionText = entry.value;
                            final isCorrect = optionIndex == mcq.correctOption;
                            final optionLabel = String.fromCharCode(65 + optionIndex);

                            return Container(
                              margin: EdgeInsets.only(bottom: 6),
                              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: isCorrect
                                    ? customYellow.withOpacity(0.8)
                                    : Colors.grey.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(8),
                                border: isCorrect
                                    ? Border.all(color: customYellow)
                                    : Border.all(color: Colors.transparent),
                              ),
                              child: Row(
                                children: [
                                  Text('$optionLabel. $optionText',
                                    style: const TextStyle(
                                      fontSize: 15,
                                    ),
                                  ),

                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit, size: 25, color: customYellow),
                            onPressed: () => _editMCQ(mcq),
                          ),
                          IconButton(
                            icon: Icon(Icons.delete, size: 25, color: Colors.red),
                            onPressed: () => _deleteMCQ(mcq),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }



}



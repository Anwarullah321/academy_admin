import 'package:admin/services/delete_service.dart';
import 'package:admin/services/get_service.dart';
import 'package:flutter/material.dart';
import '../../constants/colors.dart';
import '../../models/question_model.dart';
import '../edit_screens/editquestion_page.dart';

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

class ViewQuestionsScreen extends StatefulWidget {
  final String selectedClass;
  final String selectedSubject;
  final String selectedChapter;

  const ViewQuestionsScreen({
    Key? key,
    required this.selectedClass,
    required this.selectedSubject,
    required this.selectedChapter,
  }) : super(key: key);

  @override
  _ViewQuestionsScreenState createState() => _ViewQuestionsScreenState();
}

class _ViewQuestionsScreenState extends State<ViewQuestionsScreen> {
  final GetService _getService = GetService();
  final DeleteService _deleteService = DeleteService();
  List<Question> _questions = [];
  List<Question> _filteredQuestions = [];
  List<YearOption> _uniqueYears = [];
  YearOption? _selectedYear;
  bool _isLoading = true;
  bool _isFilterVisible = false;


  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    try {
      final questions = await _getService.getChapterwiseQuestions(
        widget.selectedClass,
        widget.selectedSubject,
        widget.selectedChapter,
      );


      Set<int> uniqueYearValues = questions
          .map((question) => question.year)
          .where((year) => year > 0)
          .toSet();

      setState(() {
        _questions = questions;
        _filteredQuestions = questions;
        _uniqueYears = [
          YearOption(null),
          ...uniqueYearValues.map((year) => YearOption(year)).toList()
            ..sort((a, b) => a.year!.compareTo(b.year!))
        ];
        _selectedYear = _uniqueYears.first;
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching questions: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }


  void _toggleFilterVisibility() {
    setState(() {
      _isFilterVisible = !_isFilterVisible;
    });
  }

  void _filterQuestions(YearOption? yearOption) {
    setState(() {
      _selectedYear = yearOption;
      _filteredQuestions = _selectedYear?.year == null
          ? _questions
          : _questions.where((Question) => Question.year == _selectedYear?.year).toList();
    });
  }

  void _editQuestion(Question question) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditQuestionPage(
          selectedClass: widget.selectedClass,
          selectedSubject: widget.selectedSubject,
          selectedChapter: widget.selectedChapter,
          question: question,
        ),
      ),
    ).then((_) => _loadQuestions());
  }

  void _deleteQuestion(Question question) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Question'),
          content: Text('Are you sure you want to delete this question?'),
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
                await _deleteService.deleteChapterwiseQuestion(
                  widget.selectedClass,
                  widget.selectedSubject,
                  widget.selectedChapter,
                  question.id,
                );
                Navigator.of(context).pop();
                _loadQuestions();
              },
            ),
          ],
        );
      },
    );
  }

  // void _filterQuestionsByYear(YearOption? selectedYear) {
  //   setState(() {
  //     _selectedYear = selectedYear;
  //     _filteredQuestions = _selectedYear?.year == null
  //         ? _questions
  //         : _questions
  //         .where((question) => question.year == _selectedYear?.year)
  //         .toList();
  //   });
  // }

  void _showDeleteYearDialog() {
    showDialog(
      context: context,
      builder: (context) {
        YearOption? selectedYearToDelete = _uniqueYears.first;
        bool _isDeleting = false;


        int _calculateTotalQuestionsForYear(int? year) {
          return _questions.where((question) => question.year == year).length;
        }

        return StatefulBuilder(
          builder: (context, setState) {

            final totalQuestionsForYear = _calculateTotalQuestionsForYear(selectedYearToDelete?.year);

            return AlertDialog(
              title: const Text('Delete Questions by Year'),
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
                      value: totalQuestionsForYear > 0 ? null : 0,
                    ),
                    const SizedBox(height: 8),
                    Text('Deleting Questions for year ${selectedYearToDelete?.year}'),
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
                      // Show confirmation dialog
                      final bool confirm = await showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: const Text('Confirm Deletion'),
                            content: Text(
                              'Are you sure you want to delete all questions for the year ${selectedYearToDelete!.year}?',
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
                          await _deleteService.deleteQuestionsByYear(
                            widget.selectedClass,
                            widget.selectedSubject,
                            widget.selectedChapter,
                            selectedYearToDelete!.year!,
                          );

                          Navigator.of(context).pop();
                          await _loadQuestions();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Deleted questions for year ${selectedYearToDelete!.year} successfully',
                              ),
                            ),
                          );
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Failed to delete questions: $e'),
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
      body: _questions.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.quiz_outlined, size: 64, color: darkGrey),
            const SizedBox(height: 16),
            Text(
              'No Questions available',
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
                    tooltip: 'Delete Questions by Year',
                    onPressed: _showDeleteYearDialog,
                  ),
                ),
                Expanded(
                  child: Text(
                    '${_filteredQuestions.length} ${_filteredQuestions.length == 1 ? 'Question' : 'Questions'}',
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

          // Filter Dropdown
          // if (_isFilterVisible)
          //   Padding(
          //     padding: const EdgeInsets.all(8),
          //     child: DropdownButtonFormField<YearOption>(
          //       value: _selectedYear,
          //       decoration: InputDecoration(
          //         labelText: 'Filter Year',
          //         labelStyle: TextStyle(color: darkGrey, fontSize: 15),
          //         contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          //         border: OutlineInputBorder(
          //           borderRadius: BorderRadius.circular(8),
          //           borderSide: BorderSide(color: darkGrey.withOpacity(0.2)),
          //         ),
          //         enabledBorder: OutlineInputBorder(
          //           borderRadius: BorderRadius.circular(8),
          //           borderSide: BorderSide(color: darkGrey.withOpacity(0.2)),
          //         ),
          //       ),
          //       items: _uniqueYears.map((yearOption) {
          //         return DropdownMenuItem<YearOption>(
          //           value: yearOption,
          //           child: Text(yearOption.toString(), style: TextStyle(fontSize: 15)),
          //         );
          //       }).toList(),
          //       onChanged: (YearOption? newValue) => _filterQuestions(newValue),
          //     ),
          //   ),

          // MCQs List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _filteredQuestions.length,
              itemBuilder: (context, index) {
                final question = _filteredQuestions[index];
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
                          question.question,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit, size: 25, color: customYellow),
                            onPressed: () => _editQuestion(question),
                          ),
                          IconButton(
                            icon: Icon(Icons.delete, size: 25, color: Colors.red),
                            onPressed: () => _deleteQuestion(question),
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
                _filterQuestions(newValue);
                Navigator.of(context).pop();
              },
            ),
          ),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }


}


import 'package:admin/services/delete_service.dart';
import 'package:admin/services/get_service.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../constants/colors.dart';
import '../../mcq_provider.dart';
import '../../models/question_model.dart';
import '../../models/year_options.dart';
import '../../providers/MCQProvider.dart';
import '../../providers/QuestionProvider.dart';
import '../edit_screens/editquestion_page.dart';


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
    Future.microtask(() {
      final provider = Provider.of<QuestionProvider>(context, listen: false);
      provider.loadQuestions(widget.selectedClass, widget.selectedSubject, widget.selectedChapter);
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


  void _showFilterDialog(BuildContext context, QuestionProvider provider) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Filter by Year'),
          content: DropdownButtonFormField<YearOption>(
            value: provider.selectedYear ?? provider.uniqueYears.first,
            decoration: InputDecoration(
              labelText: 'Select Year',
              border: OutlineInputBorder(),
            ),
            items: provider.uniqueYears.map((yearOption) {
              return DropdownMenuItem<YearOption>(
                value: yearOption,
                child: Text(yearOption.toString()),
              );
            }).toList(),
            onChanged: (YearOption? newValue) {
              provider.filterQuestions(newValue);
              context.pop();
            },
          ),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () => context.pop(),
            ),
          ],
        );
      },
    );
  }
  void _showDeleteYearDialog(BuildContext context, QuestionProvider provider) {
    showDialog(
      context: context,
      builder: (context) {
        YearOption? selectedYearToDelete = provider.uniqueYears.first;
        bool isDeleting = false;

        int calculateTotalQuestionsForYear(int? year) {
          return provider.questions.where((question) => question.year == year).length;
        }

        return StatefulBuilder(
          builder: (context, setState) {
            final totalQuestionsForYear = calculateTotalQuestionsForYear(selectedYearToDelete?.year);
            bool isAllSelected = selectedYearToDelete == null || selectedYearToDelete!.year == null;

            return AlertDialog(
              title: const Text('Delete MCQs by Year'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<YearOption>(
                    value: selectedYearToDelete,
                    decoration: InputDecoration(
                      labelText: 'Select Year',
                      labelStyle: const TextStyle(fontSize: 15, color: Colors.black54),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.black26),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.black26),
                      ),
                    ),
                    items: provider.uniqueYears.map((yearOption) {
                      return DropdownMenuItem<YearOption>(
                        value: yearOption,
                        child: Text(yearOption.toString(), style: const TextStyle(fontSize: 15)),
                      );
                    }).toList(),
                    onChanged: isDeleting
                        ? null
                        : (newValue) {
                      setState(() {
                        selectedYearToDelete = newValue!;
                      });
                    },
                  ),

                  const SizedBox(height: 12),

                  if (isDeleting) ...[
                    const SizedBox(height: 16),
                    const LinearProgressIndicator(),
                    const SizedBox(height: 8),
                    Text(
                      'Deleting Questions for year ${selectedYearToDelete?.year}...',
                      style: const TextStyle(fontSize: 14, color: Colors.black54),
                    ),
                  ],

                  const SizedBox(height: 8),
                  if (!isDeleting)
                    Text(
                      '$totalQuestionsForYear MCQs available for year ${selectedYearToDelete?.year ?? "All"}',
                      style: TextStyle(fontSize: 14, color: totalQuestionsForYear > 0 ? Colors.black87 : Colors.red),
                    ),
                ],
              ),
              actions: [
                TextButton(
                  child: const Text('Cancel'),
                  onPressed: isDeleting ? null : () => Navigator.pop(context),
                ),

                Opacity(
                  opacity: isAllSelected ? 0.5 : 1.0,
                  child: TextButton(
                    child: const Text('Delete', style: TextStyle(color: Colors.red)),
                    onPressed: (isDeleting || isAllSelected)
                        ? null
                        : () async {
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
                                onPressed: () => context.pop(false),
                              ),
                              TextButton(
                                child: const Text('Delete', style: TextStyle(color: Colors.red)),
                                onPressed: () => context.pop(true),
                              ),
                            ],
                          );
                        },
                      );

                      if (confirm) {
                        setState(() => isDeleting = true);

                        try {
                          await provider.deleteQuestionsByYear(
                            widget.selectedClass,
                            widget.selectedSubject,
                            widget.selectedChapter,
                            selectedYearToDelete!.year!,
                          );

                          if (context.mounted) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Deleted MCQs for year ${selectedYearToDelete!.year} successfully!',
                                ),
                              ),
                            );
                          }
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Failed to delete MCQs: $e'),
                            ),
                          );
                        }
                      }
                    },
                  ),
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
    return Consumer<QuestionProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          backgroundColor: customGrey,
          body: provider.isQuestionLoading
              ? const Center(child: CircularProgressIndicator())
              : provider.questions.isEmpty
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
                      icon: const Icon(Icons.filter_alt, color: Colors.blue),
                      tooltip: 'Filter by Year',
                      onPressed: () => _showFilterDialog(context, provider),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.delete_forever, color: Colors.red),
                        tooltip: 'Delete Questions by Year',
                        onPressed: () => _showDeleteYearDialog(context, provider),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        '${provider.questions.length} ${provider.questions.length == 1 ? 'Question' : 'Questions'}',
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
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: provider.questions.length,
                  itemBuilder: (context, index) {
                    final question = provider.questions[index];

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
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
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit, color: Colors.blue),
                                  onPressed: () {
                                    provider.selectQuestion(question);
                                    print("Editing Question with ID: ${question.id}");
                                    context.go('/edit_question/${widget.selectedClass}/${widget.selectedSubject}/${widget.selectedChapter}/${question.id}');
                                  },
                                ),
                                IconButton(
                                  icon: provider.isDeleting ? CircularProgressIndicator() : Icon(Icons.delete, color: Colors.red),
                                  onPressed: provider.isDeleting
                                      ? null
                                      : () {
                                    _showDeleteDialog(context, provider, question);
                                  },
                                ),
                              ],
                            ),
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
      },
    );
  }

  void _showDeleteDialog(BuildContext context, QuestionProvider provider, Question question) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Question'),
          content: Text('Are you sure you want to delete this Question?'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                context.pop();
              },
            ),
            TextButton(
              child: Text('Delete'),
              onPressed: () async {
                context.pop();
                await provider.deleteQuestion(widget.selectedClass, widget.selectedSubject, widget.selectedChapter, question.id);
              },
            ),
          ],
        );
      },
    );
  }



}



import 'package:admin/services/delete_service.dart';
import 'package:admin/services/get_service.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../constants/colors.dart';
import '../../../mcq_provider.dart';
import '../../../models/mcq_model.dart';
import '../../../models/year_options.dart';
import '../../../providers/MCQProvider.dart';
import '../../edit_screens/etea_edit/etea_edit_chapterwise.dart';



class ViewEteaMCQsPage extends StatefulWidget {
  final String selectedSubject;
  final String selectedChapter;

  const ViewEteaMCQsPage({
    Key? key,
    required this.selectedSubject,
    required this.selectedChapter,
  }) : super(key: key);

  @override
  _ViewEteaMCQsPageState createState() => _ViewEteaMCQsPageState();
}

class _ViewEteaMCQsPageState extends State<ViewEteaMCQsPage> {



  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final provider = Provider.of<MCQProvider>(context, listen: false);
      provider.loadEteaMCQs( widget.selectedSubject, widget.selectedChapter);
    });
  }




  void _showFilterDialog(BuildContext context, MCQProvider provider) {
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
              provider.filterMCQs(newValue);
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
  void _showDeleteYearDialog(BuildContext context, MCQProvider provider) {
    showDialog(
      context: context,
      builder: (context) {
        YearOption? selectedYearToDelete = provider.uniqueYears.first;
        bool isDeleting = false;

        int calculateTotalMcqsForYear(int? year) {
          return provider.mcqs.where((mcq) => mcq.year == year).length;
        }

        return StatefulBuilder(
          builder: (context, setState) {
            final totalMcqsForYear = calculateTotalMcqsForYear(selectedYearToDelete?.year);
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
                      'Deleting MCQs for year ${selectedYearToDelete?.year}...',
                      style: const TextStyle(fontSize: 14, color: Colors.black54),
                    ),
                  ],

                  const SizedBox(height: 8),
                  if (!isDeleting)
                    Text(
                      '$totalMcqsForYear MCQs available for year ${selectedYearToDelete?.year ?? "All"}',
                      style: TextStyle(fontSize: 14, color: totalMcqsForYear > 0 ? Colors.black87 : Colors.red),
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
                          await provider.deleteEteaMCQsByYear(
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

  void _showDeleteDialog(BuildContext context, MCQProvider provider, MCQ mcq) {
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
                context.pop();
              },
            ),
            TextButton(
              child: Text('Delete'),
              onPressed: () async {
                context.pop();
                await provider.deleteEteaMCQ(widget.selectedSubject, widget.selectedChapter, mcq.id);
              },
            ),
          ],
        );
      },
    );
  }



  @override
  Widget build(BuildContext context) {
    return Consumer<MCQProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          backgroundColor: Colors.grey[100],

          body: provider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : provider.mcqs.isEmpty
              ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.quiz_outlined, size: 80, color: Colors.grey[600]),
                const SizedBox(height: 16),
                Text(
                  'No MCQs available',
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          )
              : Column(
            children: [
              // Top Action Bar
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
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
                        tooltip: 'Delete MCQs by Year',
                        onPressed: () => _showDeleteYearDialog(context, provider),
                      ),
                    ),
                    const Spacer(),


                    Text(
                      '${provider.mcqs.length} ${provider.mcqs.length == 1 ? 'MCQ' : 'MCQs'}',
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),


              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: provider.mcqs.length,
                  itemBuilder: (context, index) {
                    final mcq = provider.mcqs[index];

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
                          // Question Text
                          Padding(
                            padding: const EdgeInsets.all(10),
                            child: Text(
                              mcq.question,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                          ),

                          // Options List
                          Padding(
                            padding: const EdgeInsets.all(5),
                            child: Column(
                              children: mcq.options.asMap().entries.map((entry) {
                                final optionIndex = entry.key;
                                final optionText = entry.value;
                                final isCorrect = optionIndex == mcq.correctOption;
                                final optionLabel = String.fromCharCode(65 + optionIndex);

                                return Container(
                                  margin: const EdgeInsets.only(bottom: 6),
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: isCorrect
                                        ? customYellow.withOpacity(0.8)
                                        : Colors.grey.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(8),
                                    border: isCorrect
                                        ? Border.all(color: Colors.yellow.shade700)
                                        : Border.all(color: Colors.transparent),
                                  ),
                                  child: Row(
                                    children: [
                                      Text(
                                        '$optionLabel. $optionText',
                                        style: const TextStyle(fontSize: 15),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                          ),

                          // Action Buttons
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit, color: Colors.blue),
                                  onPressed: () {
                                    provider.selectMCQ(mcq);
                                    print("Editing MCQ with ID: ${mcq.id}");
                                    context.go('/edit_eteamcq/${widget.selectedSubject}/${widget.selectedChapter}/${mcq.id}');
                                  },
                                ),
                                IconButton(
                                  icon: provider.isDeleting ? CircularProgressIndicator() : Icon(Icons.delete, color: Colors.red),
                                  onPressed: provider.isDeleting
                                      ? null
                                      : () {
                                    _showDeleteDialog(context, provider, mcq);
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


}

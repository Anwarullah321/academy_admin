import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import '../../models/mcq_model.dart';


class HalfBookDetailedResultsPage extends StatelessWidget {
  final List<MCQ> mcqs;
  final Map<int, int> selectedAnswers;
  final int correctAnswers;
  final int totalQuestions;
  final VoidCallback onSave;
  final int levelsToPopAfterSave;

  HalfBookDetailedResultsPage({
    required this.mcqs,
    required this.selectedAnswers,
    required this.correctAnswers,
    required this.totalQuestions,
    required this.onSave,
    this.levelsToPopAfterSave =0,

  });



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Test Report'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            for (int i = 0; i < levelsToPopAfterSave; i++) {
              Navigator.pop(context);
            }
          },
        ),
        elevation: 0,
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 5),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(40),
                  bottomRight: Radius.circular(40),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [

                  CircularPercentIndicator(
                    radius: 45.0,
                    lineWidth: 7.0,
                    animation: true,
                    percent: correctAnswers / totalQuestions,
                    center: Text(
                      "${(correctAnswers / totalQuestions * 100).toStringAsFixed(1)}%",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0, color: Colors.white),
                    ),
                    circularStrokeCap: CircularStrokeCap.round,
                    progressColor: Colors.white,
                    backgroundColor: Colors.white.withOpacity(0.3),
                  ),
                  Text(
                    "$correctAnswers out of $totalQuestions correct",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0, color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: EdgeInsets.all(10),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                    (context, index) {
                  MCQ mcq = mcqs[index];
                  int? selectedAnswer = selectedAnswers[index];
                  bool isAnswered = selectedAnswer != null;
                  bool isCorrect = isAnswered && selectedAnswer == mcq.correctOption;

                  return Card(
                    elevation: 3,
                    margin: EdgeInsets.only(bottom: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                      side: BorderSide(
                        color: isAnswered
                            ? (isCorrect ? Colors.green : Colors.red)
                            : Colors.grey,
                        width: 3,
                      ),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'MCQ ${index + 1}',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            mcq.question,
                            style: TextStyle(fontSize: 16),
                          ),
                          SizedBox(height: 16),
                          if (isAnswered)
                            _buildAnswerTile(
                              'Your answer:',
                              mcq.options[selectedAnswer],
                              isCorrect ? Icons.check_circle : Icons.cancel,
                              isCorrect ? Colors.green : Colors.red,
                            ),
                          if (isAnswered && !isCorrect)
                            _buildAnswerTile(
                              'Correct answer:',
                              mcq.options[mcq.correctOption],
                              Icons.check_circle,
                              Colors.green,
                            ),
                          if (!isAnswered)
                            Text(
                              'Not answered',
                              style: TextStyle(
                                color: Colors.grey,
                                fontStyle: FontStyle.italic,
                                fontSize: 16,
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
                childCount: mcqs.length,
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          onSave();


          for (int i = 1; i < levelsToPopAfterSave; i++) {
            Navigator.pop(context);
          }

        },
        icon: Icon(Icons.save),
        label: Text('Save Result'),
      ),
    );
  }

  Widget _buildAnswerTile(String label, String answer, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Icon(icon, color: color),
          SizedBox(width: 8),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: TextStyle(fontSize: 16, color: Colors.black),
                children: [
                  TextSpan(text: '$label ', style: TextStyle(fontWeight: FontWeight.bold)),
                  TextSpan(text: answer),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
import 'package:academyapp/etea/etealocal/history/SingleTestDetailPage.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';


class EteaLocalTestHistoryPage extends StatefulWidget {

  final String selectedSubject;
  final String selectedChapter;

  EteaLocalTestHistoryPage({
    required this.selectedSubject,
    required this.selectedChapter


  });


  @override
  State<EteaLocalTestHistoryPage> createState() => _EteaLocalTestHistoryPageState();
}

class _EteaLocalTestHistoryPageState extends State<EteaLocalTestHistoryPage> {
  Key _futureBuilderKey = UniqueKey();

  Future<List<Map<String, dynamic>>> _getTestHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final key = '_Etealocalobjective_${widget.selectedSubject}_${widget.selectedChapter}';
    final results = prefs.getStringList(key) ?? [];

    if (results.isEmpty) {
      print('No history found for key: $key');
      return [];
    }

    List<Map<String, dynamic>> sortedHistory = results.map((result) {
      final decodedResult = json.decode(result);
      print('Decoded result ID: ${decodedResult['id']}');
      return {
        'id': decodedResult['id'] ?? 'Unknown ID',
        'taskName': decodedResult['taskName'] ?? 'Unknown Task',
        'date': decodedResult['date'] ?? 'Unknown Date',
        'score': decodedResult['score'] ?? 0,
        'totalQuestions': decodedResult['totalQuestions'] ?? 0,
        'summary': decodedResult['summary'] ?? [],
      };
    }).toList();

    sortedHistory.sort((a, b) =>
        DateTime.parse(b['date']).compareTo(DateTime.parse(a['date'])));

    return sortedHistory;
  }

  void _showDetails(BuildContext context, Map<String, dynamic> item) {
    print('Showing details for item: $item');
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SingleEteaTestDetailPage(testData: item),
      ),
    );
  }


  Future<void> _clearHistory(BuildContext context) async {
    final shouldClear = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Clear History'),
          content: Text('Are you sure you want to clear all history?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false), // Don't clear
              child: Text('No'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true), // Clear
              child: Text('Yes'),
            ),
          ],
        );
      },
    );

    if (shouldClear != true) {
      // If user presses 'No' or dismisses the dialog
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final key = '_Etealocalobjective_${widget.selectedSubject}_${widget.selectedChapter}';
    await prefs.remove(key);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('History cleared successfully')),
    );
    setState(() {
      _futureBuilderKey = UniqueKey();
    });
  }




  Future<void> _deleteItem(BuildContext context, String itemId) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Delete'),
          content: Text('Are you sure you want to delete this item?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false), // Don't delete
              child: Text('No'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true), // Delete
              child: Text('Yes'),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true) {
      // If user presses 'No' or dismisses the dialog
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final key = '_Etealocalobjective_${widget.selectedSubject}_${widget.selectedChapter}';
    final results = prefs.getStringList(key) ?? [];

    final index = results.indexWhere((result) {
      final decodedResult = json.decode(result);
      return decodedResult['id'] == itemId;
    });

    if (index != -1) {
      results.removeAt(index);
      await prefs.setStringList(key, results);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Item deleted successfully')),
      );
      setState(() {
        _futureBuilderKey = UniqueKey();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Item not found')),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Test History'),
        actions: [
          FutureBuilder<List<Map<String, dynamic>>>(
            future: _getTestHistory(),
            builder: (context, snapshot) {
              if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                return IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () => _clearHistory(context),
                );
              } else {
                return SizedBox.shrink(); // This will hide the icon
              }
            },
          ),
        ],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        key: _futureBuilderKey,
        future: _getTestHistory(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error loading history'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No history found'));
          } else {
            final history = snapshot.data!;
            return ListView.builder(
              itemCount: history.length,
              itemBuilder: (context, index) {
                final item = history[index];
                return Dismissible(
                  key: Key(item['id'].toString()),
                  direction: DismissDirection.endToStart,
                  onDismissed: (direction) {
                    _deleteItem(context, item['id']);
                  },
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: EdgeInsets.only(right: 16.0),
                    color: Colors.red,
                    child: Icon(Icons.delete, color: Colors.white),
                  ),
                  child: Card(
                    elevation: 3,
                    margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                      side: BorderSide(
                        color: item['score'] == item['totalQuestions'] ? Colors.green : Colors.red,
                        width: 3,
                      ),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                _showDetails(context, item);
                              },
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item['taskName'],
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context).primaryColor,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'Date: ${item['date']}',
                                    style: TextStyle(fontSize: 16, color: Colors.grey),
                                  ),
                                  SizedBox(height: 16),
                                  Text(
                                    'Score: ${item['score']} / ${item['totalQuestions']}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: item['score'] == item['totalQuestions'] ? Colors.green : Colors.red,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(width: 16),
                          GestureDetector(
                            onTap: () {
                              _deleteItem(context, item['id']);
                            },
                            child: Icon(Icons.delete, color: Colors.red),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
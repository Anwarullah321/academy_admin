
class MCQ {
  final String id;
  final String question;
  final List<String> options;
  final int correctOption;
  final int year;
  MCQ({required this.id, required this.question, required this.options, required this.correctOption, required this.year});

  factory MCQ.fromMap(Map<String, dynamic> data) {
    try {
      return MCQ(
        id: data['id'] ?? '',
        question: data['question'] ?? '',
        options: List<String>.from(data['options'].cast<String>()),
        correctOption: data['correctOption']?.toInt() ?? '',
        year: data['year']?.toInt() ?? -1, // Handle potential null values
      );
    } catch (e) {
      print("Error converting MCQ from map: $e");
      rethrow; // Rethrow the exception if conversion fails
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'question': question,
      'options': options,
      'correctOption': correctOption,
      'year': year
    };
  }



}

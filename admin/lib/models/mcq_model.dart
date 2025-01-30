class MCQ {
  final String id;
  final String question;
  final List<String> options;
  final int correctOption;
  final int year;

  MCQ({
    required this.id,
    required this.question,
    required this.options,
    required this.correctOption,
    required this.year,
  });

  factory MCQ.fromMap(Map<String, dynamic> data) {
    try {
      return MCQ(
        id: data['id'] ?? '',
        question: data['question'] ?? '',
        options: data['options'] != null
            ? List<String>.from(data['options'])
            : [],
        correctOption: data['correctOption']?.toInt() ?? -1,
        year: data['year']?.toInt() ?? -1,
      );
    } catch (e) {
      print("Error converting MCQ from map: $e");
      rethrow;
    }
  }



  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'question': question,
      'options': options,
      'correctOption': correctOption,
      'year': year,
    };
  }
}

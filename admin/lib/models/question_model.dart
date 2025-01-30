class Question {
  final String id;
  final String question;
  final int year;

  Question({required this.id, required this.question,required this.year});

  factory Question.fromMap(Map<String, dynamic> data) {
    return Question(
        id: data['id'] ?? '',
        question: data['question'] ?? '',
      year: data['year'] ?.toInt() ?? -1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'question': question,
      'year': year
    };
  }
}

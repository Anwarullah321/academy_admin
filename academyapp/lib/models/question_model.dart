class Question {
  final String id;
  final String question;
  final String answer;

  Question({
    required this.id,
    required this.question,
    required this.answer,
  });



  // Factory constructor to create a Question from a Firestore document map
  factory Question.fromMap(Map<String, dynamic> data) {
    return Question(
      id: data['id'] ?? '',
      question: data['question'] ?? '',
      answer: data['answer'] ?? '',
    );
  }
  // Method to convert a Question object to a map for storing in Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'question': question,
      'answer': answer,
    };
  }
}

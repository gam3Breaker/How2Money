class GameWord {
  final String word;
  final String category;
  final String? hint;

  GameWord({
    required this.word,
    required this.category,
    this.hint,
  });
}

class GameRound {
  final String id;
  final GameWord word;
  final int timeLimit;
  bool wasGuessed;
  bool wasSkipped;

  GameRound({
    required this.id,
    required this.word,
    this.timeLimit = 30,
    this.wasGuessed = false,
    this.wasSkipped = false,
  });
}

class GameSession {
  final String id;
  final DateTime startTime;
  DateTime? endTime;
  final List<GameRound> rounds;
  int score;
  final List<String> completedTopics;

  GameSession({
    required this.id,
    required this.startTime,
    this.endTime,
    required this.rounds,
    this.score = 0,
    this.completedTopics = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'rounds': rounds.map((r) => {
            'id': r.id,
            'word': r.word.word,
            'category': r.word.category,
            'wasGuessed': r.wasGuessed,
            'wasSkipped': r.wasSkipped,
          }).toList(),
      'score': score,
      'completedTopics': completedTopics,
    };
  }

  factory GameSession.fromJson(Map<String, dynamic> json) {
    return GameSession(
      id: json['id'] ?? '',
      startTime: DateTime.parse(json['startTime']),
      endTime: json['endTime'] != null ? DateTime.parse(json['endTime']) : null,
      rounds: (json['rounds'] as List?)
              ?.map((r) => GameRound(
                    id: r['id'] ?? '',
                    word: GameWord(
                      word: r['word'] ?? '',
                      category: r['category'] ?? '',
                    ),
                    wasGuessed: r['wasGuessed'] ?? false,
                    wasSkipped: r['wasSkipped'] ?? false,
                  ))
              .toList() ??
          [],
      score: json['score'] ?? 0,
      completedTopics: List<String>.from(json['completedTopics'] ?? []),
    );
  }
}

class PersonalGameQuestion {
  final String id;
  final String question;
  final List<String> options;
  final int correctIndex;
  final String category;
  final String? explanation;

  PersonalGameQuestion({
    required this.id,
    required this.question,
    required this.options,
    required this.correctIndex,
    required this.category,
    this.explanation,
  });
}

class PersonalGame {
  final String id;
  final DateTime createdAt;
  final List<PersonalGameQuestion> questions;
  final Map<String, double> categorizedSpending;
  final int score;

  PersonalGame({
    required this.id,
    required this.createdAt,
    required this.questions,
    required this.categorizedSpending,
    this.score = 0,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'createdAt': createdAt.toIso8601String(),
      'questions': questions.map((q) => {
            'id': q.id,
            'question': q.question,
            'options': q.options,
            'correctIndex': q.correctIndex,
            'category': q.category,
            'explanation': q.explanation,
          }).toList(),
      'categorizedSpending': categorizedSpending,
      'score': score,
    };
  }

  factory PersonalGame.fromJson(Map<String, dynamic> json) {
    return PersonalGame(
      id: json['id'] ?? '',
      createdAt: DateTime.parse(json['createdAt']),
      questions: (json['questions'] as List?)
              ?.map((q) => PersonalGameQuestion(
                    id: q['id'] ?? '',
                    question: q['question'] ?? '',
                    options: List<String>.from(q['options'] ?? []),
                    correctIndex: q['correctIndex'] ?? 0,
                    category: q['category'] ?? '',
                    explanation: q['explanation'],
                  ))
              .toList() ??
          [],
      categorizedSpending:
          Map<String, double>.from(json['categorizedSpending'] ?? {}),
      score: json['score'] ?? 0,
    );
  }
}

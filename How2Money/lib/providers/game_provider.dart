import 'package:flutter/foundation.dart';
import '../models/game.dart';
import '../services/local_storage_service.dart';
import '../services/mock_ai_service.dart';
import 'package:uuid/uuid.dart';
import 'dart:math';

class GameProvider with ChangeNotifier {
  final LocalStorageService _storage = LocalStorageService();
  final MockAIService _aiService = MockAIService();
  final Uuid _uuid = const Uuid();
  final Random _random = Random();

  GameSession? _currentSession;
  GameRound? _currentRound;
  int _currentRoundIndex = 0;
  List<String> _feedback = [];

  // Game words pool
  final List<GameWord> _allWords = [
    GameWord(word: 'Credit Score', category: 'Credit', hint: 'Your financial reputation'),
    GameWord(word: 'Budget', category: 'Budgeting', hint: 'A spending plan'),
    GameWord(word: 'Interest', category: 'Credit', hint: 'The cost of borrowing'),
    GameWord(word: 'Loan', category: 'Credit', hint: 'Borrowed money'),
    GameWord(word: 'Savings Goal', category: 'Saving', hint: 'What you want to save for'),
    GameWord(word: 'Emergency Fund', category: 'Saving', hint: 'Money for unexpected expenses'),
    GameWord(word: 'Debt', category: 'Debt', hint: 'Money you owe'),
    GameWord(word: 'Income', category: 'Budgeting', hint: 'Money you earn'),
    GameWord(word: 'Expense', category: 'Budgeting', hint: 'Money you spend'),
    GameWord(word: 'Investment', category: 'Saving', hint: 'Putting money to work'),
    GameWord(word: 'Compound Interest', category: 'Credit', hint: 'Interest on interest'),
    GameWord(word: 'Credit Card', category: 'Credit', hint: 'Plastic money'),
    GameWord(word: 'Overdraft', category: 'Debt', hint: 'Spending more than you have'),
    GameWord(word: 'Fixed Expense', category: 'Budgeting', hint: 'Regular bills'),
    GameWord(word: 'Variable Expense', category: 'Budgeting', hint: 'Changing costs'),
  ];

  GameSession? get currentSession => _currentSession;
  GameRound? get currentRound => _currentRound;
  int get currentRoundIndex => _currentRoundIndex;
  List<String> get feedback => _feedback;

  Future<void> startNewGame({required List<String> completedTopics}) async {
    _currentSession = GameSession(
      id: _uuid.v4(),
      startTime: DateTime.now(),
      rounds: [],
      completedTopics: completedTopics,
    );

    _currentRoundIndex = 0;
    _feedback = [];

    // Generate 5 rounds
    final words = _selectWords(5, completedTopics);
    for (var word in words) {
      _currentSession!.rounds.add(GameRound(
        id: _uuid.v4(),
        word: word,
        timeLimit: 30,
      ));
    }

    _loadNextRound();
    notifyListeners();
  }

  List<GameWord> _selectWords(int count, List<String> completedTopics) {
    // Bias towards topics that haven't been completed
    final completedCategories = completedTopics.map((t) => t.toLowerCase()).toSet();
    final incompleteWords = _allWords
        .where((w) => !completedCategories.contains(w.category.toLowerCase()))
        .toList();
    final completedWords = _allWords
        .where((w) => completedCategories.contains(w.category.toLowerCase()))
        .toList();

    final List<GameWord> selected = [];

    // 70% incomplete topics, 30% completed
    final incompleteCount = (count * 0.7).ceil();
    final completedCount = count - incompleteCount;

    if (incompleteWords.isNotEmpty) {
      selected.addAll(
        List.generate(
          incompleteCount > incompleteWords.length ? incompleteWords.length : incompleteCount,
          (_) => incompleteWords[_random.nextInt(incompleteWords.length)],
        ),
      );
    }

    if (completedWords.isNotEmpty && selected.length < count) {
      selected.addAll(
        List.generate(
          completedCount > completedWords.length ? completedWords.length : completedCount,
          (_) => completedWords[_random.nextInt(completedWords.length)],
        ),
      );
    }

    // Fill remaining with random words
    while (selected.length < count) {
      selected.add(_allWords[_random.nextInt(_allWords.length)]);
    }

    return selected.take(count).toList();
  }

  void _loadNextRound() {
    if (_currentSession != null &&
        _currentRoundIndex < _currentSession!.rounds.length) {
      _currentRound = _currentSession!.rounds[_currentRoundIndex];
    } else {
      _currentRound = null;
    }
  }

  void markRoundGuessed() {
    if (_currentRound != null) {
      _currentRound!.wasGuessed = true;
      _currentRound!.wasSkipped = false;
    }
    _nextRound();
  }

  void markRoundSkipped() {
    if (_currentRound != null) {
      _currentRound!.wasSkipped = true;
      _currentRound!.wasGuessed = false;
    }
    _nextRound();
  }

  void _nextRound() {
    _currentRoundIndex++;
    if (_currentRoundIndex < _currentSession!.rounds.length) {
      _loadNextRound();
    } else {
      _endGame();
    }
    notifyListeners();
  }

  Future<void> _endGame() async {
    if (_currentSession == null) return;

    _currentSession!.endTime = DateTime.now();
    _currentRound = null;

    // Calculate score
    final guessedCount = _currentSession!.rounds.where((r) => r.wasGuessed).length;
    _currentSession!.score = guessedCount;

    // Get AI feedback
    _feedback = await _aiService.getGameFeedback(
      session: _currentSession!,
      completedTopics: _currentSession!.completedTopics,
    );

    // Save session
    await _storage.saveGameSession(_currentSession!);

    notifyListeners();
  }

  bool get isGameActive => _currentRound != null;
  bool get isGameComplete => _currentSession != null && _currentRound == null;
}



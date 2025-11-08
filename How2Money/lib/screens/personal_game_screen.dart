import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/mock_ai_service.dart';
import '../services/local_storage_service.dart';
import '../models/game.dart';
import '../theme/app_theme.dart';
import 'package:uuid/uuid.dart';

class PersonalGameScreen extends StatefulWidget {
  const PersonalGameScreen({super.key});

  @override
  State<PersonalGameScreen> createState() => _PersonalGameScreenState();
}

class _PersonalGameScreenState extends State<PersonalGameScreen> {
  final LocalStorageService _storage = LocalStorageService();
  PersonalGame? _currentGame;
  int _currentQuestionIndex = 0;
  int? _selectedAnswer;
  int _score = 0;
  bool _gameComplete = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Personal Game'),
      ),
      body: _currentGame == null
          ? _buildUploadScreen()
          : _gameComplete
              ? _buildResultsScreen()
              : _buildGameScreen(),
    );
  }

  Widget _buildUploadScreen() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.upload_file,
              size: 80,
              color: AppTheme.primaryTeal,
            ),
            const SizedBox(height: 24),
            const Text(
              'Upload Bank Statement',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            const Text(
              'Upload your monthly bank statement to generate a personalized financial game based on your spending.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: _uploadMockStatement,
              icon: const Icon(Icons.cloud_upload),
              label: const Text('Upload Statement (Mock)'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
              ),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: _pasteStatement,
              icon: const Icon(Icons.paste),
              label: const Text('Paste Statement (Mock)'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
              ),
            ),
            const SizedBox(height: 32),
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Note:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'This is a mock upload. In production, this would:',
                      style: TextStyle(fontSize: 12),
                    ),
                    Text(
                      '1. Upload statement to POST /api/upload_statement',
                      style: TextStyle(fontSize: 12),
                    ),
                    Text(
                      '2. Process transactions and categorize spending',
                      style: TextStyle(fontSize: 12),
                    ),
                    Text(
                      '3. Generate personalized questions',
                      style: TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _uploadMockStatement() async {
    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    // Mock statement data
    final categorizedSpending = {
      'Food': 1200.0,
      'Transport': 800.0,
      'Data': 300.0,
      'Entertainment': 500.0,
    };

    // Generate personal game
    final game = await MockAIService.generatePersonalGame(
      categorizedSpending: categorizedSpending,
    );

    // Save game
    await _storage.savePersonalGame(game);

    if (!mounted) return;
    Navigator.pop(context); // Close loading dialog

    setState(() {
      _currentGame = game;
      _currentQuestionIndex = 0;
      _score = 0;
      _gameComplete = false;
    });
  }

  Future<void> _pasteStatement() async {
    // Same as upload for mock
    await _uploadMockStatement();
  }

  Widget _buildGameScreen() {
    if (_currentGame == null) return const SizedBox();

    final question = _currentGame!.questions[_currentQuestionIndex];

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Progress indicator
          LinearProgressIndicator(
            value: (_currentQuestionIndex + 1) / _currentGame!.questions.length,
            backgroundColor: AppTheme.backgroundLight,
            valueColor: const AlwaysStoppedAnimation<Color>(
              AppTheme.primaryTeal,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Question ${_currentQuestionIndex + 1}/${_currentGame!.questions.length}',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),

          // Question card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    question.question,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Category: ${question.category}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Options
          ...question.options.asMap().entries.map((entry) {
            final index = entry.key;
            final option = entry.value;
            final isSelected = _selectedAnswer == index;

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Card(
                color: isSelected ? AppTheme.primaryTeal.withOpacity(0.1) : null,
                child: ListTile(
                  title: Text(option),
                  leading: Radio<int>(
                    value: index,
                    groupValue: _selectedAnswer,
                    onChanged: (value) {
                      setState(() {
                        _selectedAnswer = value;
                      });
                    },
                  ),
                  onTap: () {
                    setState(() {
                      _selectedAnswer = index;
                    });
                  },
                ),
              ),
            );
          }),

          const Spacer(),

          // Submit button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _selectedAnswer == null
                  ? null
                  : () {
                      _submitAnswer();
                    },
              child: const Text('Submit Answer'),
            ),
          ),
        ],
      ),
    );
  }

  void _submitAnswer() {
    if (_selectedAnswer == null || _currentGame == null) return;

    final question = _currentGame!.questions[_currentQuestionIndex];
    final isCorrect = _selectedAnswer == question.correctIndex;

    if (isCorrect) {
      setState(() {
        _score++;
      });
    }

    // Show feedback
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isCorrect ? 'Correct!' : 'Incorrect'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (question.explanation != null)
              Text(question.explanation!),
            const SizedBox(height: 16),
            Text(
              isCorrect
                  ? 'Great job! You\'re learning about ${question.category}.'
                  : 'The correct answer was: ${question.options[question.correctIndex]}',
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _nextQuestion();
            },
            child: const Text('Next'),
          ),
        ],
      ),
    );
  }

  void _nextQuestion() {
    if (_currentGame == null) return;

    setState(() {
      _currentQuestionIndex++;
      _selectedAnswer = null;

      if (_currentQuestionIndex >= _currentGame!.questions.length) {
        _gameComplete = true;
        // Update game score
        _currentGame = PersonalGame(
          id: _currentGame!.id,
          createdAt: _currentGame!.createdAt,
          questions: _currentGame!.questions,
          categorizedSpending: _currentGame!.categorizedSpending,
          score: _score,
        );
        _storage.savePersonalGame(_currentGame!);
      }
    });
  }

  Widget _buildResultsScreen() {
    if (_currentGame == null) return const SizedBox();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const Icon(
            Icons.celebration,
            size: 80,
            color: AppTheme.accentGold,
          ),
          const SizedBox(height: 24),
          const Text(
            'Game Complete!',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const Text(
                    'Your Score',
                    style: TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$_score/${_currentGame!.questions.length}',
                    style: const TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryTeal,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Spending breakdown
          const Text(
            'Your Spending Breakdown',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ..._currentGame!.categorizedSpending.entries.map((entry) {
            return Card(
              child: ListTile(
                title: Text(entry.key),
                trailing: Text(
                  'R${entry.value.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            );
          }),

          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _currentGame = null;
                _currentQuestionIndex = 0;
                _score = 0;
                _gameComplete = false;
              });
            },
            child: const Text('Play Again'),
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Back to Profile'),
          ),
        ],
      ),
    );
  }
}



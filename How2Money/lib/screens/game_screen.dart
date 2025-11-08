import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../providers/game_provider.dart';
import '../providers/learn_provider.dart';
import '../theme/app_theme.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  Timer? _timer;
  int _remainingSeconds = 30;

  @override
  void initState() {
    super.initState();
    _startGame();
  }

  void _startGame() {
    final gameProvider = Provider.of<GameProvider>(context, listen: false);
    final learnProvider = Provider.of<LearnProvider>(context, listen: false);

    if (!gameProvider.isGameActive) {
      final completedTopics = learnProvider.getCompletedTopics();
      gameProvider.startNewGame(completedTopics: completedTopics);
    }

    _startTimer();
  }

  void _startTimer() {
    _remainingSeconds = 30;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() {
          _remainingSeconds--;
        });
      } else {
        timer.cancel();
        _onTimeUp();
      }
    });
  }

  void _onTimeUp() {
    final gameProvider = Provider.of<GameProvider>(context, listen: false);
    gameProvider.markRoundSkipped();
    if (gameProvider.isGameActive) {
      _startTimer();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PlayWise - Charades'),
      ),
      body: Consumer<GameProvider>(
        builder: (context, gameProvider, _) {
          if (!gameProvider.isGameActive && gameProvider.isGameComplete) {
            return _buildGameComplete(gameProvider);
          }

          if (!gameProvider.isGameActive) {
            return _buildStartScreen();
          }

          return _buildGamePlay(gameProvider);
        },
      ),
    );
  }

  Widget _buildStartScreen() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.games,
              size: 80,
              color: AppTheme.primaryTeal,
            ),
            const SizedBox(height: 24),
            const Text(
              'PlayWise Charades',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Describe financial terms to your teammates without using the word itself!',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _startGame,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 48,
                  vertical: 16,
                ),
              ),
              child: const Text('Start Game'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGamePlay(GameProvider gameProvider) {
    final round = gameProvider.currentRound;
    if (round == null) return const SizedBox();

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Timer and round info
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      const Text('Round'),
                      Text(
                        '${gameProvider.currentRoundIndex + 1}/${gameProvider.currentSession!.rounds.length}',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      const Text('Time'),
                      Text(
                        '$_remainingSeconds',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: _remainingSeconds < 10
                              ? AppTheme.error
                              : AppTheme.primaryTeal,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),

          // Word card
          Expanded(
            child: Center(
              child: Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(48),
                  decoration: BoxDecoration(
                    gradient: AppTheme.cardGradient,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        round.word.word,
                        style: const TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        round.word.category,
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    _timer?.cancel();
                    gameProvider.markRoundSkipped();
                    if (gameProvider.isGameActive) {
                      _startTimer();
                    }
                  },
                  icon: const Icon(Icons.skip_next),
                  label: const Text('Skip'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    _timer?.cancel();
                    gameProvider.markRoundGuessed();
                    if (gameProvider.isGameActive) {
                      _startTimer();
                    }
                  },
                  icon: const Icon(Icons.check),
                  label: const Text('Got it!'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGameComplete(GameProvider gameProvider) {
    final session = gameProvider.currentSession;
    if (session == null) return const SizedBox();

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
                    '${session.score}/${session.rounds.length}',
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

          // AI Feedback
          if (gameProvider.feedback.isNotEmpty) ...[
            const Text(
              'Feedback from KasiCash',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...gameProvider.feedback.map((feedback) => Card(
                  child: ListTile(
                    leading: const Icon(
                      Icons.psychology,
                      color: AppTheme.primaryTeal,
                    ),
                    title: Text(feedback),
                  ),
                )),
          ],

          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _startGame();
              });
            },
            child: const Text('Play Again'),
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Back to Home'),
          ),
        ],
      ),
    );
  }
}



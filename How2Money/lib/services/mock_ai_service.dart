import '../models/chat_message.dart';
import '../models/learn_slide.dart';
import '../models/game.dart';
import 'dart:math';

/// Mock AI Service - returns canned responses for demo purposes
/// TODO: Replace with real API calls to POST /api/ai endpoint
class MockAIService {
  static final Random _random = Random();

  // Demo conversation responses (will be localized to South African youth slang)
  static final List<String> _demoResponses = [
    "Yo! Budgeting is all about tracking your spending. Start by writing down everything you buy for a week - you'll be shocked where your money goes!",
    "Saving tip: Set aside 10% of whatever you earn, even if it's just R50. Small amounts add up over time!",
    "Credit score? It's like your money report card. Pay bills on time, don't max out cards, and you'll build a solid score.",
    "Debt can feel overwhelming, but making a plan helps. List all your debts, pay minimums, and throw extra cash at the smallest one first.",
    "Want to save for something big? Break it down into weekly savings goals. If you want R1000 in 10 weeks, save R100 each week!",
    "Emergency fund is your safety net. Aim for 3-6 months of expenses. Start small - even R500 can help in a pinch.",
  ];

  /// Get AI response to user message
  /// TODO: Replace with POST /api/ai call
  static Future<String> getResponse(String userMessage, {String? userId}) async {
    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 800));

    // Simple keyword matching for demo
    final message = userMessage.toLowerCase();

    if (message.contains('budget') || message.contains('spending')) {
      return _demoResponses[0];
    } else if (message.contains('save') || message.contains('saving')) {
      return _demoResponses[1];
    } else if (message.contains('credit') || message.contains('score')) {
      return _demoResponses[2];
    } else if (message.contains('debt') || message.contains('owe')) {
      return _demoResponses[3];
    } else if (message.contains('goal') || message.contains('target')) {
      return _demoResponses[4];
    } else if (message.contains('emergency') || message.contains('fund')) {
      return _demoResponses[5];
    }

    // Default response
    return _demoResponses[_random.nextInt(_demoResponses.length)];
  }

  /// Get personalized greeting
  static String getGreeting(String userName) {
    // TODO: Localize to South African youth slang
    return "Hey $userName! Ready to level up your money?";
  }

  /// Get AI recommendation for next learn slide
  /// TODO: Replace with POST /api/ai/recommend endpoint
  static Future<LearnSlide?> recommendNextSlide({
    required List<LearnSlide> allSlides,
    required List<String> completedSlideIds,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));

    // Find first incomplete slide
    final incompleteSlides = allSlides
        .where((slide) => !completedSlideIds.contains(slide.id))
        .toList();

    if (incompleteSlides.isEmpty) return null;

    // Return first incomplete slide (in order)
    incompleteSlides.sort((a, b) => a.order.compareTo(b.order));
    return incompleteSlides.first;
  }

  /// Get AI feedback after game session
  /// TODO: Replace with POST /api/ai/game-feedback endpoint
  static Future<List<String>> getGameFeedback({
    required GameSession session,
    required List<String> completedTopics,
  }) async {
    await Future.delayed(const Duration(milliseconds: 600));

    final List<String> feedback = [];

    // Analyze game performance
    final guessedCount = session.rounds.where((r) => r.wasGuessed).length;
    final skippedCount = session.rounds.where((r) => r.wasSkipped).length;

    if (skippedCount > guessedCount) {
      feedback.add(
          "You skipped a few terms - don't worry! Check out the Learn section to brush up on financial basics.");
    }

    // Check for weak categories
    final categories = session.rounds.map((r) => r.word.category).toSet();
    final weakCategories = categories.where((cat) {
      final categoryRounds =
          session.rounds.where((r) => r.word.category == cat).toList();
      final guessedInCategory =
          categoryRounds.where((r) => r.wasGuessed).length;
      return guessedInCategory < categoryRounds.length / 2;
    }).toList();

    if (weakCategories.isNotEmpty) {
      feedback.add(
          "Focus on ${weakCategories.first} - check the Learn slides to master this topic!");
    }

    if (feedback.isEmpty) {
      feedback.add("Great job! Keep playing to level up your financial knowledge.");
    }

    return feedback;
  }

  /// Generate personal game from statement
  /// TODO: Replace with POST /api/upload_statement and POST /api/create_game endpoints
  static Future<PersonalGame> generatePersonalGame({
    required Map<String, double> categorizedSpending,
  }) async {
    await Future.delayed(const Duration(milliseconds: 1000));

    final List<PersonalGameQuestion> questions = [];

    // Generate questions based on spending categories
    for (var entry in categorizedSpending.entries) {
      final category = entry.key;
      final amount = entry.value;

      String question;
      List<String> options;
      int correctIndex;

      switch (category) {
        case 'Food':
          question =
              "You spent R${amount.toStringAsFixed(0)} on food last month. Can you save R${(amount * 0.2).toStringAsFixed(0)} next month?";
          options = [
            "Yes, I'll meal prep",
            "Maybe, I'll try",
            "No, that's too hard",
            "I don't know"
          ];
          correctIndex = 0;
          break;
        case 'Transport':
          question =
              "Your transport costs R${amount.toStringAsFixed(0)} per month. What's the best way to reduce this?";
          options = [
            "Use public transport more",
            "Carpool with friends",
            "Walk when possible",
            "All of the above"
          ];
          correctIndex = 3;
          break;
        case 'Entertainment':
          question =
              "You spent R${amount.toStringAsFixed(0)} on entertainment. What percentage should you aim to save?";
          options = ["5%", "10%", "20%", "30%"];
          correctIndex = 1;
          break;
        case 'Data':
          question =
              "Your data costs R${amount.toStringAsFixed(0)}. How can you reduce this?";
          options = [
            "Use WiFi more",
            "Monitor data usage",
            "Switch to a cheaper plan",
            "All of the above"
          ];
          correctIndex = 3;
          break;
        default:
          continue;
      }

      questions.add(PersonalGameQuestion(
        id: DateTime.now().millisecondsSinceEpoch.toString() + '_$category',
        question: question,
        options: options,
        correctIndex: correctIndex,
        category: category,
        explanation: "Reflecting on your spending helps you make better choices!",
      ));
    }

    return PersonalGame(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      createdAt: DateTime.now(),
      questions: questions.take(5).toList(), // Limit to 5 questions
      categorizedSpending: categorizedSpending,
    );
  }

  /// Check if message is financial-related
  /// Client-side validation to enforce financial-only rule
  static bool isFinancialMessage(String message) {
    final financialKeywords = [
      'money',
      'budget',
      'save',
      'spend',
      'debt',
      'credit',
      'loan',
      'interest',
      'bill',
      'split',
      'financial',
      'bank',
      'account',
      'cash',
      'income',
      'expense',
      'investment',
      'savings',
      'payment',
      'owe',
      'paid',
      'currency',
      'rand',
      'zar',
    ];

    final messageLower = message.toLowerCase();
    return financialKeywords.any((keyword) => messageLower.contains(keyword));
  }
}



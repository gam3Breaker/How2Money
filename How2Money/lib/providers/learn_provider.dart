import 'package:flutter/foundation.dart';
import '../models/learn_slide.dart';
import '../services/local_storage_service.dart';

class LearnProvider with ChangeNotifier {
  final LocalStorageService _storage = LocalStorageService();

  List<LearnSlide> _slides = [];
  List<String> _completedSlideIds = [];
  bool _isLoading = true;

  List<LearnSlide> get slides => _slides;
  List<String> get completedSlideIds => _completedSlideIds;
  bool get isLoading => _isLoading;
  double get progressPercentage {
    if (_slides.isEmpty) return 0.0;
    return (_completedSlideIds.length / _slides.length) * 100;
  }

  LearnProvider() {
    _initializeSlides();
  }

  Future<void> _initializeSlides() async {
    _isLoading = true;
    notifyListeners();

    // Load completed slides
    _completedSlideIds = await _storage.getCompletedSlides();

    // Load or create slides
    _slides = await _storage.getLearnSlides();
    if (_slides.isEmpty) {
      _slides = _getDefaultSlides();
      await _storage.saveLearnSlides(_slides);
    } else {
      // Update completed status
      _slides = _slides.map((slide) {
        return slide.copyWith(
          isCompleted: _completedSlideIds.contains(slide.id),
        );
      }).toList();
    }

    _isLoading = false;
    notifyListeners();
  }

  List<LearnSlide> _getDefaultSlides() {
    return [
      LearnSlide(
        id: 'budget_1',
        title: 'What is a Budget?',
        category: 'Budgeting',
        bulletPoints: [
          'A budget is a plan for your money',
          'It helps you track income and expenses',
          'You decide where your money goes',
          'It prevents overspending',
          'Review and adjust monthly',
        ],
        order: 1,
      ),
      LearnSlide(
        id: 'budget_2',
        title: 'Creating Your First Budget',
        category: 'Budgeting',
        bulletPoints: [
          'List all your income sources',
          'Track your expenses for a month',
          'Categorize: Needs vs Wants',
          'Set spending limits for each category',
          'Use the 50/30/20 rule: 50% needs, 30% wants, 20% savings',
        ],
        order: 2,
      ),
      LearnSlide(
        id: 'saving_1',
        title: 'Why Save Money?',
        category: 'Saving',
        bulletPoints: [
          'Emergency fund for unexpected expenses',
          'Achieve financial goals',
          'Reduce financial stress',
          'Build wealth over time',
          'Create financial security',
        ],
        order: 3,
      ),
      LearnSlide(
        id: 'saving_2',
        title: 'How to Start Saving',
        category: 'Saving',
        bulletPoints: [
          'Start small - even R50 a month helps',
          'Set up automatic transfers',
          'Save before you spend',
          'Set specific savings goals',
          'Track your progress',
        ],
        order: 4,
      ),
      LearnSlide(
        id: 'credit_1',
        title: 'Understanding Credit Score',
        category: 'Credit Score',
        bulletPoints: [
          'Credit score ranges from 300-850',
          'Higher score = better loan rates',
          'Payment history matters most',
          'Keep credit utilization below 30%',
          'Check your score regularly',
        ],
        order: 5,
      ),
      LearnSlide(
        id: 'credit_2',
        title: 'Improving Your Credit Score',
        category: 'Credit Score',
        bulletPoints: [
          'Pay bills on time, every time',
          'Keep credit card balances low',
          "Don't close old accounts",
          'Limit new credit applications',
          'Be patient - it takes time',
        ],
        order: 6,
      ),
      LearnSlide(
        id: 'debt_1',
        title: 'Managing Debt',
        category: 'Debt',
        bulletPoints: [
          'List all your debts',
          'Pay minimums on all debts',
          'Focus extra payments on smallest debt first',
          'Avoid taking on new debt',
          'Consider debt consolidation',
        ],
        order: 7,
      ),
      LearnSlide(
        id: 'debt_2',
        title: 'Getting Out of Debt',
        category: 'Debt',
        bulletPoints: [
          'Create a debt payoff plan',
          'Use the debt snowball method',
          'Cut unnecessary expenses',
          'Increase your income if possible',
          'Stay motivated and track progress',
        ],
        order: 8,
      ),
    ];
  }

  Future<void> markSlideCompleted(String slideId) async {
    if (!_completedSlideIds.contains(slideId)) {
      _completedSlideIds.add(slideId);
      await _storage.markSlideCompleted(slideId);

      // Update slide status
      _slides = _slides.map((slide) {
        if (slide.id == slideId) {
          return slide.copyWith(isCompleted: true);
        }
        return slide;
      }).toList();

      notifyListeners();
    }
  }

  List<LearnSlide> getSlidesByCategory(String category) {
    return _slides.where((slide) => slide.category == category).toList();
  }

  List<String> getCompletedTopics() {
    return _slides
        .where((slide) => _completedSlideIds.contains(slide.id))
        .map((slide) => slide.category)
        .toSet()
        .toList();
  }
}



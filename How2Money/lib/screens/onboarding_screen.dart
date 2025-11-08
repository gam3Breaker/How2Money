import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../models/user.dart';
import '../theme/app_theme.dart';
import 'dashboard_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  String _displayName = '';
  FinancialBackground? _selectedBackground;

  final List<OnboardingSlide> _slides = [
    OnboardingSlide(
      title: 'Welcome to MoneyWise',
      description:
          'Learn money skills through games, get AI-powered financial advice, and track your spending - all in one fun app!',
      icon: Icons.account_balance_wallet,
    ),
    OnboardingSlide(
      title: 'Play & Learn',
      description:
          'Master financial terms through charades games, complete learning slides, and get personalized tips from KasiCash AI.',
      icon: Icons.games,
    ),
    OnboardingSlide(
      title: 'Split Bills & Track Debt',
      description:
          'Easily split bills with friends, track who owes what, and get reminders to stay on top of your finances.',
      icon: Icons.receipt_long,
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _slides.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _completeOnboarding() async {
    if (_displayName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your name')),
      );
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.completeOnboarding(
      displayName: _displayName,
      background: _selectedBackground,
    );

    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const DashboardScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: PageView.builder(
          controller: _pageController,
          onPageChanged: (index) {
            setState(() {
              _currentPage = index;
            });
          },
          itemCount: _slides.length + 1, // +1 for profile setup
          itemBuilder: (context, index) {
            if (index < _slides.length) {
              return _buildSlide(_slides[index]);
            } else {
              return _buildProfileSetup();
            }
          },
        ),
      ),
      bottomNavigationBar: _currentPage < _slides.length
          ? _buildSlideNavigation()
          : _buildProfileNavigation(),
    );
  }

  Widget _buildSlide(OnboardingSlide slide) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: AppTheme.primaryTeal.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              slide.icon,
              size: 64,
              color: AppTheme.primaryTeal,
            ),
          ),
          const SizedBox(height: 48),
          Text(
            slide.title,
            style: Theme.of(context).textTheme.displayMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Text(
            slide.description,
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildProfileSetup() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Tell us about yourself',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 48),
          TextField(
            decoration: const InputDecoration(
              labelText: 'Display Name',
              hintText: 'Enter your name',
              prefixIcon: Icon(Icons.person),
            ),
            onChanged: (value) {
              setState(() {
                _displayName = value;
              });
            },
          ),
          const SizedBox(height: 32),
          const Text(
            'Financial Background',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          ...FinancialBackground.values.map((background) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: RadioListTile<FinancialBackground>(
                title: Text(background.displayName),
                value: background,
                groupValue: _selectedBackground,
                onChanged: (value) {
                  setState(() {
                    _selectedBackground = value;
                  });
                },
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: _selectedBackground == background
                        ? AppTheme.primaryTeal
                        : Colors.grey,
                    width: 2,
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildSlideNavigation() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (_currentPage > 0)
            TextButton(
              onPressed: _previousPage,
              child: const Text('Previous'),
            )
          else
            const SizedBox(),
          Row(
            children: List.generate(
              _slides.length,
              (index) => Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _currentPage == index
                      ? AppTheme.primaryTeal
                      : Colors.grey,
                ),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: _nextPage,
            child: const Text('Next'),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileNavigation() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: ElevatedButton(
        onPressed: _completeOnboarding,
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(double.infinity, 50),
        ),
        child: const Text('Get Started'),
      ),
    );
  }
}

class OnboardingSlide {
  final String title;
  final String description;
  final IconData icon;

  OnboardingSlide({
    required this.title,
    required this.description,
    required this.icon,
  });
}



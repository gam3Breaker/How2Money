import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/learn_provider.dart';
import '../providers/ai_provider.dart';
import '../theme/app_theme.dart';

class LearnSlidesScreen extends StatelessWidget {
  const LearnSlidesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final learnProvider = Provider.of<LearnProvider>(context);
    final aiProvider = Provider.of<AIProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Learn'),
        actions: [
          IconButton(
            icon: const Icon(Icons.psychology),
            onPressed: () async {
              // Get AI recommendation
              final recommended = await aiProvider.recommendNextSlide(
                allSlides: learnProvider.slides,
                completedSlideIds: learnProvider.completedSlideIds,
              );

              if (recommended != null && context.mounted) {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('KasiCash Recommends'),
                    content: Text(
                      'Next slide to learn: ${recommended.title}',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('OK'),
                      ),
                    ],
                  ),
                );
              } else if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('You\'ve completed all slides!'),
                  ),
                );
              }
            },
            tooltip: 'Get recommendation from KasiCash',
          ),
        ],
      ),
      body: learnProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Progress bar
                Container(
                  padding: const EdgeInsets.all(16),
                  color: Colors.white,
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Progress: ${learnProvider.progressPercentage.toStringAsFixed(0)}%',
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                          Text(
                            '${learnProvider.completedSlideIds.length}/${learnProvider.slides.length}',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: learnProvider.progressPercentage / 100,
                        backgroundColor: AppTheme.backgroundLight,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          AppTheme.primaryTeal,
                        ),
                      ),
                    ],
                  ),
                ),
                // Slides list
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: learnProvider.slides.length,
                    itemBuilder: (context, index) {
                      final slide = learnProvider.slides[index];
                      return _SlideCard(slide: slide);
                    },
                  ),
                ),
              ],
            ),
    );
  }
}

class _SlideCard extends StatelessWidget {
  final dynamic slide; // LearnSlide

  const _SlideCard({required this.slide});

  @override
  Widget build(BuildContext context) {
    final learnProvider = Provider.of<LearnProvider>(context, listen: false);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: slide.isCompleted
              ? AppTheme.success
              : AppTheme.primaryTeal.withOpacity(0.2),
          child: Icon(
            slide.isCompleted ? Icons.check : Icons.school,
            color: slide.isCompleted ? Colors.white : AppTheme.primaryTeal,
          ),
        ),
        title: Text(
          slide.title,
          style: TextStyle(
            fontWeight: slide.isCompleted
                ? FontWeight.normal
                : FontWeight.bold,
            decoration: slide.isCompleted
                ? TextDecoration.lineThrough
                : TextDecoration.none,
          ),
        ),
        subtitle: Text(
          slide.category,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Divider(),
                const SizedBox(height: 8),
                ...slide.bulletPoints.map((point) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.check_circle_outline,
                            size: 20,
                            color: AppTheme.primaryTeal,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              point,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ),
                        ],
                      ),
                    )),
                const SizedBox(height: 16),
                if (!slide.isCompleted)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        await learnProvider.markSlideCompleted(slide.id);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('${slide.title} marked as completed!'),
                            ),
                          );
                        }
                      },
                      child: const Text('Mark as Read'),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}



import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class TikTokIntegrationScreen extends StatelessWidget {
  const TikTokIntegrationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TikTok Integration'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            const Icon(
              Icons.video_library,
              size: 80,
              color: AppTheme.primaryTeal,
            ),
            const SizedBox(height: 24),
            const Text(
              'Share Challenges to TikTok',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Create and share your financial challenges with the TikTok community!',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 32),

            // How it works
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'How it works:',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _FeatureItem(
                      icon: Icons.games,
                      title: 'Complete Challenges',
                      description:
                          'Complete financial challenges in the app and earn achievements',
                    ),
                    const SizedBox(height: 16),
                    _FeatureItem(
                      icon: Icons.video_camera_back,
                      title: 'Create Video',
                      description:
                          'Generate a video preview of your game highlights and results',
                    ),
                    const SizedBox(height: 16),
                    _FeatureItem(
                      icon: Icons.share,
                      title: 'Share to TikTok',
                      description:
                          'Share your challenge video to TikTok with custom filters and effects',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Create Challenge button
            ElevatedButton.icon(
              onPressed: () {
                _showCreateChallengeDialog(context);
              },
              icon: const Icon(Icons.add),
              label: const Text('Create Challenge'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
            const SizedBox(height: 24),

            // TODO section
            Card(
              color: AppTheme.backgroundLight,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'TODO: Backend Integration',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryTeal,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'This feature requires backend integration with:',
                      style: TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    const _TodoItem(
                      text: 'TikTok Developer API for video uploads',
                    ),
                    const _TodoItem(
                      text: 'TikTok Effect House for custom filters',
                    ),
                    const _TodoItem(
                      text: 'Video generation service for game highlights',
                    ),
                    const _TodoItem(
                      text: 'Leaderboard API for challenge rankings',
                    ),
                    const _TodoItem(
                      text: 'Webhook endpoint for challenge results',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Mock features
            const Text(
              'Mock Features (Frontend Only)',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: ListTile(
                leading: const Icon(Icons.video_library, color: AppTheme.primaryTeal),
                title: const Text('Generate Video Preview'),
                subtitle: const Text('Create a mock video preview of game highlights'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  _showMockVideoPreview(context);
                },
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: ListTile(
                leading: const Icon(Icons.leaderboard, color: AppTheme.primaryTeal),
                title: const Text('View Leaderboard'),
                subtitle: const Text('Mock leaderboard for challenge rankings'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  _showMockLeaderboard(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCreateChallengeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create Challenge'),
        content: const Text(
          'In production, this would:\n\n'
          '1. Record game highlights\n'
          '2. Generate video with TikTok filters\n'
          '3. Upload to TikTok via API\n'
          '4. Share challenge link\n\n'
          'For now, this is a mock feature.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showMockVideoPreview(context);
            },
            child: const Text('Generate Mock Video'),
          ),
        ],
      ),
    );
  }

  void _showMockVideoPreview(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Mock Video Preview',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              height: 200,
              decoration: BoxDecoration(
                color: AppTheme.backgroundLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.video_library, size: 64, color: AppTheme.textSecondary),
                    SizedBox(height: 8),
                    Text('Video preview would appear here'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'In production, this would show a video preview of your game highlights with TikTok filters applied.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Mock: Video would be uploaded to TikTok'),
                        ),
                      );
                    },
                    child: const Text('Share to TikTok'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showMockLeaderboard(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Challenge Leaderboard',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Card(
              child: ListTile(
                leading: CircleAvatar(child: Text('1')),
                title: Text('Top Player'),
                trailing: Text('10,000 pts'),
              ),
            ),
            const Card(
              child: ListTile(
                leading: CircleAvatar(child: Text('2')),
                title: Text('Second Place'),
                trailing: Text('8,500 pts'),
              ),
            ),
            const Card(
              child: ListTile(
                leading: CircleAvatar(child: Text('3')),
                title: Text('Third Place'),
                trailing: Text('7,200 pts'),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Mock leaderboard - in production, this would fetch real data from the backend API.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        ),
      ),
    );
  }
}

class _FeatureItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _FeatureItem({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppTheme.primaryTeal),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TodoItem extends StatelessWidget {
  final String text;

  const _TodoItem({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle_outline, size: 16, color: AppTheme.textSecondary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}



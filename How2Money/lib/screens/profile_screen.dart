import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';
import 'personal_game_screen.dart';
import 'tiktok_integration_screen.dart';
import 'splash_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile header
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: AppTheme.primaryTeal,
                      child: Text(
                        authProvider.user?.displayName[0].toUpperCase() ?? 'U',
                        style: const TextStyle(
                          fontSize: 32,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            authProvider.user?.displayName ?? 'User',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            authProvider.user?.background?.displayName ?? 'No background set',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          if (authProvider.user?.isPremium == true)
                            Container(
                              margin: const EdgeInsets.only(top: 8),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                gradient: AppTheme.goldGradient,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text(
                                'PREMIUM',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Settings section
            Text(
              'Settings',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 16),

            // Premium toggle
            Card(
              child: SwitchListTile(
                title: const Text('Premium Status'),
                subtitle: const Text('Enable premium features (demo)'),
                value: authProvider.user?.isPremium ?? false,
                onChanged: (value) async {
                  await authProvider.setPremium(value);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          value
                              ? 'Premium enabled (demo)'
                              : 'Premium disabled',
                        ),
                      ),
                    );
                  }
                },
              ),
            ),
            const SizedBox(height: 12),

            // Currency
            Card(
              child: ListTile(
                title: const Text('Currency'),
                subtitle: Text(authProvider.user?.currency ?? 'ZAR'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  // TODO: Implement currency selection
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Currency selection coming soon')),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),

            // Weekly reminder time
            Card(
              child: ListTile(
                title: const Text('Weekly Debt Reminder'),
                subtitle: const Text('Set reminder time (coming soon)'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  // TODO: Implement reminder time setting
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Reminder settings coming soon')),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),

            // Features section
            Text(
              'Features',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 16),

            // Personal Game
            Card(
              child: ListTile(
                title: const Text('Personal Game'),
                subtitle: const Text('Generate game from bank statement'),
                leading: const Icon(Icons.games, color: AppTheme.primaryTeal),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const PersonalGameScreen(),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),

            // TikTok Integration
            Card(
              child: ListTile(
                title: const Text('TikTok Integration'),
                subtitle: const Text('Share challenges to TikTok'),
                leading: const Icon(Icons.video_library, color: AppTheme.primaryTeal),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const TikTokIntegrationScreen(),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),

            // Logout
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () async {
                  await authProvider.logout();
                  if (context.mounted) {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => const SplashScreen()),
                      (route) => false,
                    );
                  }
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.error,
                  side: const BorderSide(color: AppTheme.error),
                ),
                child: const Text('Logout'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

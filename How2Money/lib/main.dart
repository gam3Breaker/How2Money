import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme/app_theme.dart';
import 'providers/auth_provider.dart';
import 'providers/ai_provider.dart';
import 'providers/game_provider.dart';
import 'providers/split_provider.dart';
import 'providers/learn_provider.dart';
import 'screens/splash_screen.dart';

void main() {
  runApp(const MoneyWiseApp());
}

class MoneyWiseApp extends StatelessWidget {
  const MoneyWiseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => AIProvider()),
        ChangeNotifierProvider(create: (_) => GameProvider()),
        ChangeNotifierProvider(create: (_) => SplitProvider()),
        ChangeNotifierProvider(create: (_) => LearnProvider()),
      ],
      child: MaterialApp(
        title: 'MoneyWise',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const SplashScreen(),
      ),
    );
  }
}



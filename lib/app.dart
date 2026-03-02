import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'core/theme/app_theme.dart';
import 'presentation/screens/home/home_screen.dart';
import 'presentation/screens/game_setup/game_setup_screen.dart';
import 'presentation/screens/scoring/scoring_screen.dart';
import 'presentation/screens/history/history_screen.dart';

final _router = GoRouter(
  routes: [
    GoRoute(path: '/', builder: (context, state) => const HomeScreen()),
    GoRoute(
      path: '/setup',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>;
        return GameSetupScreen(
          gameId: extra['gameId'] as String,
          gameName: extra['gameName'] as String,
          gameType: extra['gameType'] as String,
        );
      },
    ),
    GoRoute(
      path: '/scoring',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>;
        return ScoringScreen(
          gameId: extra['gameId'] as String,
          gameName: extra['gameName'] as String,
          gameType: extra['gameType'] as String,
          players: (extra['players'] as List).cast<Map<String, dynamic>>(),
        );
      },
    ),
    GoRoute(
      path: '/history',
      builder: (context, state) => const HistoryScreen(),
    ),
  ],
);

class BoardGameScoreApp extends ConsumerWidget {
  const BoardGameScoreApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'BoardGameScore',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      routerConfig: _router,
    );
  }
}

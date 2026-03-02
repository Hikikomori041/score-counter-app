import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/database/database_helper.dart';
import '../../domain/entities/game.dart';
import '../../domain/entities/player.dart';
import '../../domain/entities/game_session.dart';
import '../../domain/repositories/player_repository.dart';
import '../../domain/repositories/game_repository.dart';
import '../../domain/repositories/session_repository.dart';
import '../../data/repositories/player_repository_impl.dart';
import '../../data/repositories/game_repository_impl.dart';
import '../../data/repositories/session_repository_impl.dart';

enum SortMode { lastUsed, alphabetical }

// Repository providers
final playerRepositoryProvider = Provider<PlayerRepository>(
  (ref) => PlayerRepositoryImpl(DatabaseHelper.instance),
);

final gameRepositoryProvider = Provider<GameRepository>(
  (ref) => GameRepositoryImpl(DatabaseHelper.instance),
);

final sessionRepositoryProvider = Provider<SessionRepository>(
  (ref) => SessionRepositoryImpl(DatabaseHelper.instance),
);

// State providers
final sortModeProvider = StateProvider<SortMode>((ref) => SortMode.lastUsed);

final gamesProvider = FutureProvider<List<Game>>((ref) {
  return ref.read(gameRepositoryProvider).getAllGames();
});

final playersProvider = FutureProvider<List<Player>>((ref) {
  return ref.read(playerRepositoryProvider).getAllPlayers();
});

final sessionsProvider = FutureProvider<List<GameSession>>((ref) {
  return ref.read(sessionRepositoryProvider).getAllSessions();
});

// Sorted games derived provider
final sortedGamesProvider = FutureProvider<List<Game>>((ref) async {
  final games = await ref.watch(gamesProvider.future);
  final sortMode = ref.watch(sortModeProvider);
  final sorted = List<Game>.from(games);
  if (sortMode == SortMode.lastUsed) {
    sorted.sort((a, b) => b.lastUsed.compareTo(a.lastUsed));
  } else {
    sorted.sort((a, b) => a.name.compareTo(b.name));
  }
  return sorted;
});

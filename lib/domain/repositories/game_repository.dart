import '../entities/game.dart';

abstract class GameRepository {
  Future<List<Game>> getAllGames();
  Future<Game?> getGameById(String id);
  Future<void> insertGame(Game game);
  Future<void> updateGame(Game game);
  Future<void> deleteGame(String id);
  Future<void> updateLastUsed(String id, DateTime lastUsed);
  Future<void> toggleFavorite(String id, bool isFavorite);
}

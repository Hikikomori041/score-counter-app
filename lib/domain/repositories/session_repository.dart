import '../entities/game_session.dart';

abstract class SessionRepository {
  Future<List<GameSession>> getAllSessions();
  Future<List<GameSession>> getSessionsByGameId(String gameId);
  Future<GameSession?> getSessionById(String id);
  Future<void> insertSession(GameSession session);
  Future<void> updateSession(GameSession session);
  Future<void> deleteSession(String id);
}

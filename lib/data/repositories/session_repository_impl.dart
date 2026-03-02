import 'package:sqflite/sqflite.dart';
import '../../core/database/database_helper.dart';
import '../../domain/entities/game_session.dart';
import '../../domain/repositories/session_repository.dart';
import '../models/game_session_model.dart';

class SessionRepositoryImpl implements SessionRepository {
  SessionRepositoryImpl(this._dbHelper);

  final DatabaseHelper _dbHelper;

  @override
  Future<List<GameSession>> getAllSessions() async {
    final db = await _dbHelper.database;
    final sessions = await db.query(
      'game_sessions',
      orderBy: 'started_at DESC',
    );
    final result = <GameSession>[];
    for (final s in sessions) {
      final scores = await db.query(
        'session_scores',
        where: 'session_id = ?',
        whereArgs: [s['id']],
      );
      result.add(GameSessionModel.fromMap(s, scores));
    }
    return result;
  }

  @override
  Future<List<GameSession>> getSessionsByGameId(String gameId) async {
    final db = await _dbHelper.database;
    final sessions = await db.query(
      'game_sessions',
      where: 'game_id = ?',
      whereArgs: [gameId],
      orderBy: 'started_at DESC',
    );
    final result = <GameSession>[];
    for (final s in sessions) {
      final scores = await db.query(
        'session_scores',
        where: 'session_id = ?',
        whereArgs: [s['id']],
      );
      result.add(GameSessionModel.fromMap(s, scores));
    }
    return result;
  }

  @override
  Future<GameSession?> getSessionById(String id) async {
    final db = await _dbHelper.database;
    final sessions = await db.query(
      'game_sessions',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (sessions.isEmpty) return null;
    final scores = await db.query(
      'session_scores',
      where: 'session_id = ?',
      whereArgs: [id],
    );
    return GameSessionModel.fromMap(sessions.first, scores);
  }

  @override
  Future<void> insertSession(GameSession session) async {
    final db = await _dbHelper.database;
    final model = GameSessionModel.fromEntity(session);
    await db.transaction((txn) async {
      await txn.insert(
        'game_sessions',
        model.toSessionMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      await txn.delete(
        'session_scores',
        where: 'session_id = ?',
        whereArgs: [session.id],
      );
      for (final entry in session.scores.entries) {
        // entry.key is the player name (scores are keyed by player name)
        await txn.insert('session_scores', {
          'session_id': session.id,
          'player_id': entry.key,
          'player_name': entry.key,
          'score': entry.value,
        });
      }
    });
  }

  @override
  Future<void> updateSession(GameSession session) async {
    final db = await _dbHelper.database;
    final model = GameSessionModel.fromEntity(session);
    await db.transaction((txn) async {
      await txn.update(
        'game_sessions',
        model.toSessionMap(),
        where: 'id = ?',
        whereArgs: [session.id],
      );
      await txn.delete(
        'session_scores',
        where: 'session_id = ?',
        whereArgs: [session.id],
      );
      for (final entry in session.scores.entries) {
        // entry.key is the player name (scores are keyed by player name)
        await txn.insert('session_scores', {
          'session_id': session.id,
          'player_id': entry.key,
          'player_name': entry.key,
          'score': entry.value,
        });
      }
    });
  }

  @override
  Future<void> deleteSession(String id) async {
    final db = await _dbHelper.database;
    await db.transaction((txn) async {
      await txn.delete(
        'session_scores',
        where: 'session_id = ?',
        whereArgs: [id],
      );
      await txn.delete(
        'game_sessions',
        where: 'id = ?',
        whereArgs: [id],
      );
    });
  }
}

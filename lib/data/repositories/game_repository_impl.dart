import 'package:sqflite/sqflite.dart';
import '../../core/database/database_helper.dart';
import '../../domain/entities/game.dart';
import '../../domain/repositories/game_repository.dart';
import '../models/game_model.dart';

class GameRepositoryImpl implements GameRepository {
  GameRepositoryImpl(this._dbHelper);

  final DatabaseHelper _dbHelper;

  @override
  Future<List<Game>> getAllGames() async {
    final db = await _dbHelper.database;
    final maps = await db.query('games', orderBy: 'name ASC');
    return maps.map((m) => GameModel.fromMap(m)).toList();
  }

  @override
  Future<Game?> getGameById(String id) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'games',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return GameModel.fromMap(maps.first);
  }

  @override
  Future<void> insertGame(Game game) async {
    final db = await _dbHelper.database;
    await db.insert(
      'games',
      GameModel.fromEntity(game).toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> updateGame(Game game) async {
    final db = await _dbHelper.database;
    await db.update(
      'games',
      GameModel.fromEntity(game).toMap(),
      where: 'id = ?',
      whereArgs: [game.id],
    );
  }

  @override
  Future<void> deleteGame(String id) async {
    final db = await _dbHelper.database;
    await db.delete('games', where: 'id = ?', whereArgs: [id]);
  }

  @override
  Future<void> updateLastUsed(String id, DateTime lastUsed) async {
    final db = await _dbHelper.database;
    await db.update(
      'games',
      {'last_used': lastUsed.millisecondsSinceEpoch},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  @override
  Future<void> toggleFavorite(String id, bool isFavorite) async {
    final db = await _dbHelper.database;
    await db.update(
      'games',
      {'is_favorite': isFavorite ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}

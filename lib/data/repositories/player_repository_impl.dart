import 'package:sqflite/sqflite.dart';
import '../../core/database/database_helper.dart';
import '../../domain/entities/player.dart';
import '../../domain/repositories/player_repository.dart';
import '../models/player_model.dart';

class PlayerRepositoryImpl implements PlayerRepository {
  PlayerRepositoryImpl(this._dbHelper);

  final DatabaseHelper _dbHelper;

  @override
  Future<List<Player>> getAllPlayers() async {
    final db = await _dbHelper.database;
    final maps = await db.query('players', orderBy: 'name ASC');
    return maps.map((m) => PlayerModel.fromMap(m)).toList();
  }

  @override
  Future<Player?> getPlayerById(String id) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'players',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return PlayerModel.fromMap(maps.first);
  }

  @override
  Future<void> insertPlayer(Player player) async {
    final db = await _dbHelper.database;
    await db.insert(
      'players',
      PlayerModel.fromEntity(player).toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> updatePlayer(Player player) async {
    final db = await _dbHelper.database;
    await db.update(
      'players',
      PlayerModel.fromEntity(player).toMap(),
      where: 'id = ?',
      whereArgs: [player.id],
    );
  }

  @override
  Future<void> deletePlayer(String id) async {
    final db = await _dbHelper.database;
    await db.delete('players', where: 'id = ?', whereArgs: [id]);
  }
}

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  DatabaseHelper._();
  static final DatabaseHelper instance = DatabaseHelper._();

  static Database? _database;

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'board_game_score.db');
    return openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE players (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        color_hex TEXT NOT NULL,
        icon_name TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE games (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        type TEXT NOT NULL,
        is_favorite INTEGER NOT NULL DEFAULT 0,
        last_used INTEGER NOT NULL DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE game_sessions (
        id TEXT PRIMARY KEY,
        game_id TEXT NOT NULL,
        game_name TEXT NOT NULL,
        game_type TEXT NOT NULL,
        started_at INTEGER NOT NULL,
        ended_at INTEGER,
        winner_id TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE session_scores (
        session_id TEXT NOT NULL,
        player_id TEXT NOT NULL,
        player_name TEXT NOT NULL,
        score INTEGER NOT NULL DEFAULT 0,
        PRIMARY KEY (session_id, player_id)
      )
    ''');

    await _insertDefaultGames(db);
  }

  Future<void> _insertDefaultGames(Database db) async {
    final defaultGames = [
      {
        'id': 'catan',
        'name': 'Catan',
        'type': 'standard',
        'is_favorite': 0,
        'last_used': 0,
      },
      {
        'id': 'ticket-to-ride',
        'name': 'Ticket to Ride',
        'type': 'standard',
        'is_favorite': 0,
        'last_used': 0,
      },
      {
        'id': 'pandemic',
        'name': 'Pandemic',
        'type': 'standard',
        'is_favorite': 0,
        'last_used': 0,
      },
      {
        'id': 'seven-wonders',
        'name': '7 Wonders',
        'type': 'standard',
        'is_favorite': 0,
        'last_used': 0,
      },
      {
        'id': 'splendor',
        'name': 'Splendor',
        'type': 'standard',
        'is_favorite': 0,
        'last_used': 0,
      },
      {
        'id': 'azul',
        'name': 'Azul',
        'type': 'standard',
        'is_favorite': 0,
        'last_used': 0,
      },
      {
        'id': 'wingspan',
        'name': 'Wingspan',
        'type': 'standard',
        'is_favorite': 0,
        'last_used': 0,
      },
      {
        'id': 'skyjo',
        'name': 'Skyjo',
        'type': 'grid',
        'is_favorite': 0,
        'last_used': 0,
      },
      {
        'id': 'scrabble',
        'name': 'Scrabble',
        'type': 'grid',
        'is_favorite': 0,
        'last_used': 0,
      },
      {
        'id': 'mtg',
        'name': 'Magic: The Gathering',
        'type': 'mtg',
        'is_favorite': 1,
        'last_used': 0,
      },
    ];

    for (final game in defaultGames) {
      await db.insert('games', game);
    }
  }
}

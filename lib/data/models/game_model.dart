import '../../domain/entities/game.dart';

class GameModel extends Game {
  const GameModel({
    required super.id,
    required super.name,
    required super.type,
    required super.isFavorite,
    required super.lastUsed,
  });

  factory GameModel.fromMap(Map<String, dynamic> map) {
    return GameModel(
      id: map['id'] as String,
      name: map['name'] as String,
      type: _parseGameType(map['type'] as String),
      isFavorite: (map['is_favorite'] as int) == 1,
      lastUsed: DateTime.fromMillisecondsSinceEpoch(map['last_used'] as int),
    );
  }

  factory GameModel.fromEntity(Game game) {
    return GameModel(
      id: game.id,
      name: game.name,
      type: game.type,
      isFavorite: game.isFavorite,
      lastUsed: game.lastUsed,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'type': type.name,
      'is_favorite': isFavorite ? 1 : 0,
      'last_used': lastUsed.millisecondsSinceEpoch,
    };
  }

  static GameType _parseGameType(String value) {
    return GameType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => GameType.standard,
    );
  }
}

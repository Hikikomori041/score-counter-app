enum GameType { standard, mtg, grid }

class Game {
  const Game({
    required this.id,
    required this.name,
    required this.type,
    required this.isFavorite,
    required this.lastUsed,
  });

  final String id;
  final String name;
  final GameType type;
  final bool isFavorite;
  final DateTime lastUsed;

  Game copyWith({
    String? id,
    String? name,
    GameType? type,
    bool? isFavorite,
    DateTime? lastUsed,
  }) {
    return Game(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      isFavorite: isFavorite ?? this.isFavorite,
      lastUsed: lastUsed ?? this.lastUsed,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Game &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          type == other.type &&
          isFavorite == other.isFavorite &&
          lastUsed == other.lastUsed;

  @override
  int get hashCode =>
      id.hashCode ^
      name.hashCode ^
      type.hashCode ^
      isFavorite.hashCode ^
      lastUsed.hashCode;

  @override
  String toString() =>
      'Game(id: $id, name: $name, type: $type, isFavorite: $isFavorite, lastUsed: $lastUsed)';
}

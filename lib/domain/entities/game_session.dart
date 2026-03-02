class GameSession {
  const GameSession({
    required this.id,
    required this.gameId,
    required this.gameName,
    required this.gameType,
    required this.startedAt,
    this.endedAt,
    required this.scores,
    this.winnerId,
  });

  final String id;
  final String gameId;
  final String gameName;
  final String gameType;
  final DateTime startedAt;
  final DateTime? endedAt;
  final Map<String, int> scores;
  final String? winnerId;

  GameSession copyWith({
    String? id,
    String? gameId,
    String? gameName,
    String? gameType,
    DateTime? startedAt,
    DateTime? endedAt,
    Map<String, int>? scores,
    String? winnerId,
  }) {
    return GameSession(
      id: id ?? this.id,
      gameId: gameId ?? this.gameId,
      gameName: gameName ?? this.gameName,
      gameType: gameType ?? this.gameType,
      startedAt: startedAt ?? this.startedAt,
      endedAt: endedAt ?? this.endedAt,
      scores: scores ?? this.scores,
      winnerId: winnerId ?? this.winnerId,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GameSession &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'GameSession(id: $id, gameId: $gameId, gameName: $gameName, startedAt: $startedAt)';
}

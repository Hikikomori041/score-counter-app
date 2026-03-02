import '../../domain/entities/game_session.dart';

class GameSessionModel extends GameSession {
  const GameSessionModel({
    required super.id,
    required super.gameId,
    required super.gameName,
    required super.gameType,
    required super.startedAt,
    super.endedAt,
    required super.scores,
    super.winnerId,
  });

  /// Builds a [GameSessionModel] from a database row and its associated score rows.
  /// Score keys are player names for display purposes.
  factory GameSessionModel.fromMap(
    Map<String, dynamic> map,
    List<Map<String, dynamic>> scoreRows,
  ) {
    final scores = <String, int>{};
    for (final row in scoreRows) {
      final key = row['player_name'] as String? ?? row['player_id'] as String;
      scores[key] = row['score'] as int;
    }
    return GameSessionModel(
      id: map['id'] as String,
      gameId: map['game_id'] as String,
      gameName: map['game_name'] as String,
      gameType: map['game_type'] as String,
      startedAt:
          DateTime.fromMillisecondsSinceEpoch(map['started_at'] as int),
      endedAt: map['ended_at'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['ended_at'] as int)
          : null,
      scores: scores,
      winnerId: map['winner_id'] as String?,
    );
  }

  factory GameSessionModel.fromEntity(GameSession session) {
    return GameSessionModel(
      id: session.id,
      gameId: session.gameId,
      gameName: session.gameName,
      gameType: session.gameType,
      startedAt: session.startedAt,
      endedAt: session.endedAt,
      scores: session.scores,
      winnerId: session.winnerId,
    );
  }

  Map<String, dynamic> toSessionMap() {
    return {
      'id': id,
      'game_id': gameId,
      'game_name': gameName,
      'game_type': gameType,
      'started_at': startedAt.millisecondsSinceEpoch,
      'ended_at': endedAt?.millisecondsSinceEpoch,
      'winner_id': winnerId,
    };
  }
}

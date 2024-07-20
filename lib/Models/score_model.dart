class Score {
  int id = 0;
  int gameId;
  int matchId;
  int playerId;
  int score;

  Score({
    required this.gameId,
    required this.matchId,
    required this.playerId,
    required this.score,
  });

  Score.withId({
    required this.id,
    required this.gameId,
    required this.matchId,
    required this.playerId,
    required this.score,
  });

  // Convert a Score instance to a map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'gameId': gameId,
      'matchId': matchId,
      'playerId': playerId,
      'score': score,
    };
  }

  // Convert a map to a Score instance
  factory Score.fromMap(Map<String, dynamic> map) {
    return Score.withId(
      id: map['id'] ?? 0, // Provide default values if needed
      gameId: map['gameId'] ?? 0,
      matchId: map['matchId'] ?? 0,
      playerId: map['playerId'] ?? 0,
      score: map['score'] ?? 0,
    );
  }
}

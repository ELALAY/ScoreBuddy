class Score {
  int id = 0;
  int gameId;
  int matchId;
  int playerId;
  int score;
  int won; //-1:loss, 0: lost, 1: draw, 

  Score({
    required this.gameId,
    required this.matchId,
    required this.playerId,
    required this.score,
    required this.won,
  });

  Score.withId({
    required this.id,
    required this.gameId,
    required this.matchId,
    required this.playerId,
    required this.score,
    required this.won,
  });

  // Convert a Score instance to a map
  Map<String, dynamic> toMap() {
    return {
      'game_id': gameId,
      'match_id': matchId,
      'player_id': playerId,
      'score': score,
      'won': won,
    };
  }
  // Convert a Score instance to a map
  Map<String, dynamic> toMapwithId() {
    return {
      'id': id,
      'game_id': gameId,
      'match_id': matchId,
      'player_id': playerId,
      'score': score,
      'won': won,
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
      won: map['won'] ?? 0,
    );
  }
}

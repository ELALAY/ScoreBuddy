
class PlayerScore {
  int id = 0;
  int gameId;
  int roomId;
  int playerId;
  int score;

  PlayerScore({
    required this.gameId,
    required this.roomId,
    required this.playerId,
    required this.score,
  });

  PlayerScore.withId({
    required this.id,
    required this.gameId,
    required this.roomId,
    required this.playerId,
    required this.score,
  });
// Convert PlayerScore object to map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'gameId': gameId,
      'roomId': roomId,
      'playerId': playerId,
      'score': score,
    };
  }

  // Convert map to PlayerScore object
  factory PlayerScore.fromMap(Map<String, dynamic> map) {
    return PlayerScore.withId(
      id: map['id'] ?? 0, // Provide default value if id is not present
      gameId: map['gameId'] ?? 0,
      roomId: map['roomId'] ?? 0,
      playerId: map['playerId'] ?? 0, // Assuming playerId should be int, not string
      score: map['score'] ?? 0,
    );
  }
}

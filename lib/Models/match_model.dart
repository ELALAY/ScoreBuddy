class Match {
  int id = 0;
  int gameId;
  String name;
  int target;

  Match(this.gameId, this.name, this.target);
  Match.withId(this.id, this.gameId, this.name, this.target);

  // Convert a Match instance to a map
  Map<String, dynamic> toMap() {
    return {
      'game_id': gameId,
      'name': name,
      'target': target,
    };
  }

  factory Match.fromMap(Map<String, dynamic> map) {
    return Match.withId(map['id'] ?? 0, map['game_id'] ?? 0, map['name'] ?? "N/A", map['target'] ?? 0);
  }
}
